import 'package:flutter/material.dart';

/// Overall Farm Statistics summary entity.
class FarmSummaryEntity {
  final int totalFarms;
  final int totalTrees;
  final int connectedDevices;
  final double overallHealthPercent;

  const FarmSummaryEntity({
    required this.totalFarms,
    required this.totalTrees,
    required this.connectedDevices,
    required this.overallHealthPercent,
  });
}

/// Real-time Environmental Monitoring Metrics.
class EnvironmentalMetricEntity {
  final double soilMoisture; // e.g. 42.5 %
  final String soilMoistureStatus; // Optimal, Low, High
  final double temperatureCelsius; // e.g. 26.8 °C
  final bool isHighTemperatureWarning;
  final double airHumidity; // e.g. 58 %
  final double dailyWaterConsumptionLiters; // e.g. 380 L
  final double vsYesterdayPercent; // e.g. -12.4 % (saved)

  const EnvironmentalMetricEntity({
    required this.soilMoisture,
    required this.soilMoistureStatus,
    required this.temperatureCelsius,
    required this.isHighTemperatureWarning,
    required this.airHumidity,
    required this.dailyWaterConsumptionLiters,
    required this.vsYesterdayPercent,
  });

  EnvironmentalMetricEntity copyWith({
    double? soilMoisture,
    String? soilMoistureStatus,
    double? temperatureCelsius,
    bool? isHighTemperatureWarning,
    double? airHumidity,
    double? dailyWaterConsumptionLiters,
    double? vsYesterdayPercent,
  }) {
    return EnvironmentalMetricEntity(
      soilMoisture: soilMoisture ?? this.soilMoisture,
      soilMoistureStatus: soilMoistureStatus ?? this.soilMoistureStatus,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      isHighTemperatureWarning:
          isHighTemperatureWarning ?? this.isHighTemperatureWarning,
      airHumidity: airHumidity ?? this.airHumidity,
      dailyWaterConsumptionLiters:
          dailyWaterConsumptionLiters ?? this.dailyWaterConsumptionLiters,
      vsYesterdayPercent: vsYesterdayPercent ?? this.vsYesterdayPercent,
    );
  }
}

/// Smart Irrigation Status and Actuator state.
class IrrigationStatusEntity {
  final bool isPumpActive;
  final bool isAutomaticMode;
  final String nextScheduledEn;
  final String nextScheduledAr;
  final String lastActivityEn;
  final String lastActivityAr;
  final double lastWaterVolumeLiters;

  const IrrigationStatusEntity({
    required this.isPumpActive,
    required this.isAutomaticMode,
    required this.nextScheduledEn,
    required this.nextScheduledAr,
    required this.lastActivityEn,
    required this.lastActivityAr,
    required this.lastWaterVolumeLiters,
  });

  IrrigationStatusEntity copyWith({
    bool? isPumpActive,
    bool? isAutomaticMode,
    String? nextScheduledEn,
    String? nextScheduledAr,
    String? lastActivityEn,
    String? lastActivityAr,
    double? lastWaterVolumeLiters,
  }) {
    return IrrigationStatusEntity(
      isPumpActive: isPumpActive ?? this.isPumpActive,
      isAutomaticMode: isAutomaticMode ?? this.isAutomaticMode,
      nextScheduledEn: nextScheduledEn ?? this.nextScheduledEn,
      nextScheduledAr: nextScheduledAr ?? this.nextScheduledAr,
      lastActivityEn: lastActivityEn ?? this.lastActivityEn,
      lastActivityAr: lastActivityAr ?? this.lastActivityAr,
      lastWaterVolumeLiters:
          lastWaterVolumeLiters ?? this.lastWaterVolumeLiters,
    );
  }
}

/// Plant & Crop Health Breakdown.
class PlantHealthEntity {
  final int healthyCount;
  final int attentionCount;
  final int criticalCount;
  final int totalCount;
  final double overallHealthPercent;

  const PlantHealthEntity({
    required this.healthyCount,
    required this.attentionCount,
    required this.criticalCount,
    required this.totalCount,
    required this.overallHealthPercent,
  });
}

/// Daily Water Consumption bar point for the weekly analytics chart.
class DailyWaterConsumptionPoint {
  final String dayNameEn;
  final String dayNameAr;
  final double liters;
  final bool isToday;

  const DailyWaterConsumptionPoint({
    required this.dayNameEn,
    required this.dayNameAr,
    required this.liters,
    this.isToday = false,
  });
}

/// Weekly Water Consumption Analytics.
class WaterAnalyticsEntity {
  final List<DailyWaterConsumptionPoint> weeklyReadings;
  final double weeklyTotalLiters;
  final double dailyAverageLiters;

  const WaterAnalyticsEntity({
    required this.weeklyReadings,
    required this.weeklyTotalLiters,
    required this.dailyAverageLiters,
  });
}

enum ActivityCategory {
  irrigation,
  sensor,
  warning,
  device,
  health,
}

/// Recent Farm Activity timeline event.
class FarmActivityEntity {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final String timeAgoEn;
  final String timeAgoAr;
  final ActivityCategory category;
  final IconData icon;

  const FarmActivityEntity({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.timeAgoEn,
    required this.timeAgoAr,
    required this.category,
    required this.icon,
  });
}
