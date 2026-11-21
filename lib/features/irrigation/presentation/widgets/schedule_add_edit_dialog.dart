import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/irrigation_entities.dart';

/// Modal dialog for adding or editing an automated irrigation schedule.
class ScheduleAddEditDialog extends StatefulWidget {
  final IrrigationScheduleEntity? initialSchedule;
  final ValueChanged<IrrigationScheduleEntity> onSave;

  const ScheduleAddEditDialog({
    super.key,
    this.initialSchedule,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    IrrigationScheduleEntity? initialSchedule,
    required ValueChanged<IrrigationScheduleEntity> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScheduleAddEditDialog(
        initialSchedule: initialSchedule,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ScheduleAddEditDialog> createState() => _ScheduleAddEditDialogState();
}

class _ScheduleAddEditDialogState extends State<ScheduleAddEditDialog> {
  late TimeOfDay _startTime;
  late int _durationMinutes;
  late List<int> _selectedDays;
  late bool _isEnabled;

  String _selectedZone = 'المنطقة أ - زيتون شرقي';

  final List<String> _zones = [
    'المنطقة أ - زيتون شرقي',
    'المنطقة ب - نخيل البرحي',
    'المنطقة ج - حزام الموالح والليمون',
    'قطاع المجدول النموذجي',
  ];

  final List<String> _daysShortAr = [
    'سبت',
    'أحد',
    'اثنين',
    'ثلاثاء',
    'أربعاء',
    'خميس',
    'جمعة',
  ];

  final List<String> _daysShortEn = [
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.initialSchedule;
    _startTime = s?.startTime ?? const TimeOfDay(hour: 6, minute: 0);
    _durationMinutes = s?.durationMinutes ?? 45;
    _selectedDays = s != null ? List<int>.from(s.daysOfWeek) : [0, 2, 4];
    _isEnabled = s?.isEnabled ?? true;
    if (s != null && _zones.contains(s.zoneName)) {
      _selectedZone = s.zoneName;
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.flowBlue,
              primary: AppColors.flowBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  void _toggleDay(int index) {
    setState(() {
      if (_selectedDays.contains(index)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(index);
        }
      } else {
        _selectedDays.add(index);
        _selectedDays.sort();
      }
    });
  }

  void _onSave() {
    final schedule = IrrigationScheduleEntity(
      id: widget.initialSchedule?.id ??
          'sched-${DateTime.now().millisecondsSinceEpoch}',
      farmId: 'farm-001',
      farmName: 'مزرعة الأمل للزيتون والنخيل',
      zoneId: 'zone-001',
      zoneName: _selectedZone,
      startTime: _startTime,
      durationMinutes: _durationMinutes,
      daysOfWeek: _selectedDays,
      isEnabled: _isEnabled,
      nextRunTime: DateTime.now().add(const Duration(hours: 12)),
    );

    widget.onSave(schedule);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayNames = isArabic ? _daysShortAr : _daysShortEn;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              widget.initialSchedule != null
                  ? (isArabic ? 'تعديل جدول الري' : 'Edit Irrigation Schedule')
                  : (isArabic ? 'إنشاء جدول ري ذكي جديد' : 'New Smart Schedule'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 16),

            // Zone selector
            Text(
              isArabic ? 'اختر قطاع الري:' : 'Select Irrigation Zone:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedZone,
                  isExpanded: true,
                  items: _zones.map((z) {
                    return DropdownMenuItem(
                      value: z,
                      child: Text(z, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedZone = val);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Start Time Picker
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'وقت البدء:' : 'Start Time:',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 18, color: AppColors.flowBlue),
                              const SizedBox(width: 8),
                              Text(
                                _startTime.format(context),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'المدة (دقيقة):' : 'Duration (min):',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_durationMinutes ${isArabic ? 'دقيقة' : 'mins'}',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (_durationMinutes > 15) {
                                      setState(() => _durationMinutes -= 15);
                                    }
                                  },
                                  child: const Icon(Icons.remove_circle_outline,
                                      size: 20),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    if (_durationMinutes < 180) {
                                      setState(() => _durationMinutes += 15);
                                    }
                                  },
                                  child: const Icon(Icons.add_circle_outline,
                                      size: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Days of the week multi-select
            Text(
              isArabic ? 'أيام التشغيل الأسبوعية:' : 'Days of Operation:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isSelected = _selectedDays.contains(index);
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _toggleDay(index),
                  child: Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : (isDark
                              ? AppColors.cardDark
                              : AppColors.backgroundLight),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dayNames[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 14),

            // Enable switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primaryGreen,
              title: Text(
                isArabic ? 'تفعيل الجدول فور الحفظ' : 'Enable Schedule on Save',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              value: _isEnabled,
              onChanged: (val) {
                setState(() => _isEnabled = val);
              },
            ),

            const SizedBox(height: 20),

            CustomButton(
              label: isArabic ? 'حفظ جدول الري' : 'Save Schedule',
              icon: Icons.check_circle_rounded,
              onPressed: _onSave,
            ),
          ],
        ),
      ),
    );
  }
}
