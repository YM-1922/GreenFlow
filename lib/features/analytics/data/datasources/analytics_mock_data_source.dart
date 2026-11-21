import '../../domain/entities/analytics_entities.dart';

/// Mock Data Source for Commercial Farm Telemetry & Irrigation Analytics.
/// Computes distinct realistic values per farm and timeframe.
class AnalyticsMockDataSource {
  const AnalyticsMockDataSource();

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

  FarmAnalyticsEntity getAnalytics({
    String farmId = 'farm-001',
    AnalyticsTimeframe timeframe = AnalyticsTimeframe.weekly,
  }) {
    final isHope = farmId == 'farm-001';
    final isNile = farmId == 'farm-002';

    final farmNameEn = isHope
        ? 'Hope Olive & Palm Farm'
        : (isNile ? 'Nile Valley Citrus Farm' : 'Fayrouz Organic Estate');

    final farmNameAr = isHope
        ? 'مزرعة الأمل للزيتون والنخيل'
        : (isNile ? 'مزرعة وادي النيل للطماطم والموالح' : 'مزرعة الفيروز العضوية');

    switch (timeframe) {
      case AnalyticsTimeframe.daily:
        return FarmAnalyticsEntity(
          farmId: farmId,
          farmNameEn: farmNameEn,
          farmNameAr: farmNameAr,
          timeframe: timeframe,
          totalWaterLiters: isHope ? 580.0 : (isNile ? 890.0 : 420.0),
          waterSavedPercentage: isHope ? 14.5 : (isNile ? 11.2 : 18.0),
          totalIrrigationMinutes: isHope ? 90 : (isNile ? 140 : 65),
          irrigationSessionsCount: isHope ? 2 : (isNile ? 3 : 1),
          averageFlowRateLpm: 6.4,
          averageSoilMoisture: isHope ? 43.2 : (isNile ? 38.5 : 45.0),
          averageTemperatureCelsius: 28.4,
          averageHumidityPercent: 54.0,
          solarGeneratedKwh: isHope ? 8.4 : (isNile ? 12.8 : 5.6),
          solarConsumedKwh: isHope ? 5.8 : (isNile ? 9.8 : 6.2),
          solarNetSurplusKwh: isHope ? 2.6 : (isNile ? 3.0 : -0.6),
          waterChartPoints: const [
            ConsumptionChartPoint(label: '06h', value: 80.0),
            ConsumptionChartPoint(label: '09h', value: 160.0),
            ConsumptionChartPoint(label: '12h', value: 40.0),
            ConsumptionChartPoint(label: '15h', value: 120.0),
            ConsumptionChartPoint(label: '18h', value: 180.0),
          ],
          soilTrendPoints: const [
            SoilTrendPoint(label: '06h', topMoisture: 42.0, deepMoisture: 45.0),
            SoilTrendPoint(label: '10h', topMoisture: 38.0, deepMoisture: 44.0),
            SoilTrendPoint(label: '14h', topMoisture: 45.0, deepMoisture: 48.0),
            SoilTrendPoint(label: '18h', topMoisture: 43.0, deepMoisture: 46.0),
          ],
          weatherTrendPoints: const [
            WeatherTrendPoint(label: '06h', tempCelsius: 22.0, humidityPercent: 68.0),
            WeatherTrendPoint(label: '12h', tempCelsius: 34.0, humidityPercent: 42.0),
            WeatherTrendPoint(label: '16h', tempCelsius: 31.0, humidityPercent: 48.0),
            WeatherTrendPoint(label: '20h', tempCelsius: 26.0, humidityPercent: 58.0),
          ],
          solarChartPoints: const [
            ConsumptionChartPoint(label: '08h', value: 1.2),
            ConsumptionChartPoint(label: '11h', value: 2.8),
            ConsumptionChartPoint(label: '14h', value: 2.9),
            ConsumptionChartPoint(label: '17h', value: 1.5),
          ],
        );

      case AnalyticsTimeframe.weekly:
        return FarmAnalyticsEntity(
          farmId: farmId,
          farmNameEn: farmNameEn,
          farmNameAr: farmNameAr,
          timeframe: timeframe,
          totalWaterLiters: isHope ? 3840.0 : (isNile ? 5420.0 : 2910.0),
          waterSavedPercentage: isHope ? 16.8 : (isNile ? 13.5 : 19.4),
          totalIrrigationMinutes: isHope ? 620 : (isNile ? 880 : 450),
          irrigationSessionsCount: isHope ? 14 : (isNile ? 21 : 10),
          averageFlowRateLpm: 6.2,
          averageSoilMoisture: isHope ? 42.8 : (isNile ? 39.1 : 44.2),
          averageTemperatureCelsius: 29.1,
          averageHumidityPercent: 52.0,
          solarGeneratedKwh: isHope ? 68.2 : (isNile ? 94.5 : 46.8),
          solarConsumedKwh: isHope ? 46.0 : (isNile ? 72.0 : 48.5),
          solarNetSurplusKwh: isHope ? 22.2 : (isNile ? 22.5 : -1.7),
          waterChartPoints: const [
            ConsumptionChartPoint(label: 'Sat', value: 520.0),
            ConsumptionChartPoint(label: 'Sun', value: 580.0),
            ConsumptionChartPoint(label: 'Mon', value: 490.0),
            ConsumptionChartPoint(label: 'Tue', value: 610.0),
            ConsumptionChartPoint(label: 'Wed', value: 540.0),
            ConsumptionChartPoint(label: 'Thu', value: 560.0),
            ConsumptionChartPoint(label: 'Fri', value: 540.0),
          ],
          soilTrendPoints: const [
            SoilTrendPoint(label: 'Sat', topMoisture: 41.0, deepMoisture: 45.0),
            SoilTrendPoint(label: 'Mon', topMoisture: 44.0, deepMoisture: 47.0),
            SoilTrendPoint(label: 'Wed', topMoisture: 42.0, deepMoisture: 46.0),
            SoilTrendPoint(label: 'Fri', topMoisture: 45.0, deepMoisture: 48.0),
          ],
          weatherTrendPoints: const [
            WeatherTrendPoint(label: 'Sat', tempCelsius: 28.0, humidityPercent: 55.0),
            WeatherTrendPoint(label: 'Mon', tempCelsius: 30.5, humidityPercent: 50.0),
            WeatherTrendPoint(label: 'Wed', tempCelsius: 29.0, humidityPercent: 52.0),
            WeatherTrendPoint(label: 'Fri', tempCelsius: 32.0, humidityPercent: 47.0),
          ],
          solarChartPoints: const [
            ConsumptionChartPoint(label: 'Sat', value: 9.8),
            ConsumptionChartPoint(label: 'Sun', value: 10.4),
            ConsumptionChartPoint(label: 'Mon', value: 10.1),
            ConsumptionChartPoint(label: 'Tue', value: 9.5),
            ConsumptionChartPoint(label: 'Wed', value: 11.2),
            ConsumptionChartPoint(label: 'Thu', value: 10.8),
            ConsumptionChartPoint(label: 'Fri', value: 8.4),
          ],
        );

      case AnalyticsTimeframe.monthly:
        return FarmAnalyticsEntity(
          farmId: farmId,
          farmNameEn: farmNameEn,
          farmNameAr: farmNameAr,
          timeframe: timeframe,
          totalWaterLiters: isHope ? 15200.0 : (isNile ? 22800.0 : 11600.0),
          waterSavedPercentage: isHope ? 18.2 : (isNile ? 14.8 : 21.0),
          totalIrrigationMinutes: isHope ? 2450 : (isNile ? 3600 : 1800),
          irrigationSessionsCount: isHope ? 58 : (isNile ? 84 : 42),
          averageFlowRateLpm: 6.3,
          averageSoilMoisture: isHope ? 43.5 : (isNile ? 39.8 : 44.6),
          averageTemperatureCelsius: 27.6,
          averageHumidityPercent: 56.0,
          solarGeneratedKwh: isHope ? 284.0 : (isNile ? 390.0 : 195.0),
          solarConsumedKwh: isHope ? 198.0 : (isNile ? 310.0 : 205.0),
          solarNetSurplusKwh: isHope ? 86.0 : (isNile ? 80.0 : -10.0),
          waterChartPoints: const [
            ConsumptionChartPoint(label: 'W1', value: 3600.0),
            ConsumptionChartPoint(label: 'W2', value: 3950.0),
            ConsumptionChartPoint(label: 'W3', value: 3800.0),
            ConsumptionChartPoint(label: 'W4', value: 3850.0),
          ],
          soilTrendPoints: const [
            SoilTrendPoint(label: 'W1', topMoisture: 42.0, deepMoisture: 46.0),
            SoilTrendPoint(label: 'W2', topMoisture: 44.0, deepMoisture: 47.0),
            SoilTrendPoint(label: 'W3', topMoisture: 43.0, deepMoisture: 46.0),
            SoilTrendPoint(label: 'W4', topMoisture: 45.0, deepMoisture: 48.0),
          ],
          weatherTrendPoints: const [
            WeatherTrendPoint(label: 'W1', tempCelsius: 27.0, humidityPercent: 58.0),
            WeatherTrendPoint(label: 'W2', tempCelsius: 29.0, humidityPercent: 53.0),
            WeatherTrendPoint(label: 'W3', tempCelsius: 28.0, humidityPercent: 55.0),
            WeatherTrendPoint(label: 'W4', tempCelsius: 26.5, humidityPercent: 60.0),
          ],
          solarChartPoints: const [
            ConsumptionChartPoint(label: 'W1', value: 68.0),
            ConsumptionChartPoint(label: 'W2', value: 74.0),
            ConsumptionChartPoint(label: 'W3', value: 71.0),
            ConsumptionChartPoint(label: 'W4', value: 71.0),
          ],
        );
    }
  }
}
