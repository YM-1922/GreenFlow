import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/irrigation_entities.dart';

/// Grid of individual zone solenoid valves with instant actuation and safety interlocks.
class ZoneValvesGrid extends StatelessWidget {
  final List<ZoneValveEntity> valves;
  final Function(String valveId, bool open) onToggleValve;

  const ZoneValvesGrid({
    super.key,
    required this.valves,
    required this.onToggleValve,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.flowBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'محابس القطاعات الذكية' : 'Smart Zone Solenoid Valves',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            Text(
              '${valves.where((v) => v.isOpen).length}/${valves.length} ${isArabic ? 'مفتوحة' : 'Open'}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.flowBlue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: valves.map((valve) {
                return Container(
                  width: cardWidth,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: valve.isOpen
                          ? AppColors.flowBlue
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                      width: valve.isOpen ? 1.6 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (valve.isOpen
                                ? AppColors.flowBlue
                                : Colors.black)
                            .withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
                              color: (valve.isOpen
                                      ? AppColors.flowBlue
                                      : const Color(0xFF64748B))
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              size: 16,
                              color: valve.isOpen
                                  ? AppColors.flowBlue
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          Switch(
                            value: valve.isOpen,
                            activeThumbColor: AppColors.flowBlue,
                            activeTrackColor:
                                AppColors.flowBlue.withValues(alpha: 0.3),
                            onChanged: (val) {
                              onToggleValve(valve.id, val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${isArabic ? 'محبس' : 'Valve'} #${valve.valveNumber}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.flowBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        valve.zoneName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            valve.isOpen
                                ? '${valve.flowRateLpm.toInt()} L/m'
                                : (isArabic ? 'مغلق' : 'Closed'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: valve.isOpen
                                  ? AppColors.primaryGreen
                                  : (isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight),
                            ),
                          ),
                          Text(
                            '${valve.currentMoisture.toStringAsFixed(1)}%',
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
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
