import 'package:flutter/foundation.dart';
import '../../domain/entities/notification_entities.dart';

/// Local mock data source and state manager for Green Flow Notifications.
/// Operates as a reactive singleton notifying UI widgets on state changes.
class NotificationsMockDataSource extends ChangeNotifier {
  static final NotificationsMockDataSource _instance = NotificationsMockDataSource._internal();
  factory NotificationsMockDataSource() => _instance;

  NotificationsMockDataSource._internal() {
    _initDemoNotifications();
  }

  late List<AppNotificationEntity> _notifications;

  List<AppNotificationEntity> getNotifications() => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _initDemoNotifications() {
    final now = DateTime.now();
    _notifications = [
      AppNotificationEntity(
        id: 'notif-001',
        titleEn: '🚨 E-Stop Triggered',
        titleAr: '🚨 إيقاف اضطراري للمضخة',
        bodyEn: 'Emergency stop activated on Pump Station A in Hope Farm. Manual inspection required.',
        bodyAr: 'تم تفعيل الإيقاف الاضطراري على محطة ضخ أ بمزرعة الأمل. مطلوب معاينة يدوية.',
        severity: NotificationSeverity.critical,
        category: NotificationCategory.irrigation,
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        farmName: 'Hope Olive & Palm Farm',
      ),
      AppNotificationEntity(
        id: 'notif-002',
        titleEn: '🔋 Low Battery Warning',
        titleAr: '🔋 تنبيه انخفاض البطارية',
        bodyEn: 'Solar battery reserve in Nile Valley dropped below 20%. Drip schedules paused.',
        bodyAr: 'احتياطي بطارية الطاقة الشمسية في وادي النيل انخفض عن 20%. تم تعليق الري بالتنقيط.',
        severity: NotificationSeverity.warning,
        category: NotificationCategory.solarEnergy,
        timestamp: now.subtract(const Duration(minutes: 42)),
        isRead: false,
        farmName: 'Nile Valley Citrus Farm',
      ),
      AppNotificationEntity(
        id: 'notif-003',
        titleEn: '💧 Water Flow Meter Alert',
        titleAr: '💧 تنبيه استهلاك المياه',
        bodyEn: 'Daily water consumption reached 92% of target limit (480 L delivered today).',
        bodyAr: 'استهلاك المياه اليومي وصل إلى 92% من الحد المسموح (تم ضخ 480 لتر اليوم).',
        severity: NotificationSeverity.warning,
        category: NotificationCategory.water,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 20)),
        isRead: false,
        farmName: 'Fayrouz Organic Estate',
      ),
      AppNotificationEntity(
        id: 'notif-004',
        titleEn: '📡 Soil Sensor Node Offline',
        titleAr: '📡 انقطاع مستشعر التربة',
        bodyEn: 'LoRa node GF-LORA-003 has not reported moisture readings for 35 minutes.',
        bodyAr: 'عقدة لورا GF-LORA-003 لم ترسل قراءات الرطوبة منذ أكثر من 35 دقيقة.',
        severity: NotificationSeverity.critical,
        category: NotificationCategory.devices,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 10)),
        isRead: false,
        farmName: 'Hope Olive & Palm Farm',
      ),
      AppNotificationEntity(
        id: 'notif-005',
        titleEn: '✅ Zone A Irrigation Complete',
        titleAr: '✅ اكتمل ري القطاع الشرقي',
        bodyEn: 'Automated 45-minute olive irrigation cycle completed. 340 L consumed.',
        bodyAr: 'اكتملت دورة ري قطاع الزيتون الشرقي الآلية لمدة 45 دقيقة. استهلاك 340 لتر.',
        severity: NotificationSeverity.success,
        category: NotificationCategory.irrigation,
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
        farmName: 'Hope Olive & Palm Farm',
      ),
      AppNotificationEntity(
        id: 'notif-006',
        titleEn: '🌡 High Heatwave Forecast',
        titleAr: '🌡 موجة حر قادمة',
        bodyEn: 'Ambient temperature expected to exceed 41°C tomorrow. Pre-irrigation advised.',
        bodyAr: 'درجة حرارة الجو المتوقعة غداً تتجاوز 41°م. يُنصح بالري الوقائي قبل الظهيرة.',
        severity: NotificationSeverity.info,
        category: NotificationCategory.weather,
        timestamp: now.subtract(const Duration(hours: 4, minutes: 30)),
        isRead: true,
        farmName: 'Nile Valley Citrus Farm',
      ),
      AppNotificationEntity(
        id: 'notif-007',
        titleEn: '☀️ Solar Generation Record',
        titleAr: '☀️ ذروة إنتاج الطاقة الشمسية',
        bodyEn: 'Array output reached 1,840W peak today. Net surplus feeding grid backup.',
        bodyAr: 'إنتاج المنظومة الشمسية حقق ذروة 1,840 واط اليوم مع فائض يغذي البطاريات.',
        severity: NotificationSeverity.success,
        category: NotificationCategory.solarEnergy,
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        farmName: 'Nile Valley Citrus Farm',
      ),
      AppNotificationEntity(
        id: 'notif-008',
        titleEn: '⚙️ Gateway Firmware Update',
        titleAr: '⚙️ تحديث برامج البوابة متاح',
        bodyEn: 'ESP32 Firmware v2.4.1 available for download with improved LoRa stability.',
        bodyAr: 'تحديث فيرموير ESP32 رقم v2.4.1 متوفر الآن لتحسين استقرار شبكة LoRa.',
        severity: NotificationSeverity.info,
        category: NotificationCategory.system,
        timestamp: now.subtract(const Duration(hours: 6)),
        isRead: true,
        farmName: null,
      ),
    ];
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void deleteNotification(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  void resetDemoData() {
    _initDemoNotifications();
    notifyListeners();
  }
}
