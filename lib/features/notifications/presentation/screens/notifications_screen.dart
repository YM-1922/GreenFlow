import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/datasources/notifications_mock_data_source.dart';
import '../../domain/entities/notification_entities.dart';

/// Notifications Screen – Phase 9.
/// Interactive notifications center with category filters, unread management,
/// details dialog, and individual / batch deletion.
class NotificationsScreen extends StatefulWidget {
  final NotificationsMockDataSource? dataSource;

  const NotificationsScreen({
    super.key,
    this.dataSource,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsMockDataSource _dataSource;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? NotificationsMockDataSource();
    _dataSource.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataSource.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _markAllRead() {
    _dataSource.markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text(
          AppStrings.isArabic(context)
              ? 'تم تحديد جميع الإشعارات كمقروءة'
              : 'All notifications marked as read',
        ),
      ),
    );
  }

  void _markRead(String id) {
    _dataSource.markAsRead(id);
  }

  void _deleteNotification(String id) {
    _dataSource.deleteNotification(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.cardDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text(
          AppStrings.isArabic(context)
              ? 'تم حذف الإشعار'
              : 'Notification deleted',
        ),
      ),
    );
  }

  void _showNotificationDetails(AppNotificationEntity notification, bool isAr) {
    _markRead(notification.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
        final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAr ? notification.category.labelAr() : notification.category.labelEn(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _deleteNotification(notification.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isAr ? notification.titleAr : notification.titleEn,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (notification.farmName != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      notification.farmName!,
                      style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Text(
                isAr ? notification.bodyAr : notification.bodyEn,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(isAr ? 'إغلاق' : 'Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<AppNotificationEntity> get _filteredNotifications {
    final list = _dataSource.getNotifications();
    switch (_selectedFilter) {
      case 'unread':
        return list.where((n) => !n.isRead).toList();
      case 'irrigation':
        return list.where((n) => n.category == NotificationCategory.irrigation).toList();
      case 'devices':
        return list.where((n) => n.category == NotificationCategory.devices).toList();
      case 'water':
        return list.where((n) => n.category == NotificationCategory.water).toList();
      case 'solar':
        return list.where((n) => n.category == NotificationCategory.solarEnergy).toList();
      case 'weather':
        return list.where((n) => n.category == NotificationCategory.weather).toList();
      case 'system':
        return list.where((n) => n.category == NotificationCategory.system).toList();
      case 'all':
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final filtered = _filteredNotifications;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.pureWhite,
        elevation: 0,
        title: Text(
          isAr ? 'مركز الإشعارات' : 'Notification Center',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: textPrimary),
        actions: [
          if (_dataSource.unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: Text(
                isAr ? 'قراءة الكل' : 'Mark all read',
                style: const TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.pureWhite,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip(isAr ? 'الكل' : 'All', 'all', textPrimary),
                  const SizedBox(width: 8),
                  _filterChip(
                    '${isAr ? 'غير مقروء' : 'Unread'} (${_dataSource.unreadCount})',
                    'unread',
                    textPrimary,
                  ),
                  const SizedBox(width: 8),
                  _filterChip(isAr ? 'الري' : 'Irrigation', 'irrigation', textPrimary),
                  const SizedBox(width: 8),
                  _filterChip(isAr ? 'الأجهزة' : 'Devices', 'devices', textPrimary),
                  const SizedBox(width: 8),
                  _filterChip(isAr ? 'المياه' : 'Water', 'water', textPrimary),
                  const SizedBox(width: 8),
                  _filterChip(isAr ? 'الطاقة الشمسية' : 'Solar', 'solar', textPrimary),
                  const SizedBox(width: 8),
                  _filterChip(isAr ? 'الطقس' : 'Weather', 'weather', textPrimary),
                  const SizedBox(width: 8),
                  _filterChip(isAr ? 'النظام' : 'System', 'system', textPrimary),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Notifications List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isAr, textSecondary)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notif = filtered[index];
                      return Dismissible(
                        key: Key('notif_${notif.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteNotification(notif.id),
                        child: _NotificationCard(
                          notification: notif,
                          isAr: isAr,
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () => _showNotificationDetails(notif, isAr),
                          onDelete: () => _deleteNotification(notif.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String filterKey, Color textColor) {
    final isSelected = _selectedFilter == filterKey;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = filterKey),
      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryGreen : textColor,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
      ),
      backgroundColor: Colors.transparent,
      showCheckmark: false,
    );
  }

  Widget _buildEmptyState(bool isAr, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 54, color: textSecondary),
          const SizedBox(height: 12),
          Text(
            isAr ? 'لا توجد إشعارات في هذا التصنيف' : 'No notifications in this category',
            style: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotificationEntity notification;
  final bool isAr;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.isAr,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
    required this.onDelete,
  });

  Color get _borderColor {
    switch (notification.severity) {
      case NotificationSeverity.critical:
        return Colors.red;
      case NotificationSeverity.warning:
        return Colors.amber.shade700;
      case NotificationSeverity.info:
        return AppColors.flowBlue;
      case NotificationSeverity.success:
        return AppColors.primaryGreen;
    }
  }

  String _relativeTime(BuildContext context) {
    final diff = DateTime.now().difference(notification.timestamp);
    if (diff.inMinutes < 60) {
      return isAr ? 'منذ ${diff.inMinutes} د' : '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return isAr ? 'منذ ${diff.inHours} س' : '${diff.inHours}h ago';
    } else {
      return isAr ? 'منذ ${diff.inDays} ي' : '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                : _borderColor.withValues(alpha: 0.6),
            width: notification.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator Dot or Icon
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: notification.isRead ? Colors.transparent : _borderColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: notification.isRead ? Colors.grey.shade400 : _borderColor,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isAr ? notification.titleAr : notification.titleEn,
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          _relativeTime(context),
                          style: TextStyle(color: textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAr ? notification.bodyAr : notification.bodyEn,
                      style: TextStyle(color: textSecondary, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isAr ? notification.category.labelAr() : notification.category.labelEn(),
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (notification.farmName != null)
                          Text(
                            '📍 ${notification.farmName}',
                            style: TextStyle(fontSize: 10, color: textSecondary),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, size: 16, color: textSecondary),
                onPressed: onDelete,
                tooltip: isAr ? 'حذف' : 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
