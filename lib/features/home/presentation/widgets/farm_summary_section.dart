import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Farm Summary Cards Section matching the Reference Mobile Design.
/// Displays Total Farms, Connected IoT Devices, and Irrigation Zones (No tree counters).
class FarmSummarySection extends StatelessWidget {
  final FarmSummaryEntity summary;

  const FarmSummarySection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isAr = AppStrings.isArabic(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // 1. Farms Count
            Expanded(
              child: _SummaryCard(
                title: isAr ? 'المزارع' : 'Farms',
                value: '${summary.totalFarms}',
                icon: Icons.landscape_rounded,
                accentColor: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 8),
            // 2. Connected Devices Count
            Expanded(
              child: _SummaryCard(
                title: isAr ? 'الأجهزة' : 'Devices',
                value: '${summary.connectedDevices}',
                icon: Icons.sensors_rounded,
                accentColor: AppColors.flowBlue,
              ),
            ),
            const SizedBox(width: 8),
            // 3. Irrigation Zones Count (Replacing tree count)
            Expanded(
              child: _SummaryCard(
                title: isAr ? 'مناطق الري' : 'Zones',
                value: '3',
                icon: Icons.water_drop_rounded,
                accentColor: const Color(0xFF10B981),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
