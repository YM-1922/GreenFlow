import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Farm Summary Cards Grid.
/// Displays Total Farms, Total Trees, Connected IoT Devices, and Overall Health.
class FarmSummarySection extends StatelessWidget {
  final FarmSummaryEntity summary;

  const FarmSummarySection({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use 2 columns for standard mobile
        final itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryCard(
              width: itemWidth,
              title: AppStrings.totalFarms(context),
              value: '${summary.totalFarms}',
              subtitle: AppStrings.isArabic(context) ? 'مواقع نشطة' : 'Active Sites',
              icon: Icons.landscape_rounded,
              accentColor: AppColors.primaryGreen,
              gradient: const LinearGradient(
                colors: [Color(0x1F10B981), Color(0x0510B981)],
              ),
            ),
            _SummaryCard(
              width: itemWidth,
              title: AppStrings.totalTrees(context),
              value: summary.totalTrees.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  ),
              subtitle: AppStrings.isArabic(context) ? 'محاصيل مراقبة' : 'Monitored Crops',
              icon: Icons.forest_rounded,
              accentColor: const Color(0xFF14B8A6), // Teal
              gradient: const LinearGradient(
                colors: [Color(0x1F14B8A6), Color(0x0514B8A6)],
              ),
            ),
            _SummaryCard(
              width: itemWidth,
              title: AppStrings.connectedDevices(context),
              value: '${summary.connectedDevices}',
              subtitle: AppStrings.isArabic(context) ? 'عقد ESP32 نشطة' : 'Active ESP32 Nodes',
              icon: Icons.sensors_rounded,
              accentColor: AppColors.flowBlue,
              gradient: const LinearGradient(
                colors: [Color(0x1F0284C7), Color(0x050284C7)],
              ),
            ),
            _SummaryCard(
              width: itemWidth,
              title: AppStrings.overallHealth(context),
              value: '${summary.overallHealthPercent.toStringAsFixed(1)}%',
              subtitle: AppStrings.isArabic(context) ? 'معدل قياسي' : 'Optimal Index',
              icon: Icons.health_and_safety_rounded,
              accentColor: AppColors.sensorOnline,
              gradient: const LinearGradient(
                colors: [Color(0x1F22C55E), Color(0x0522C55E)],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Gradient gradient;

  const _SummaryCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        gradient: isDark ? null : gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark
              : accentColor.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.05 : 0.06),
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
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: accentColor.withValues(alpha: 0.6),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: accentColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
