import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';

/// Modal dialog for confirming and triggering an Emergency Stop (E-Stop).
class EmergencyStopModal extends StatefulWidget {
  final ValueChanged<String> onConfirmEmergencyStop;

  const EmergencyStopModal({
    super.key,
    required this.onConfirmEmergencyStop,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EmergencyStopModal(
        onConfirmEmergencyStop: onConfirm,
      ),
    );
  }

  @override
  State<EmergencyStopModal> createState() => _EmergencyStopModalState();
}

class _EmergencyStopModalState extends State<EmergencyStopModal> {
  String _selectedReason = 'تسريب مياه أو كسر في خط التوزيع';

  final List<String> _reasonsAr = [
    'تسريب مياه أو كسر في خط التوزيع',
    'صوت غير طبيعي أو اهتزاز في المضخة',
    'انخفاض حاد في منسوب البئر (خطر التشغيل الجاف)',
    'أعمال صيانة طارئة في الحقل',
    'إيقاف وقائي عام',
  ];

  final List<String> _reasonsEn = [
    'Water leak or burst pipeline detected',
    'Abnormal pump cavitation or vibration',
    'Critical low well level (dry-run risk)',
    'Emergency field maintenance work',
    'General manual safety shutdown',
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reasons = isArabic ? _reasonsAr : _reasonsEn;

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

          // Red Warning Icon Header
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.sensorAlert.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.sensorAlert,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            isArabic ? 'تفعيل إيقاف الطوارئ (E-STOP)' : 'Emergency Stop (E-Stop)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.sensorAlert,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(
            isArabic
                ? 'سيتم فوراً قطع التيار عن طلمبات الري وإغلاق كافة الصمامات الكهربائية وحماية الآبار والمعدات.'
                : 'Will immediately cut power to all irrigation pumps, shut solenoid valves, and protect well equipment.',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            isArabic ? 'سبب إيقاف الطوارئ:' : 'Reason for Emergency Stop:',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          // Reason radio selection
          RadioGroup<String>(
            groupValue: _selectedReason,
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedReason = val);
              }
            },
            child: Column(
              children: reasons.map((r) {
                final isSelected = _selectedReason == r;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.sensorAlert.withValues(alpha: 0.1)
                        : (isDark
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.sensorAlert
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: r,
                    dense: true,
                    activeColor: AppColors.sensorAlert,
                    title: Text(
                      r,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Confirm Emergency Button
          CustomButton(
            label: isArabic
                ? 'تأكيد إيقاف الطوارئ الفوري'
                : 'Confirm Emergency Shutdown Now',
            icon: Icons.dangerous_rounded,
            onPressed: () {
              Navigator.pop(context);
              widget.onConfirmEmergencyStop(_selectedReason);
            },
          ),

          const SizedBox(height: 10),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel(context)),
          ),
        ],
      ),
    );
  }
}
