import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/irrigation_entities.dart';

/// Timeline of completed irrigation operations with water metering and duration logs.
class IrrigationHistoryList extends StatelessWidget {
  final List<IrrigationHistoryRecordEntity> history;

  const IrrigationHistoryList({
    super.key,
    required this.history,
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
                    color: const Color(0xFF6366F1), // Indigo
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'سجل عمليات الري' : 'Irrigation Operation History',
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
              '${history.length} ${isArabic ? 'سجلات' : 'Logs'}',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (history.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                isArabic ? 'لا توجد سجلات ري سابقة' : 'No past irrigation logs',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ] else ...[
          ...history.map((record) {
            final dateStr =
                '${record.startedAt.day}/${record.startedAt.month} • ${record.startedAt.hour.toString().padLeft(2, '0')}:${record.startedAt.minute.toString().padLeft(2, '0')}';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (record.isSuccess
                              ? AppColors.primaryGreen
                              : AppColors.sensorAlert)
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      record.isSuccess
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 16,
                      color: record.isSuccess
                          ? AppColors.primaryGreen
                          : AppColors.sensorAlert,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.zoneName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${record.waterConsumedLiters.toInt()} L',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.flowBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: record.isScheduled
                              ? AppColors.primaryGreenSurface
                              : AppColors.flowBlueSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          record.isScheduled
                              ? (isArabic ? 'جدول آلي' : 'Scheduled')
                              : (isArabic ? 'يدوي' : 'Manual'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: record.isScheduled
                                ? AppColors.primaryGreenDark
                                : AppColors.flowBlueDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
