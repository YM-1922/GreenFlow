/// Solar Energy domain entities for Green Flow.
/// Represents solar panel telemetry, battery state, farm association, and historical metrics.
class SolarPanelEntity {
  final String farmId;
  final String farmName;
  final String farmNameAr;
  final double generationWatts; // current W
  final double peakWatts; // today peak W
  final double dailyKwh; // today kWh
  final double batteryPercent; // 0–100
  final double batteryVoltage; // volts
  final double pumpConsumptionWatts; // pump load W
  final double netBalanceWatts; // generation - consumption
  final bool isCharging;
  final String systemStatus; // 'Optimal', 'Normal', 'Warning'
  final double inverterTempCelsius;
  final String lastUpdated;
  final List<SolarHistoryPoint> hourlyHistory;
  final List<SolarDailyHistoryPoint> dailyHistory;
  final List<SolarAlertEntity> activeAlerts;

  const SolarPanelEntity({
    this.farmId = 'farm-001',
    this.farmName = 'Green Oasis Farm',
    this.farmNameAr = 'مزرعة الواحة الخضراء',
    required this.generationWatts,
    this.peakWatts = 1450.0,
    required this.dailyKwh,
    required this.batteryPercent,
    required this.batteryVoltage,
    required this.pumpConsumptionWatts,
    required this.netBalanceWatts,
    required this.isCharging,
    this.systemStatus = 'Optimal',
    this.inverterTempCelsius = 38.5,
    required this.lastUpdated,
    required this.hourlyHistory,
    this.dailyHistory = const [],
    this.activeAlerts = const [],
  });
}

class SolarHistoryPoint {
  final String hour; // e.g. "08:00"
  final double generationW;
  final double consumptionW;

  const SolarHistoryPoint({
    required this.hour,
    required this.generationW,
    required this.consumptionW,
  });
}

class SolarDailyHistoryPoint {
  final String dayNameEn;
  final String dayNameAr;
  final double generatedKwh;
  final double consumedKwh;

  const SolarDailyHistoryPoint({
    required this.dayNameEn,
    required this.dayNameAr,
    required this.generatedKwh,
    required this.consumedKwh,
  });
}

class SolarAlertEntity {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final String severity; // 'info', 'warning', 'critical'
  final String timestamp;

  const SolarAlertEntity({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.severity,
    required this.timestamp,
  });
}
