import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/irrigation_entities.dart';
import 'schedule_add_edit_dialog.dart';

/// List of automated irrigation schedules with live toggle, edit, and delete support.
class IrrigationSchedulesList extends StatelessWidget {
  final List<IrrigationScheduleEntity> schedules;
  final ValueChanged<IrrigationScheduleEntity> onSaveSchedule;
  final ValueChanged<String> onDeleteSchedule;
  final Function(String id, bool enabled) onToggleEnabled;

  const IrrigationSchedulesList({
    super.key,
    required this.schedules,
    required this.onSaveSchedule,
    required this.onDeleteSchedule,
    required this.onToggleEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final daysLabelsAr = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
    final daysLabelsEn = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final dayNames = isArabic ? daysLabelsAr : daysLabelsEn;

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
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'جداول الري المبرمجة' : 'Automated Irrigation Schedules',
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
            TextButton.icon(
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: Text(
                isArabic ? 'إضافة جدول' : 'Add Schedule',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                ScheduleAddEditDialog.show(
                  context,
                  onSave: onSaveSchedule,
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (schedules.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Center(
              child: Text(
                isArabic ? 'لا توجد جداول ري مبرمجة' : 'No schedules configured yet',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ] else ...[
          ...schedules.map((schedule) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: schedule.isEnabled
                      ? AppColors.primaryGreen.withValues(alpha: 0.4)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            schedule.zoneName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Switch(
                            value: schedule.isEnabled,
                            activeThumbColor: AppColors.primaryGreen,
                            activeTrackColor:
                                AppColors.primaryGreen.withValues(alpha: 0.3),
                            onChanged: (val) {
                              onToggleEnabled(schedule.id, val);
                            },
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.more_vert_rounded, size: 18),
                            onSelected: (action) {
                              if (action == 'edit') {
                                ScheduleAddEditDialog.show(
                                  context,
                                  initialSchedule: schedule,
                                  onSave: onSaveSchedule,
                                );
                              } else if (action == 'delete') {
                                onDeleteSchedule(schedule.id);
                              }
                            },
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(isArabic ? 'تعديل' : 'Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  isArabic ? 'حذف' : 'Delete',
                                  style: const TextStyle(
                                      color: AppColors.sensorAlert),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 14, color: AppColors.flowBlue),
                      const SizedBox(width: 4),
                      Text(
                        '${schedule.startTime.format(context)} • ${schedule.durationMinutes} ${isArabic ? 'دقيقة' : 'mins'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.flowBlue,
                        ),
                      ),
                      if (schedule.nextRunTime != null && schedule.isEnabled) ...[
                        const Spacer(),
                        Text(
                          isArabic ? 'التشغيل القادم بعد 8 س' : 'Next in 8h',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Days Pills
                  Wrap(
                    spacing: 6,
                    children: schedule.daysOfWeek.map((dayIdx) {
                      final label = (dayIdx >= 0 && dayIdx < dayNames.length)
                          ? dayNames[dayIdx]
                          : '$dayIdx';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.backgroundDark
                              : AppColors.primaryGreenSurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primaryGreen
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreenDark,
                          ),
                        ),
                      );
                    }).toList(),
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
