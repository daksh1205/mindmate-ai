import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
// adjust to your project's secrets file

// ─── Model ────────────────────────────────────────────────────────────────────

class CallRecord {
  final String callId;
  final String phoneNumber;
  final String createdAt;
  final String summary;
  final String status;
  final double callLength;

  const CallRecord({
    required this.callId,
    required this.phoneNumber,
    required this.createdAt,
    required this.summary,
    required this.status,
    required this.callLength,
  });

  factory CallRecord.fromJson(Map<String, dynamic> json) {
    double length = 0.0;
    final raw = json['call_length'];
    if (raw is num) {
      length = raw.toDouble();
    } else if (raw is String) {
      length = double.tryParse(raw) ?? 0.0;
    }

    String createdAt =
        json['created_at'] ?? json['createdAt'] ?? '2023-01-01T00:00:00.000Z';
    try {
      DateTime.parse(createdAt);
    } catch (_) {
      createdAt = '2023-01-01T00:00:00.000Z';
    }

    return CallRecord(
      callId: json['call_id'] ?? '',
      phoneNumber: json['to'] ?? json['phoneNumber'] ?? '',
      createdAt: createdAt,
      summary: json['summary'] ?? 'No summary available',
      status: json['status'] ?? 'unknown',
      callLength: length,
    );
  }

  Map<String, dynamic> toJson() => {
    'call_id': callId,
    'phoneNumber': phoneNumber,
    'createdAt': createdAt,
    'summary': summary,
    'status': status,
    'call_length': callLength,
  };

  CallRecord copyWith({
    String? callId,
    String? phoneNumber,
    String? createdAt,
    String? summary,
    String? status,
    double? callLength,
  }) => CallRecord(
    callId: callId ?? this.callId,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    createdAt: createdAt ?? this.createdAt,
    summary: summary ?? this.summary,
    status: status ?? this.status,
    callLength: callLength ?? this.callLength,
  );
}

// ─── Service ──────────────────────────────────────────────────────────────────

class CallHistoryService {
  static const String _baseUrl = 'https://api.bland.ai/v1/calls/';
  static const String _apiKey = AppSecrets.blandApiKey;
  static const String _prefKey = 'call_history';

  // ── Fetch single call from Bland AI ───────────────────────────────────────

  static Future<CallRecord?> fetchCallDetails(String callId) async {
    log('[CallHistoryService] Fetching call: $callId');
    try {
      final existing = await _findInHistory(callId);

      final res = await http.get(
        Uri.parse('$_baseUrl$callId'),
        headers: {'authorization': _apiKey, 'Content-Type': 'application/json'},
      );

      log('[CallHistoryService] Response ${res.statusCode} for $callId');

      if (res.statusCode != 200) return null;

      CallRecord fetched = CallRecord.fromJson(jsonDecode(res.body));

      // Preserve original createdAt if API didn't return one
      if (fetched.createdAt.isEmpty && existing != null) {
        fetched = fetched.copyWith(createdAt: existing.createdAt);
      }

      await _upsertRecord(fetched);
      return fetched;
    } catch (e) {
      log('[CallHistoryService] fetchCallDetails error: $e');
      return null;
    }
  }

  // ── Get full history from SharedPrefs ─────────────────────────────────────

  static Future<List<CallRecord>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefKey) ?? [];
      final list = raw.map((s) => CallRecord.fromJson(jsonDecode(s))).toList();
      list.sort(
        (a, b) =>
            DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)),
      );
      return list;
    } catch (e) {
      log('[CallHistoryService] getHistory error: $e');
      return [];
    }
  }

  // ── Refresh all initiated calls ───────────────────────────────────────────

  static Future<void> refreshInitiatedCalls() async {
    try {
      final history = await getHistory();
      final initiated = history.where((c) => c.status == 'initiated');
      for (final call in initiated) {
        await fetchCallDetails(call.callId);
      }
      log(
        '[CallHistoryService] Refreshed ${initiated.length} initiated call(s)',
      );
    } catch (e) {
      log('[CallHistoryService] refreshInitiatedCalls error: $e');
    }
  }

  // ── Delete a single call ──────────────────────────────────────────────────

  static Future<bool> deleteCall(String callId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();
      final updated = history.where((c) => c.callId != callId).toList();

      if (updated.length == history.length) {
        log('[CallHistoryService] Call not found: $callId');
        return false;
      }

      await prefs.setStringList(
        _prefKey,
        updated.map((c) => jsonEncode(c.toJson())).toList(),
      );
      log('[CallHistoryService] Deleted call: $callId');
      return true;
    } catch (e) {
      log('[CallHistoryService] deleteCall error: $e');
      return false;
    }
  }

  // ── Clear all history ─────────────────────────────────────────────────────

  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_prefKey);
      log('[CallHistoryService] clearAll: $success');
      return success;
    } catch (e) {
      log('[CallHistoryService] clearAll error: $e');
      return false;
    }
  }

  // ── Save a new call (called externally when a call is initiated) ──────────

  static Future<void> saveNewCall(CallRecord record) async {
    await _upsertRecord(record);
    log('[CallHistoryService] Saved new call: ${record.callId}');
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static Future<void> _upsertRecord(CallRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getHistory();
      final idx = history.indexWhere((c) => c.callId == record.callId);
      if (idx != -1) {
        history[idx] = record;
      } else {
        history.add(record);
      }
      await prefs.setStringList(
        _prefKey,
        history.map((c) => jsonEncode(c.toJson())).toList(),
      );
    } catch (e) {
      log('[CallHistoryService] _upsertRecord error: $e');
    }
  }

  static Future<CallRecord?> _findInHistory(String callId) async {
    final history = await getHistory();
    try {
      return history.firstWhere((c) => c.callId == callId);
    } catch (_) {
      return null;
    }
  }
}
