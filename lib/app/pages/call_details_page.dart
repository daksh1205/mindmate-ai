import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/services/call_history_service.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/styles.dart';

class CallDetailsPage extends StatefulWidget {
  final CallRecord call;

  const CallDetailsPage({super.key, required this.call});

  @override
  State<CallDetailsPage> createState() => _CallDetailsPageState();
}

class _CallDetailsPageState extends State<CallDetailsPage> {
  late CallRecord _call;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _call = widget.call;
    // Auto-refresh if still pending
    if (_call.status == 'initiated') _refresh();
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final updated = await CallHistoryService.fetchCallDetails(_call.callId);
      if (updated != null) setState(() => _call = updated);
    } catch (_) {
      _showSnackBar('Failed to refresh call details', isError: true);
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: AppColors.textWhite,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(msg, style: AppStyles.bodySmall),
          ],
        ),
        backgroundColor: isError
            ? Colors.redAccent.withAlpha(220)
            : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Today, ${DateFormat('hh:mm a').format(dt)}';
      } else if (dt.year == yesterday.year &&
          dt.month == yesterday.month &&
          dt.day == yesterday.day) {
        return 'Yesterday, ${DateFormat('hh:mm a').format(dt)}';
      }
      return DateFormat('MMM dd yyyy, hh:mm a').format(dt);
    } catch (_) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = _call.phoneNumber.replaceAll(RegExp(r'\+91'), '');
    final isCompleted = _call.status == 'completed';
    final isInitiated = _call.status == 'initiated';
    final statusColor = isCompleted
        ? AppColors.primary
        : isInitiated
        ? Colors.orangeAccent
        : Colors.redAccent;
    final statusLabel = isCompleted
        ? 'Completed'
        : isInitiated
        ? 'Pending'
        : 'Failed';
    final hasSummary =
        _call.summary.isNotEmpty &&
        _call.summary != 'No summary available' &&
        _call.summary != 'Call initiated';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textWhite,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Call Details',
          style: AppStyles.heading3.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.refresh, color: AppColors.textWhite),
            onPressed: _isRefreshing ? null : _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero card ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: AppStyles.radiusXLarge,
                border: Border.all(color: AppColors.whiteOverlay5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.phone
                          : isInitiated
                          ? Icons.phone_forwarded
                          : Icons.phone_missed,
                      color: statusColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+91 $phone',
                          style: AppStyles.heading3.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(_call.createdAt),
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textWhite60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withAlpha(80)),
                    ),
                    child: Text(
                      statusLabel,
                      style: AppStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Info card ──────────────────────────────────────────────────
            _SectionCard(
              title: 'Call Information',
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.tag,
                    label: 'Call ID',
                    value: _call.callId,
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: _call.callId));
                      _showSnackBar('Call ID copied');
                    },
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Number',
                    value: '+91 $phone',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: _call.callLength > 0
                        ? '${_call.callLength.toStringAsFixed(1)} minutes'
                        : 'Not available',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: _formatDate(_call.createdAt),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Summary card ───────────────────────────────────────────────
            if (hasSummary)
              _SectionCard(
                title: 'Call Summary',
                child: Text(
                  _call.summary,
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textWhite80,
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),
              )
            else
              _SectionCard(
                title: 'Call Summary',
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textWhite60,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isInitiated
                          ? 'Summary will appear once the call completes'
                          : 'No summary available for this call',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textWhite60,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ── Refresh CTA for pending calls ──────────────────────────────
            if (isInitiated)
              GestureDetector(
                onTap: _isRefreshing ? null : _refresh,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOverlay20,
                    borderRadius: AppStyles.radiusXLarge,
                    border: Border.all(color: AppColors.primary.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isRefreshing
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Icon(
                              Icons.refresh,
                              color: AppColors.primary,
                              size: 20,
                            ),
                      const SizedBox(width: 10),
                      Text(
                        _isRefreshing ? 'Refreshing...' : 'Check for Updates',
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable sub-widgets ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppStyles.radiusXLarge,
        border: Border.all(color: AppColors.whiteOverlay5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.heading3.copyWith(
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textWhite60),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppStyles.bodySmall.copyWith(color: AppColors.textWhite60),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: Icon(
                Icons.copy_outlined,
                size: 16,
                color: AppColors.textWhite60,
              ),
            ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: AppColors.whiteOverlay5, height: 1);
  }
}
