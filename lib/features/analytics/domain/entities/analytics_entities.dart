/// Analytics domain entities for Green Flow – Phase 9.
library;

enum AnalyticsTimeframe { daily, weekly, monthly }

extension AnalyticsTimeframeExtension on AnalyticsTimeframe {
  String labelEn() {
    switch (this) {
      case AnalyticsTimeframe.daily:
        return 'Daily (24h)';
      case AnalyticsTimeframe.weekly:
        return 'Weekly (7d)';
      case AnalyticsTimeframe.monthly:
        return 'Monthly (30d)';
    }
  }

  String labelAr() {
    switch (this) {
      case AnalyticsTimeframe.daily:
        return 'يومي (24س)';
      case AnalyticsTimeframe.weekly:
        return 'أسبوعي (7أيام)';
      case AnalyticsTimeframe.monthly:
        return 'شهري (30يوم)';
    }
  }
}

class ConsumptionChartPoint {
  final String label; // "Mon" or "10:00" or "W1"
  final double value; // Liters or kWh

  const ConsumptionChartPoint({
    required this.label,
    required this.value,
  });
}

class SoilTrendPoint {
  final String label;
  final double topMoisture; // 25cm %
  final double deepMoisture; // 50cm %

  const SoilTrendPoint({
    required this.label,
    required this.topMoisture,
    required this.deepMoisture,
  });
}

class WeatherTrendPoint {
  final String label;
  final double tempCelsius;
  final double humidityPercent;

  const WeatherTrendPoint({
    required this.label,
    required this.tempCelsius,
    required this.humidityPercent,
  });
}

class FarmAnalyticsEntity {
  final String farmId;
  final String farmNameEn;
  final String farmNameAr;
  final AnalyticsTimeframe timeframe;
  final double totalWaterLiters;
  final double waterSavedPercentage;
  final int totalIrrigationMinutes;
  final int irrigationSessionsCount;
  final double averageFlowRateLpm; // Liters per minute
  final double averageSoilMoisture;
  final double averageTemperatureCelsius;
  final double averageHumidityPercent;
  final double solarGeneratedKwh;
  final double solarConsumedKwh;
  final double solarNetSurplusKwh;
  final List<ConsumptionChartPoint> waterChartPoints;
  final List<SoilTrendPoint> soilTrendPoints;
  final List<WeatherTrendPoint> weatherTrendPoints;
  final List<ConsumptionChartPoint> solarChartPoints;

  const FarmAnalyticsEntity({
    required this.farmId,
    required this.farmNameEn,
    required this.farmNameAr,
    required this.timeframe,
    required this.totalWaterLiters,
    required this.waterSavedPercentage,
    required this.totalIrrigationMinutes,
    required this.irrigationSessionsCount,
    required this.averageFlowRateLpm,
    required this.averageSoilMoisture,
    required this.averageTemperatureCelsius,
    required this.averageHumidityPercent,
    required this.solarGeneratedKwh,
    required this.solarConsumedKwh,
    required this.solarNetSurplusKwh,
    required this.waterChartPoints,
    required this.soilTrendPoints,
    required this.weatherTrendPoints,
    required this.solarChartPoints,
  });
}
