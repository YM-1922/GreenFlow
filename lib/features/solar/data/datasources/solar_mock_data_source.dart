import '../../domain/entities/solar_entities.dart';

/// Local mock data source for Solar Energy feature.
/// Returns realistic demo solar telemetry – no real hardware required.
class SolarMockDataSource {
  const SolarMockDataSource();

  List<Map<String, String>> getAvailableFarms() {
    return const [
      {
        'id': 'farm-001',
        'nameEn': 'Hope Olive & Palm Farm',
        'nameAr': 'مزرعة الأمل للزيتون والنخيل',
      },
      {
        'id': 'farm-002',
        'nameEn': 'Nile Valley Citrus Farm',
        'nameAr': 'مزرعة وادي النيل للطماطم والموالح',
      },
      {
        'id': 'farm-003',
        'nameEn': 'Fayrouz Organic Estate',
        'nameAr': 'مزرعة الفيروز العضوية',
      },
    ];
  }

  SolarPanelEntity getSolarData([String? farmId]) {
    final selectedId = farmId ?? 'farm-001';

    if (selectedId == 'farm-002') {
      return const SolarPanelEntity(
        farmId: 'farm-002',
        farmName: 'Nile Valley Citrus Farm',
        farmNameAr: 'مزرعة وادي النيل للطماطم والموالح',
        generationWatts: 1840.0,
        peakWatts: 2100.0,
        dailyKwh: 12.8,
        batteryPercent: 92.0,
        batteryVoltage: 51.2,
        pumpConsumptionWatts: 1200.0,
        netBalanceWatts: 640.0,
        isCharging: true,
        systemStatus: 'Optimal',
        inverterTempCelsius: 41.2,
        lastUpdated: '14:35',
        hourlyHistory: [
          SolarHistoryPoint(hour: '06:00', generationW: 110.0, consumptionW: 600.0),
          SolarHistoryPoint(hour: '07:00', generationW: 450.0, consumptionW: 600.0),
          SolarHistoryPoint(hour: '08:00', generationW: 890.0, consumptionW: 1200.0),
          SolarHistoryPoint(hour: '09:00', generationW: 1350.0, consumptionW: 1200.0),
          SolarHistoryPoint(hour: '10:00', generationW: 1680.0, consumptionW: 1200.0),
          SolarHistoryPoint(hour: '11:00', generationW: 1820.0, consumptionW: 1200.0),
          SolarHistoryPoint(hour: '12:00', generationW: 1910.0, consumptionW: 1200.0),
          SolarHistoryPoint(hour: '13:00', generationW: 1870.0, consumptionW: 1200.0),
          SolarHistoryPoint(hour: '14:00', generationW: 1840.0, consumptionW: 1200.0),
          SolarHistoryPoint(hour: '15:00', generationW: 1420.0, consumptionW: 1200.0),
          SolarHistoryPoint(hour: '16:00', generationW: 880.0, consumptionW: 600.0),
          SolarHistoryPoint(hour: '17:00', generationW: 390.0, consumptionW: 600.0),
        ],
        dailyHistory: [
          SolarDailyHistoryPoint(dayNameEn: 'Mon', dayNameAr: 'الإثنين', generatedKwh: 14.2, consumedKwh: 11.5),
          SolarDailyHistoryPoint(dayNameEn: 'Tue', dayNameAr: 'الثلاثاء', generatedKwh: 15.1, consumedKwh: 12.0),
          SolarDailyHistoryPoint(dayNameEn: 'Wed', dayNameAr: 'الأربعاء', generatedKwh: 13.8, consumedKwh: 11.8),
          SolarDailyHistoryPoint(dayNameEn: 'Thu', dayNameAr: 'الخميس', generatedKwh: 14.9, consumedKwh: 12.2),
          SolarDailyHistoryPoint(dayNameEn: 'Fri', dayNameAr: 'الجمعة', generatedKwh: 16.0, consumedKwh: 11.0),
          SolarDailyHistoryPoint(dayNameEn: 'Sat', dayNameAr: 'السبت', generatedKwh: 15.5, consumedKwh: 12.5),
          SolarDailyHistoryPoint(dayNameEn: 'Sun', dayNameAr: 'الأحد', generatedKwh: 12.8, consumedKwh: 9.8),
        ],
        activeAlerts: [
          SolarAlertEntity(
            id: 'alt-sol-201',
            titleEn: 'Inverter Operating Near Peak Load',
            titleAr: 'المحول يعمل بالقرب من الحمل الأقصى',
            descriptionEn: 'Pump load is stable with 640W net surplus feeding battery reserve.',
            descriptionAr: 'حمل المضخة مستقر مع فائض 640 واط يغذي احتياطي البطارية.',
            severity: 'info',
            timestamp: '13:45',
          ),
        ],
      );
    } else if (selectedId == 'farm-003') {
      return const SolarPanelEntity(
        farmId: 'farm-003',
        farmName: 'Fayrouz Organic Estate',
        farmNameAr: 'مزرعة الفيروز العضوية',
        generationWatts: 720.0,
        peakWatts: 1100.0,
        dailyKwh: 5.6,
        batteryPercent: 44.0,
        batteryVoltage: 46.8,
        pumpConsumptionWatts: 800.0,
        netBalanceWatts: -80.0,
        isCharging: false,
        systemStatus: 'Warning',
        inverterTempCelsius: 36.0,
        lastUpdated: '14:30',
        hourlyHistory: [
          SolarHistoryPoint(hour: '06:00', generationW: 40.0, consumptionW: 300.0),
          SolarHistoryPoint(hour: '07:00', generationW: 190.0, consumptionW: 300.0),
          SolarHistoryPoint(hour: '08:00', generationW: 380.0, consumptionW: 800.0),
          SolarHistoryPoint(hour: '09:00', generationW: 550.0, consumptionW: 800.0),
          SolarHistoryPoint(hour: '10:00', generationW: 710.0, consumptionW: 800.0),
          SolarHistoryPoint(hour: '11:00', generationW: 800.0, consumptionW: 800.0),
          SolarHistoryPoint(hour: '12:00', generationW: 840.0, consumptionW: 800.0),
          SolarHistoryPoint(hour: '13:00', generationW: 790.0, consumptionW: 800.0),
          SolarHistoryPoint(hour: '14:00', generationW: 720.0, consumptionW: 800.0),
          SolarHistoryPoint(hour: '15:00', generationW: 590.0, consumptionW: 800.0),
          SolarHistoryPoint(hour: '16:00', generationW: 380.0, consumptionW: 300.0),
          SolarHistoryPoint(hour: '17:00', generationW: 140.0, consumptionW: 300.0),
        ],
        dailyHistory: [
          SolarDailyHistoryPoint(dayNameEn: 'Mon', dayNameAr: 'الإثنين', generatedKwh: 8.2, consumedKwh: 7.9),
          SolarDailyHistoryPoint(dayNameEn: 'Tue', dayNameAr: 'الثلاثاء', generatedKwh: 7.8, consumedKwh: 8.0),
          SolarDailyHistoryPoint(dayNameEn: 'Wed', dayNameAr: 'الأربعاء', generatedKwh: 8.5, consumedKwh: 7.5),
          SolarDailyHistoryPoint(dayNameEn: 'Thu', dayNameAr: 'الخميس', generatedKwh: 6.9, consumedKwh: 8.1),
          SolarDailyHistoryPoint(dayNameEn: 'Fri', dayNameAr: 'الجمعة', generatedKwh: 9.0, consumedKwh: 7.8),
          SolarDailyHistoryPoint(dayNameEn: 'Sat', dayNameAr: 'السبت', generatedKwh: 8.1, consumedKwh: 8.3),
          SolarDailyHistoryPoint(dayNameEn: 'Sun', dayNameAr: 'الأحد', generatedKwh: 5.6, consumedKwh: 6.2),
        ],
        activeAlerts: [
          SolarAlertEntity(
            id: 'alt-sol-301',
            titleEn: 'Discharging from Battery Reserve',
            titleAr: 'تفريغ من احتياطي البطارية',
            descriptionEn: 'Pump consumption (800W) exceeds solar array output (720W).',
            descriptionAr: 'استهلاك المضخة (800 واط) يتجاوز إنتاج الألواح الشمسية (720 واط).',
            severity: 'warning',
            timestamp: '14:10',
          ),
        ],
      );
    }

    // Default farm-001
    return const SolarPanelEntity(
      farmId: 'farm-001',
      farmName: 'Hope Olive & Palm Farm',
      farmNameAr: 'مزرعة الأمل للزيتون والنخيل',
      generationWatts: 1250.0,
      peakWatts: 1480.0,
      dailyKwh: 8.4,
      batteryPercent: 78.0,
      batteryVoltage: 48.6,
      pumpConsumptionWatts: 850.0,
      netBalanceWatts: 400.0,
      isCharging: true,
      systemStatus: 'Optimal',
      inverterTempCelsius: 38.5,
      lastUpdated: '14:32',
      hourlyHistory: [
        SolarHistoryPoint(hour: '06:00', generationW: 85.0, consumptionW: 420.0),
        SolarHistoryPoint(hour: '07:00', generationW: 320.0, consumptionW: 430.0),
        SolarHistoryPoint(hour: '08:00', generationW: 580.0, consumptionW: 850.0),
        SolarHistoryPoint(hour: '09:00', generationW: 820.0, consumptionW: 850.0),
        SolarHistoryPoint(hour: '10:00', generationW: 1050.0, consumptionW: 850.0),
        SolarHistoryPoint(hour: '11:00', generationW: 1180.0, consumptionW: 850.0),
        SolarHistoryPoint(hour: '12:00', generationW: 1250.0, consumptionW: 850.0),
        SolarHistoryPoint(hour: '13:00', generationW: 1210.0, consumptionW: 850.0),
        SolarHistoryPoint(hour: '14:00', generationW: 1100.0, consumptionW: 850.0),
        SolarHistoryPoint(hour: '15:00', generationW: 920.0, consumptionW: 850.0),
        SolarHistoryPoint(hour: '16:00', generationW: 640.0, consumptionW: 430.0),
        SolarHistoryPoint(hour: '17:00', generationW: 280.0, consumptionW: 420.0),
      ],
      dailyHistory: [
        SolarDailyHistoryPoint(dayNameEn: 'Mon', dayNameAr: 'الإثنين', generatedKwh: 9.8, consumedKwh: 6.8),
        SolarDailyHistoryPoint(dayNameEn: 'Tue', dayNameAr: 'الثلاثاء', generatedKwh: 10.4, consumedKwh: 7.2),
        SolarDailyHistoryPoint(dayNameEn: 'Wed', dayNameAr: 'الأربعاء', generatedKwh: 10.1, consumedKwh: 7.0),
        SolarDailyHistoryPoint(dayNameEn: 'Thu', dayNameAr: 'الخميس', generatedKwh: 9.5, consumedKwh: 6.9),
        SolarDailyHistoryPoint(dayNameEn: 'Fri', dayNameAr: 'الجمعة', generatedKwh: 11.2, consumedKwh: 7.5),
        SolarDailyHistoryPoint(dayNameEn: 'Sat', dayNameAr: 'السبت', generatedKwh: 10.8, consumedKwh: 7.3),
        SolarDailyHistoryPoint(dayNameEn: 'Sun', dayNameAr: 'الأحد', generatedKwh: 8.4, consumedKwh: 5.8),
      ],
      activeAlerts: [
        SolarAlertEntity(
          id: 'alt-sol-101',
          titleEn: 'Solar Output Optimal',
          titleAr: 'إنتاج الطاقة الشمسية في المعدل المثالي',
          descriptionEn: 'Panels are generating 1250W with 400W feeding battery storage.',
          descriptionAr: 'الألواح تنتج 1250 واط مع 400 واط فائض لشحن بطاريات الليثيوم.',
          severity: 'info',
          timestamp: '14:20',
        ),
      ],
    );
  }
}
