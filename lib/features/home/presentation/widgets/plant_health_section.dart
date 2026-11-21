import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Plant & Crop Health breakdown section.
/// Displays segmented health bar, counts for Healthy, Attention, Critical, and overall score.
class PlantHealthSection extends StatelessWidget {
  final PlantHealthEntity health;

  const PlantHealthSection({
    super.key,
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final healthyRatio = health.healthyCount / health.totalCount;
    final attentionRatio = health.attentionCount / health.totalCount;
    final criticalRatio = health.criticalCount / health.totalCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title & Overall Health Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.energy_savings_leaf_rounded,
                        color: AppColors.primaryGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        AppStrings.plantHealthSection(context),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${health.overallHealthPercent.toStringAsFixed(0)}% ${AppStrings.overallHealth(context)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Segmented Horizontal Health Ratio Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: (healthyRatio * 1000).toInt(),
                    child: Container(color: AppColors.sensorOnline),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (attentionRatio * 1000).toInt().clamp(1, 1000),
                    child: Container(color: AppColors.sensorWarning),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: (criticalRatio * 1000).toInt().clamp(1, 1000),
                    child: Container(color: AppColors.sensorAlert),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3 Health Category Mini Badges (Healthy, Attention, Critical)
          Row(
            children: [
              Expanded(
                child: _HealthPill(
                  label: AppStrings.healthyPlants(context),
                  count: '${health.healthyCount}',
                  percentage: '${(healthyRatio * 100).toStringAsFixed(1)}%',
                  color: AppColors.sensorOnline,
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HealthPill(
                  label: AppStrings.attentionPlants(context),
                  count: '${health.attentionCount}',
                  percentage: '${(attentionRatio * 100).toStringAsFixed(1)}%',
                  color: AppColors.sensorWarning,
                  icon: Icons.warning_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HealthPill(
                  label: AppStrings.criticalPlants(context),
                  count: '${health.criticalCount}',
                  percentage: '${(criticalRatio * 100).toStringAsFixed(1)}%',
                  color: AppColors.sensorAlert,
                  icon: Icons.error_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Bottom AI Health summary line
          Text(
            isArabic
                ? 'تم تحليل 1,420 شجرة زيتون ونخيل بواسطة الأقمار الصناعية ومجسات التربة'
                : '1,420 crops monitored via multi-spectral indices & soil nodes',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HealthPill extends StatelessWidget {
  final String label;
  final String count;
  final String percentage;
  final Color color;
  final IconData icon;

  const _HealthPill({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 9,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}
