import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/call_history_service.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/styles.dart';
import 'call_details_page.dart';

class RecentActivityPage extends StatefulWidget {
  const RecentActivityPage({super.key});

  @override
  State<RecentActivityPage> createState() => _RecentActivityPageState();
}

class _RecentActivityPageState extends State<RecentActivityPage> {
  List<CallRecord> _callHistory = [];
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadCallHistory();
  }

  Future<void> _loadCallHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await CallHistoryService.getHistory();
      setState(() {
        _callHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to load call history', isError: true);
    }
  }

  Future<void> _refreshCallHistory() async {
    setState(() => _isLoading = true);
    try {
      await CallHistoryService.refreshInitiatedCalls();
      final history = await CallHistoryService.getHistory();
      setState(() {
        _callHistory = history;
        _isLoading = false;
      });
      _showSnackBar('Activity refreshed');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to refresh', isError: true);
    }
  }

  Future<void> _deleteCall(String callId) async {
    setState(() => _isDeleting = true);
    try {
      final success = await CallHistoryService.deleteCall(callId);
      if (success) {
        await _loadCallHistory();
        _showSnackBar('Call deleted');
      } else {
        _showSnackBar('Failed to delete', isError: true);
      }
    } catch (e) {
      _showSnackBar('An error occurred', isError: true);
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  Future<bool> _confirmDelete(String callId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.whiteOverlay10),
        ),
        title: Text(
          'Delete Call',
          style: AppStyles.heading3.copyWith(fontSize: 18),
        ),
        content: Text(
          'Remove this call from your history? This cannot be undone.',
          style: AppStyles.bodySmall.copyWith(color: AppColors.textWhite60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppStyles.bodySmall.copyWith(color: AppColors.textWhite60),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: AppStyles.bodySmall.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
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
            Text(message, style: AppStyles.bodySmall),
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

  String _formatDate(String isoString) {
    try {
      DateTime dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return 'Today, ${DateFormat('hh:mm a').format(dt)}';
      } else if (dt.year == yesterday.year &&
          dt.month == yesterday.month &&
          dt.day == yesterday.day) {
        return 'Yesterday, ${DateFormat('hh:mm a').format(dt)}';
      } else {
        return DateFormat('MMM dd, hh:mm a').format(dt);
      }
    } catch (_) {
      return 'Unknown date';
    }
  }

  String _truncate(String text, int max) =>
      text.length <= max ? text : '${text.substring(0, max)}...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text(
          'Call History',
          style: AppStyles.heading3.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textWhite),
            onPressed: _isLoading ? null : _refreshCallHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshCallHistory,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceDark,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _callHistory.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _callHistory.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _buildCallItem(_callHistory[i]),
                  ),
          ),
          if (_isDeleting)
            Container(
              color: AppColors.backgroundDark.withAlpha(180),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.whiteOverlay10),
            ),
            child: Icon(Icons.history, size: 36, color: AppColors.textWhite60),
          ),
          const SizedBox(height: 20),
          Text(
            'No call history yet',
            style: AppStyles.heading3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Your voice calls will appear here',
            style: AppStyles.bodySmall.copyWith(color: AppColors.textWhite60),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _refreshCallHistory,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryOverlay20,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withAlpha(80)),
              ),
              child: Text(
                'Refresh',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallItem(CallRecord call) {
    final phone = call.phoneNumber.replaceAll(RegExp(r'\+91'), '');
    final isCompleted = call.status == 'completed';
    final isInitiated = call.status == 'initiated';

    final statusColor = isCompleted
        ? AppColors.primary
        : isInitiated
        ? Colors.orangeAccent
        : Colors.redAccent;

    final statusIcon = isCompleted
        ? Icons.phone
        : isInitiated
        ? Icons.phone_forwarded
        : Icons.phone_missed;

    return Dismissible(
      key: Key(call.callId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(call.callId),
      onDismissed: (_) => _deleteCall(call.callId),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent.withAlpha(40),
          borderRadius: AppStyles.radiusXLarge,
          border: Border.all(color: Colors.redAccent.withAlpha(80)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: AppStyles.bodySmall.copyWith(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CallDetailsPage(call: call)),
          ).then((_) => _loadCallHistory());
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: AppStyles.radiusXLarge,
            border: Border.all(color: AppColors.whiteOverlay5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '+91 $phone',
                          style: AppStyles.bodyMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isCompleted
                                ? 'Completed'
                                : isInitiated
                                ? 'Pending'
                                : 'Failed',
                            style: AppStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Date & Duration row
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textWhite60,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(call.createdAt),
                          style: AppStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textWhite60,
                          ),
                        ),
                        if (call.callLength > 0) ...[
                          Text(
                            '  •  ',
                            style: AppStyles.bodySmall.copyWith(
                              color: AppColors.textWhite60,
                            ),
                          ),
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: AppColors.textWhite60,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${call.callLength.toStringAsFixed(1)} min',
                            style: AppStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: AppColors.textWhite60,
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Summary
                    if (call.summary.isNotEmpty &&
                        call.summary != 'No summary available' &&
                        call.summary != 'Call initiated') ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.whiteOverlay5,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _truncate(call.summary, 80),
                          style: AppStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textWhite80,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
