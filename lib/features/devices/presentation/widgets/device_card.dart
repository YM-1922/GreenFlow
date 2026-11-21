import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/device_entities.dart';

/// Card widget presenting an ESP32 hardware node, signal metrics, and sensor values.
class DeviceCard extends StatelessWidget {
  final Esp32DeviceEntity device;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusLabel =
        isArabic ? device.status.labelAr() : device.status.labelEn();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row: Category Icon + Name & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    device.category.icon(),
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${device.serialNumber} • ${device.zoneName}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                StatusBadge(
                  label: statusLabel,
                  color: device.status.color(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Live Telemetry preview pills if it's a soil probe or level sensor
            if (device.soilMoistureTop25cm != null ||
                device.waterLevelMeters != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.primaryGreenSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (device.soilMoistureTop25cm != null) ...[
                      _ReadingItem(
                        label: isArabic ? 'رطوبة 25 سم' : 'Moisture 25cm',
                        value: '${device.soilMoistureTop25cm!.toStringAsFixed(1)}%',
                        color: AppColors.primaryGreen,
                        isDark: isDark,
                      ),
                      _ReadingItem(
                        label: isArabic ? 'رطوبة 50 سم' : 'Moisture 50cm',
                        value: '${device.soilMoistureDeep50cm?.toStringAsFixed(1) ?? '45'}%',
                        color: AppColors.flowBlue,
                        isDark: isDark,
                      ),
                      _ReadingItem(
                        label: isArabic ? 'حرارة التربة' : 'Soil Temp',
                        value: '${device.soilTemperatureCelsius?.toStringAsFixed(1) ?? '22'}°C',
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),
                    ] else if (device.waterLevelMeters != null) ...[
                      _ReadingItem(
                        label: isArabic ? 'منسوب المياه' : 'Water Level',
                        value: '${device.waterLevelMeters!.toStringAsFixed(1)} m',
                        color: AppColors.flowBlue,
                        isDark: isDark,
                      ),
                      _ReadingItem(
                        label: isArabic ? 'حالة البئر' : 'Well State',
                        value: isArabic ? 'آمن وطبيعي' : 'Optimal',
                        color: AppColors.sensorOnline,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Bottom Footer: Signal RSSI, Battery, Last Seen
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.wifi_rounded,
                      size: 13,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${device.rssiSignalDbm} dBm',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.battery_charging_full_rounded,
                      size: 14,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${device.batteryPercent}% (${device.batteryVoltage.toStringAsFixed(1)}V)',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                Text(
                  isArabic ? 'متصل منذ قليل' : 'Active 1m ago',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _ReadingItem({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }
}
