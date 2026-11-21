import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Timer widget allowing custom timed irrigation cycles with automatic cutoff.
class IrrigationTimerWidget extends StatefulWidget {
  final Duration? activeDuration;
  final DateTime? timerStartedAt;
  final ValueChanged<Duration> onStartTimer;
  final VoidCallback onCancelTimer;

  const IrrigationTimerWidget({
    super.key,
    this.activeDuration,
    this.timerStartedAt,
    required this.onStartTimer,
    required this.onCancelTimer,
  });

  @override
  State<IrrigationTimerWidget> createState() => _IrrigationTimerWidgetState();
}

class _IrrigationTimerWidgetState extends State<IrrigationTimerWidget> {
  int _selectedMinutes = 30;

  final List<int> _durations = [15, 30, 45, 60, 90];

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isTimerActive = widget.activeDuration != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTimerActive
              ? AppColors.flowBlue
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isTimerActive ? 1.5 : 1.0,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.flowBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.timer_rounded,
                      color: AppColors.flowBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'مؤقت الري المحدد' : 'Irrigation Countdown Timer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              if (isTimerActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.flowBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isArabic ? 'مؤقت نشط' : 'Active Timer',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.flowBlue,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          if (isTimerActive) ...[
            // Active Timer Countdown Visual Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.flowBlueSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.flowBlue),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic
                              ? 'جاري الري لمدة ${widget.activeDuration!.inMinutes} دقيقة'
                              : 'Irrigating for ${widget.activeDuration!.inMinutes} minutes',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isArabic
                              ? 'سيتم الإيقاف الآلي فور انتهاء المؤقت عبر وحدة التحكم'
                              : 'Auto cutoff enforced by ESP32 upon expiration',
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
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.sensorAlert,
                    ),
                    onPressed: widget.onCancelTimer,
                    child: Text(
                      isArabic ? 'إلغاء' : 'Cancel',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Duration selector chips
            Text(
              isArabic
                  ? 'اختر مدة الري بالدقائق:'
                  : 'Select irrigation duration:',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _durations.map((mins) {
                final isSelected = _selectedMinutes == mins;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          _selectedMinutes = mins;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.flowBlue
                              : (isDark
                                  ? AppColors.backgroundDark
                                  : AppColors.backgroundLight),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.flowBlue
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$mins ${isArabic ? 'د' : 'm'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.flowBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(
                isArabic
                    ? 'بدء الري المؤقت ($_selectedMinutes دقيقة)'
                    : 'Start Timed Irrigation ($_selectedMinutes mins)',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                widget.onStartTimer(Duration(minutes: _selectedMinutes));
              },
            ),
          ],
        ],
      ),
    );
  }
}
