import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Card presenting controller-side hardware protections and safety interlocks.
class HardwareSafetyCard extends StatelessWidget {
  const HardwareSafetyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final safeguards = [
      _SafeguardItem(
        titleAr: 'حماية التشغيل الجاف (Dry-Run Protection)',
        titleEn: 'Dry-Run Protection Lockout',
        descAr: 'فصل فوري للمضخة إذا لم يتدفق الماء خلال 15 ثانية لحماية التوربينة.',
        descEn: 'Automatic pump shutdown if flow rate is zero within 15s to save motor.',
        icon: Icons.shield_rounded,
        color: AppColors.primaryGreen,
      ),
      _SafeguardItem(
        titleAr: 'حساس منسوب البئر والخزان (Low-Level Cutoff)',
        titleEn: 'Groundwater / Tank Level Interlock',
        descAr: 'إغلاق التشغيل آلياً إذا انخفض منسوب المياه عن عمق 45 متراً لتفادي السحب الهوائي.',
        descEn: 'Cuts off pump if water table drops below critical suction depth.',
        icon: Icons.water_drop_rounded,
        color: AppColors.flowBlue,
      ),
      _SafeguardItem(
        titleAr: 'مؤقت الأمان للأعطال (Watchdog Timer - 90 Min)',
        titleEn: 'Controller Watchdog Limit (90 Mins)',
        descAr: 'وحدة أمان مدمجة داخل معالج ESP32 توقف الري تلقائياً حتى في حال انقطاع الإنترنت.',
        descEn: 'Hardware RTC cutoff stops pump independently of mobile app connectivity.',
        icon: Icons.timer_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _SafeguardItem(
        titleAr: 'صمامات كهربائية مغلقة طبيعياً (Normally Closed)',
        titleEn: 'Failsafe Normally-Closed Valves',
        descAr: 'محابس تغلق تلقائياً بمجرد انقطاع التيار الكهربائي لمنع أي تسريب مائي.',
        descEn: 'Valves seal closed on power outage to ensure zero field flooding.',
        icon: Icons.power_off_rounded,
        color: const Color(0xFF6366F1),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primaryGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic ? 'منظومة الحماية والأمان العتادية' : 'Hardware Safety Safeguards',
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

          const SizedBox(height: 14),

          ...safeguards.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.icon, size: 16, color: item.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? item.titleAr : item.titleEn,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isArabic ? item.descAr : item.descEn,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SafeguardItem {
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final IconData icon;
  final Color color;

  const _SafeguardItem({
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    required this.icon,
    required this.color,
  });
}
