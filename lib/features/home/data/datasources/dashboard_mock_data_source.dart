import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Local Mock Data Source for Green Flow Dashboard.
/// Provides realistic demonstration telemetry values separated from UI widgets.
class DashboardMockDataSource {
  const DashboardMockDataSource();

  FarmSummaryEntity getFarmSummary() {
    return const FarmSummaryEntity(
      totalFarms: 3,
      totalTrees: 1420,
      connectedDevices: 18,
      overallHealthPercent: 94.2,
    );
  }

  EnvironmentalMetricEntity getEnvironmentalMetrics() {
    return const EnvironmentalMetricEntity(
      soilMoisture: 42.5,
      soilMoistureStatus: 'Optimal',
      temperatureCelsius: 26.8,
      isHighTemperatureWarning: false,
      airHumidity: 58.0,
      dailyWaterConsumptionLiters: 380.0,
      vsYesterdayPercent: -12.4, // 12.4% water saved
    );
  }

  IrrigationStatusEntity getIrrigationStatus() {
    return const IrrigationStatusEntity(
      isPumpActive: false,
      isAutomaticMode: true,
      nextScheduledEn: 'Today at 09:30 PM (Zone A)',
      nextScheduledAr: 'اليوم في 09:30 م (القطاع أ)',
      lastActivityEn: 'Completed 4 hrs ago • 140 L delivered',
      lastActivityAr: 'اكتملت قبل 4 ساعات • تم استهلاك 140 لتر',
      lastWaterVolumeLiters: 140.0,
    );
  }

  PlantHealthEntity getPlantHealth() {
    return const PlantHealthEntity(
      healthyCount: 1335,
      attentionCount: 68,
      criticalCount: 17,
      totalCount: 1420,
      overallHealthPercent: 94.0,
    );
  }

  WaterAnalyticsEntity getWaterAnalytics() {
    return const WaterAnalyticsEntity(
      weeklyReadings: [
        DailyWaterConsumptionPoint(
          dayNameEn: 'Sat',
          dayNameAr: 'السبت',
          liters: 340,
        ),
        DailyWaterConsumptionPoint(
          dayNameEn: 'Sun',
          dayNameAr: 'الأحد',
          liters: 420,
        ),
        DailyWaterConsumptionPoint(
          dayNameEn: 'Mon',
          dayNameAr: 'الاثنين',
          liters: 390,
        ),
        DailyWaterConsumptionPoint(
          dayNameEn: 'Tue',
          dayNameAr: 'الثلاثاء',
          liters: 460,
        ),
        DailyWaterConsumptionPoint(
          dayNameEn: 'Wed',
          dayNameAr: 'الأربعاء',
          liters: 380,
          isToday: true,
        ),
        DailyWaterConsumptionPoint(
          dayNameEn: 'Thu',
          dayNameAr: 'الخميس',
          liters: 310,
        ),
        DailyWaterConsumptionPoint(
          dayNameEn: 'Fri',
          dayNameAr: 'الجمعة',
          liters: 240,
        ),
      ],
      weeklyTotalLiters: 2540,
      dailyAverageLiters: 362.8,
    );
  }

  List<FarmActivityEntity> getRecentActivities() {
    return const [
      FarmActivityEntity(
        id: 'act-1',
        titleEn: 'Smart Irrigation Completed',
        titleAr: 'اكتملت دورة الري الذكي',
        descriptionEn: 'Olive Grove Zone A • 45 min • 140 L consumed',
        descriptionAr: 'حقل الزيتون القطاع أ • 45 دقيقة • استهلاك 140 لتر',
        timeAgoEn: '42m ago',
        timeAgoAr: 'منذ 42 دقيقة',
        category: ActivityCategory.irrigation,
        icon: Icons.water_drop_rounded,
      ),
      FarmActivityEntity(
        id: 'act-2',
        titleEn: 'Soil Moisture Calibrated',
        titleAr: 'تحديث قراءات رطوبة التربة',
        descriptionEn: 'Sector B deep probe reported 42.5% (Optimal)',
        descriptionAr: 'مجس الأعماق في القطاع ب سجّل 42.5% (مستوى مثالي)',
        timeAgoEn: '1h 15m ago',
        timeAgoAr: 'منذ ساعة و15 دقيقة',
        category: ActivityCategory.sensor,
        icon: Icons.grass_rounded,
      ),
      FarmActivityEntity(
        id: 'act-3',
        titleEn: 'Peak Temperature Notice',
        titleAr: 'تنبيه ذروة درجة الحرارة',
        descriptionEn: 'Greenhouse 1 ambient temperature reached 33.5°C',
        descriptionAr: 'حرارة البيوت المحمية 1 وصلت إلى 33.5 درجة مئوية',
        timeAgoEn: '3h ago',
        timeAgoAr: 'منذ 3 ساعات',
        category: ActivityCategory.warning,
        icon: Icons.thermostat_rounded,
      ),
      FarmActivityEntity(
        id: 'act-4',
        titleEn: 'ESP32 Node Mesh Re-synced',
        titleAr: 'إعادة مزامنة شبكة ESP32',
        descriptionEn: 'Node #08 (Sub-surface Valve) latency 18ms',
        descriptionAr: 'العقدة #08 (صمام تحت أرضي) زمن الاستجابة 18 ملي ثانية',
        timeAgoEn: '5h ago',
        timeAgoAr: 'منذ 5 ساعات',
        category: ActivityCategory.device,
        icon: Icons.sensors_rounded,
      ),
      FarmActivityEntity(
        id: 'act-5',
        titleEn: 'Automated Crop Health Scan',
        titleAr: 'مسح آلي لصحة المحاصيل',
        descriptionEn: '94% of trees in optimal chlorophyll index',
        descriptionAr: '94% من الأشجار في مؤشر نمو وكلوروفيل ممتاز',
        timeAgoEn: '8h ago',
        timeAgoAr: 'منذ 8 ساعات',
        category: ActivityCategory.health,
        icon: Icons.energy_savings_leaf_rounded,
      ),
    ];
  }
}
