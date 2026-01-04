import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:mindmate_ai/core/utils/constants.dart';

class CallService {
  static const String _baseUrl = AppSecrets.blandBaseUrl;
  static const String _apiKey = AppSecrets.blandApiKey;
  // Call state management
  final ValueNotifier<CallState> callState = ValueNotifier(CallState.idle);
  final ValueNotifier<Duration> callDuration = ValueNotifier(Duration.zero);
  final ValueNotifier<bool> isMuted = ValueNotifier(false);
  final ValueNotifier<bool> isSpeakerOn = ValueNotifier(true);

  Timer? _durationTimer;
  String? _currentCallId;

  // Singleton pattern
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  /// Start a new phone call with Bland AI
  Future<bool> startCall({required String phoneNumber}) async {
    try {
      callState.value = CallState.connecting;

      if (kDebugMode) {
        print('Initiating phone call to: $phoneNumber');
      }

      final payload = {
        "phone_number": phoneNumber,
        "task":
            "You are MindMate, a compassionate and supportive AI companion for teens. "
            "Your main objective is to provide emotional support and listen to what the teen wants to share. "
            "Create a safe, non-judgmental space where they feel comfortable opening up. "
            "Listen actively, validate their feelings, and offer supportive responses. "
            "If they're going through something difficult, acknowledge their emotions and help them feel heard.",
        "first_sentence":
            "Hey there! This is MindMate. I'm here to listen. "
            "How are you doing today? Feel free to share what's on your mind.",
        "wait_for_greeting": true,
        "model": "enhanced",
        "voice": "maya", // Young, friendly voice
        "record": true,
        "language": "eng",
        "answered_by_enabled": true,
        "temperature": 0.7, // Slightly creative but consistent
        "max_duration": 30, // 30 minutes max call duration
      };

      if (kDebugMode) {
        print('Call payload: ${json.encode(payload)}');
      }

      final headers = {
        "authorization": _apiKey,
        "Content-Type": "application/json",
      };

      // Make API call to Bland AI
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: json.encode(payload),
      );

      if (kDebugMode) {
        print('Call response status code: ${response.statusCode}');
      }

      final responseJson = json.decode(response.body);

      if (response.statusCode == 200) {
        _currentCallId = responseJson['call_id'];

        if (kDebugMode) {
          print('Call successfully initiated');
          print('Call ID: $_currentCallId');
          print('Response: $responseJson');
        }

        callState.value = CallState.connected;
        _startDurationTimer();

        return true;
      } else {
        if (kDebugMode) {
          print('Failed to start call. Status: ${response.statusCode}');
          print('Error response: $responseJson');
        }
        callState.value = CallState.error;
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting call: $e');
      }
      callState.value = CallState.error;
      return false;
    }
  }

  /// Get call details from Bland AI
  Future<CallDetails?> getCallDetails() async {
    if (_currentCallId == null) return null;

    try {
      final headers = {
        "authorization": _apiKey,
        "Content-Type": "application/json",
      };

      final response = await http.get(
        Uri.parse('$_baseUrl/$_currentCallId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);

        if (kDebugMode) {
          print('Call details retrieved: $responseJson');
        }

        return CallDetails.fromJson(responseJson);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting call details: $e');
      }
    }
    return null;
  }

  /// End the current call
  Future<void> endCall() async {
    try {
      if (_currentCallId != null) {
        // Bland AI doesn't have a direct end call endpoint
        // The call will end naturally or we can just clean up locally
        if (kDebugMode) {
          print('Ending call: $_currentCallId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error ending call: $e');
      }
    } finally {
      _cleanup();
    }
  }

  /// Toggle mute state
  void toggleMute() {
    isMuted.value = !isMuted.value;
    if (kDebugMode) {
      print('Mute toggled: ${isMuted.value}');
    }
  }

  /// Toggle speaker state
  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    if (kDebugMode) {
      print('Speaker toggled: ${isSpeakerOn.value}');
    }
  }

  /// Start the call duration timer
  void _startDurationTimer() {
    callDuration.value = Duration.zero;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDuration.value = Duration(seconds: callDuration.value.inSeconds + 1);
    });
  }

  /// Cleanup resources
  void _cleanup() {
    _durationTimer?.cancel();
    _durationTimer = null;
    _currentCallId = null;
    callDuration.value = Duration.zero;
    callState.value = CallState.idle;
    isMuted.value = false;
    isSpeakerOn.value = true;
  }

  /// Dispose resources
  void dispose() {
    _cleanup();
    callState.dispose();
    callDuration.dispose();
    isMuted.dispose();
    isSpeakerOn.dispose();
  }
}

// Call details model
class CallDetails {
  final String callId;
  final double callLength;
  final String phoneNumber;
  final String createdAt;
  final String summary;
  final String status;

  CallDetails({
    required this.callId,
    required this.callLength,
    required this.phoneNumber,
    required this.createdAt,
    required this.summary,
    required this.status,
  });

  factory CallDetails.fromJson(Map<String, dynamic> json) {
    double callLength = 0.0;
    if (json['call_length'] != null) {
      if (json['call_length'] is num) {
        callLength = (json['call_length'] as num).toDouble();
      } else if (json['call_length'] is String) {
        try {
          callLength = double.parse(json['call_length'] as String);
        } catch (e) {
          // Keep default
        }
      }
    }

    String createdAt =
        json['created_at'] ??
        json['createdAt'] ??
        DateTime.now().toIso8601String();

    return CallDetails(
      callId: json['call_id'] ?? '',
      callLength: callLength,
      phoneNumber: json['to'] ?? json['phoneNumber'] ?? '',
      createdAt: createdAt,
      summary: json['summary'] ?? 'No summary available',
      status: json['status'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'call_id': callId,
      'call_length': callLength,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'summary': summary,
      'status': status,
    };
  }
}

enum CallState { idle, connecting, connected, disconnected, error }
