/// Notifications domain entities for Green Flow – Phase 9.
enum NotificationSeverity { critical, warning, info, success }

enum NotificationCategory {
  irrigation,
  devices,
  water,
  solarEnergy,
  weather,
  system,
}

extension NotificationCategoryExtension on NotificationCategory {
  String labelEn() {
    switch (this) {
      case NotificationCategory.irrigation:
        return 'Irrigation';
      case NotificationCategory.devices:
        return 'Devices';
      case NotificationCategory.water:
        return 'Water';
      case NotificationCategory.solarEnergy:
        return 'Solar Energy';
      case NotificationCategory.weather:
        return 'Weather';
      case NotificationCategory.system:
        return 'System';
    }
  }

  String labelAr() {
    switch (this) {
      case NotificationCategory.irrigation:
        return 'الري';
      case NotificationCategory.devices:
        return 'الأجهزة';
      case NotificationCategory.water:
        return 'المياه';
      case NotificationCategory.solarEnergy:
        return 'الطاقة الشمسية';
      case NotificationCategory.weather:
        return 'الطقس';
      case NotificationCategory.system:
        return 'النظام';
    }
  }
}

class AppNotificationEntity {
  final String id;
  final String titleEn;
  final String titleAr;
  final String bodyEn;
  final String bodyAr;
  final NotificationSeverity severity;
  final NotificationCategory category;
  final DateTime timestamp;
  final bool isRead;
  final String? farmName;

  const AppNotificationEntity({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.severity,
    this.category = NotificationCategory.system,
    required this.timestamp,
    required this.isRead,
    this.farmName,
  });

  AppNotificationEntity copyWith({
    bool? isRead,
    NotificationCategory? category,
  }) {
    return AppNotificationEntity(
      id: id,
      titleEn: titleEn,
      titleAr: titleAr,
      bodyEn: bodyEn,
      bodyAr: bodyAr,
      severity: severity,
      category: category ?? this.category,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      farmName: farmName,
    );
  }
}
