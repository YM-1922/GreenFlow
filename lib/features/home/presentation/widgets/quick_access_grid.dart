import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../screens/farmer_shell.dart';

/// Quick Access Navigation Cards Grid for Green Flow.
/// Directs users to My Farms, Devices, Irrigation, and Analytics module stubs.
class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _QuickAccessItem(
        title: AppStrings.myFarms(context),
        subtitle: isArabic ? '3 مواقع وحقول' : '3 Fields & Zones',
        icon: Icons.landscape_rounded,
        color: AppColors.primaryGreen,
        route: AppRoutes.farms,
      ),
      _QuickAccessItem(
        title: AppStrings.devices(context),
        subtitle: isArabic ? '18 مجس ومحبس' : '18 ESP32 Nodes',
        icon: Icons.sensors_rounded,
        color: AppColors.flowBlue,
        route: AppRoutes.devices,
      ),
      _QuickAccessItem(
        title: AppStrings.irrigation(context),
        subtitle: isArabic ? 'جداول وتحكم' : 'Schedules & Flow',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF06B6D4), // Cyan
        route: AppRoutes.irrigation,
      ),
      _QuickAccessItem(
        title: AppStrings.analytics(context),
        subtitle: isArabic ? 'تقارير بيئية' : 'Eco & Crop Reports',
        icon: Icons.insights_rounded,
        color: const Color(0xFF8B5CF6), // Purple
        route: AppRoutes.analytics,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              AppStrings.quickAccess(context),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                letterSpacing: 0.2,
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
              children: items.map((item) {
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (item.route == AppRoutes.farms) {
                      FarmerShell.switchTab(context, 1);
                    } else if (item.route == AppRoutes.irrigation) {
                      FarmerShell.switchTab(context, 3);
                    } else if (item.route == AppRoutes.analytics) {
                      FarmerShell.switchTab(context, 2);
                    } else {
                      Navigator.pushNamed(context, item.route);
                    }
                  },
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
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
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _QuickAccessItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickAccessItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
