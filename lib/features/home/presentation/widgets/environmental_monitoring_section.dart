import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Environmental Monitoring Section.
/// Displays 4 live telemetry cards: Soil Moisture, Temperature, Humidity, and Water Consumption.
class EnvironmentalMonitoringSection extends StatelessWidget {
  final EnvironmentalMetricEntity metrics;

  const EnvironmentalMonitoringSection({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      AppStrings.environmentalMonitoring(context),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              label: isArabic ? 'بيانات حية' : 'Live ESP32',
              color: AppColors.sensorOnline,
              icon: Icons.wifi_tethering_rounded,
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 4 Environmental Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // 1. Soil Moisture Card
                _SoilMoistureCard(
                  width: cardWidth,
                  moisture: metrics.soilMoisture,
                  status: metrics.soilMoistureStatus,
                ),

                // 2. Temperature Card
                _TemperatureCard(
                  width: cardWidth,
                  temperature: metrics.temperatureCelsius,
                  isWarning: metrics.isHighTemperatureWarning,
                ),

                // 3. Air Humidity Card
                _HumidityCard(
                  width: cardWidth,
                  humidity: metrics.airHumidity,
                ),

                // 4. Water Consumption Card
                _WaterConsumptionCard(
                  width: cardWidth,
                  liters: metrics.dailyWaterConsumptionLiters,
                  vsYesterday: metrics.vsYesterdayPercent,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// 1. Soil Moisture Card with circular indicator
class _SoilMoistureCard extends StatelessWidget {
  final double width;
  final double moisture;
  final String status;

  const _SoilMoistureCard({
    required this.width,
    required this.moisture,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = AppStrings.isArabic(context);

    final statusLabel = status == 'Optimal'
        ? AppStrings.optimal(context)
        : (status == 'Low' ? AppStrings.low(context) : AppStrings.high(context));

    final color = status == 'Optimal'
        ? AppColors.primaryGreen
        : (status == 'Low' ? AppColors.sensorWarning : AppColors.flowBlue);

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.grass_rounded,
                  color: AppColors.primaryGreen,
                  size: 16,
                ),
              ),
              StatusBadge(
                label: statusLabel,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${moisture.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.soilMoisture(context),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              // Circular Progress Ring
              SizedBox(
                width: 38,
                height: 38,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: moisture / 100,
                      strokeWidth: 3.8,
                      backgroundColor: isDark
                          ? AppColors.borderDark
                          : AppColors.primaryGreenSurface,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    Icon(
                      Icons.water_drop_outlined,
                      size: 16,
                      color: color,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isArabic ? 'العمق 25 سم • مستشعر B2' : 'Depth 25cm • Probe B2',
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Temperature Card with warning state
class _TemperatureCard extends StatelessWidget {
  final double width;
  final double temperature;
  final bool isWarning;

  const _TemperatureCard({
    required this.width,
    required this.temperature,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = AppStrings.isArabic(context);

    final color = isWarning ? AppColors.sensorAlert : const Color(0xFFF59E0B);

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? AppColors.sensorAlert.withValues(alpha: 0.6)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isWarning ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.thermostat_rounded,
                  color: color,
                  size: 16,
                ),
              ),
              StatusBadge(
                label: isWarning
                    ? AppStrings.warningHigh(context)
                    : (isArabic ? 'معتدل' : 'Moderate'),
                color: color,
                icon: isWarning ? Icons.warning_amber_rounded : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${temperature.toStringAsFixed(1)} °C',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isWarning
                  ? AppColors.sensorAlert
                  : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            AppStrings.temperature(context),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic ? 'القمة: 31° • الأدنى: 19°' : 'High: 31° • Low: 19°',
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Air Humidity Card
class _HumidityCard extends StatelessWidget {
  final double width;
  final double humidity;

  const _HumidityCard({
    required this.width,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = AppStrings.isArabic(context);

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.flowBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.air_rounded,
                  color: AppColors.flowBlue,
                  size: 16,
                ),
              ),
              StatusBadge(
                label: isArabic ? 'طبيعي' : 'Optimal',
                color: AppColors.flowBlue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${humidity.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            AppStrings.airHumidity(context),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: humidity / 100,
              minHeight: 5,
              backgroundColor: isDark
                  ? AppColors.borderDark
                  : AppColors.flowBlueSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.flowBlue),
            ),
          ),
        ],
      ),
    );
  }
}

// 4. Water Consumption Card
class _WaterConsumptionCard extends StatelessWidget {
  final double width;
  final double liters;
  final double vsYesterday;

  const _WaterConsumptionCard({
    required this.width,
    required this.liters,
    required this.vsYesterday,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = AppStrings.isArabic(context);

    final isSaved = vsYesterday <= 0;
    final formattedPercent = '${vsYesterday.abs().toStringAsFixed(1)}%';

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.flowBlueDark.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.opacity_rounded,
                  color: AppColors.flowBlueDark,
                  size: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isSaved
                      ? AppColors.sensorOnline.withValues(alpha: 0.12)
                      : AppColors.sensorAlert.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSaved ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      size: 11,
                      color: isSaved ? AppColors.sensorOnline : AppColors.sensorAlert,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      formattedPercent,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSaved ? AppColors.sensorOnline : AppColors.sensorAlert,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                liters.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isArabic ? 'لتر/اليوم' : 'L/day',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            AppStrings.waterConsumption(context),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSaved
                ? (isArabic ? 'توفير مياه ممتاز اليوم' : 'Excellent water savings')
                : (isArabic ? 'زيادة طفيفة في الاستهلاك' : 'Slight usage increase'),
            style: TextStyle(
              fontSize: 10,
              color: isSaved ? AppColors.sensorOnline : AppColors.sensorAlert,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
