import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../services/offline_sync_service.dart';

/// Interactive connectivity and synchronization indicator banner.
/// Shows online/offline status, pending changes count, and last sync timestamp.
class ConnectivityBanner extends StatefulWidget {
  final VoidCallback? onSyncTap;

  const ConnectivityBanner({
    super.key,
    this.onSyncTap,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  final OfflineSyncService _syncService = OfflineSyncService();

  @override
  void initState() {
    super.initState();
    _syncService.addListener(_onSyncUpdate);
  }

  @override
  void dispose() {
    _syncService.removeListener(_onSyncUpdate);
    super.dispose();
  }

  void _onSyncUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = _syncService.status;
    final queuedCount = _syncService.queuedOperationsCount;

    Color bg;
    Color border;
    Color fg;
    IconData icon;
    String title;
    String subtitle;

    switch (status) {
      case SyncConnectionStatus.online:
        if (queuedCount == 0) {
          // Subtle compact online state
          bg = isDark ? AppColors.surfaceDark : AppColors.primaryGreenSurface;
          border = AppColors.primaryGreen.withValues(alpha: 0.3);
          fg = isDark ? Colors.white : AppColors.primaryGreenDark;
          icon = Icons.cloud_done_rounded;
          title = isArabic ? 'متصل بالسحابة والعقد' : 'Online & Connected';
          subtitle = isArabic
              ? 'تمت مزامنة كافة قراءات وتعديلات المزرعة'
              : 'All farm data and telemetry synchronized';
        } else {
          bg = const Color(0xFFFEF3C7);
          border = const Color(0xFFF59E0B);
          fg = const Color(0xFF92400E);
          icon = Icons.sync_rounded;
          title = isArabic
              ? 'جارٍ معالجة التغييرات ($queuedCount)'
              : 'Processing Offline Queue ($queuedCount)';
          subtitle = isArabic
              ? 'يتم إرسال العمليات المحفوظة تدريجياً'
              : 'Syncing stored modifications with gateway';
        }
        break;

      case SyncConnectionStatus.offline:
        bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        border = const Color(0xFF64748B);
        fg = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
        icon = Icons.cloud_off_rounded;
        title = isArabic
            ? 'وضع عدم الاتصال (أوفلاين)'
            : 'Offline Operation Mode';
        subtitle = queuedCount > 0
            ? (isArabic
                ? 'يوجد $queuedCount عملية محفوظة بانتظار عودة الاتصال'
                : '$queuedCount changes saved locally, awaiting connection')
            : (isArabic
                ? 'يمكنك تصفح البيانات المخزنة محلياً بالكامل'
                : 'Browsing cached farm telemetry and nodes');
        break;

      case SyncConnectionStatus.syncing:
        bg = const Color(0xFFE0F2FE);
        border = AppColors.flowBlue;
        fg = const Color(0xFF0369A1);
        icon = Icons.sync_rounded;
        title = isArabic ? 'جارٍ المزامنة السحابية...' : 'Synchronizing Data...';
        subtitle = isArabic
            ? 'تحديث سجلات الاستشعار وأوامر الصمامات'
            : 'Pushing queued operations to server';
        break;

      case SyncConnectionStatus.syncError:
        bg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
        border = Colors.redAccent;
        fg = isDark ? Colors.white : const Color(0xFF991B1B);
        icon = Icons.error_outline_rounded;
        title = isArabic ? 'تعذر إتمام المزامنة' : 'Synchronization Failed';
        subtitle = _syncService.lastSyncError ??
            (isArabic
                ? 'فشل الاتصال بالخادم. اضغط لإعادة المحاولة'
                : 'Server connection timeout. Tap to retry');
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: fg, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: fg.withValues(alpha: 0.85),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Action button to retry sync or toggle connectivity for testing
          IconButton(
            tooltip: isArabic ? 'مزامنة فورية' : 'Sync Now',
            icon: Icon(
              status == SyncConnectionStatus.syncing
                  ? Icons.hourglass_top_rounded
                  : Icons.refresh_rounded,
              size: 20,
              color: fg,
            ),
            onPressed: () {
              if (widget.onSyncTap != null) {
                widget.onSyncTap!();
              } else {
                _syncService.synchronizePendingQueue();
              }
            },
          ),
        ],
      ),
    );
  }
}
