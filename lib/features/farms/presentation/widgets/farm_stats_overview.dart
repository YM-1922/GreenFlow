import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/farm_entities.dart';

/// Top Summary Metric Cards for the Farms Screen.
/// Displays Total Farms, Total Area, Total Trees, and Total Zones with clean responsive styling.
class FarmStatsOverview extends StatelessWidget {
  final List<FarmEntity> farms;

  const FarmStatsOverview({super.key, required this.farms});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalFarms = farms.length;
    final totalArea = farms.fold<double>(0.0, (sum, f) => sum + f.area);
    final totalZones = farms.fold<int>(0, (sum, f) => sum + f.zones.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // 1. Total Farms
            _StatCard(
              width: cardWidth,
              title: AppStrings.totalFarms(context),
              value: '$totalFarms',
              unit: isArabic ? 'مزارع' : 'Farms',
              icon: Icons.landscape_rounded,
              color: AppColors.primaryGreen,
              isDark: isDark,
            ),

            // 2. Total Area
            _StatCard(
              width: cardWidth,
              title: AppStrings.totalFarmArea(context),
              value: totalArea.toStringAsFixed(0),
              unit: isArabic ? 'فدان' : 'Feddan',
              icon: Icons.square_foot_rounded,
              color: AppColors.flowBlue,
              isDark: isDark,
            ),

            // 3. Connected IoT Devices
            _StatCard(
              width: cardWidth,
              title: isArabic ? 'أجهزة الاستشعار' : 'Connected Devices',
              value: '${farms.fold<int>(0, (sum, f) => sum + f.devices)}',
              unit: isArabic ? 'عقدة نشطة' : 'IoT Nodes',
              icon: Icons.sensors_rounded,
              color: const Color(0xFF10B981),
              isDark: isDark,
            ),

            // 4. Total Zones
            _StatCard(
              width: cardWidth,
              title: AppStrings.totalZones(context),
              value: '$totalZones',
              unit: isArabic ? 'قطاعات ري' : 'Active Zones',
              icon: Icons.grid_view_rounded,
              color: const Color(0xFF06B6D4), // Cyan
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
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
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
