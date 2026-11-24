import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Professional Material 3 Bottom Navigation Bar for Green Flow.
/// Features smooth animated active pills and emerald glow indicators.
class GreenFlowBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const GreenFlowBottomNav({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _NavItem(
        label: AppStrings.navHome(context),
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
      ),
      _NavItem(
        label: AppStrings.navIrrigation(context),
        icon: Icons.water_drop_outlined,
        activeIcon: Icons.water_drop_rounded,
      ),
      _NavItem(
        label: AppStrings.navDevices(context),
        icon: Icons.sensors_outlined,
        activeIcon: Icons.sensors_rounded,
      ),
      _NavItem(
        label: AppStrings.navReports(context),
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
      ),
      _NavItem(
        label: AppStrings.navAccount(context),
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              final item = items[index];

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onIndexChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 12 : 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AppColors.primaryGreen.withValues(alpha: 0.18)
                            : AppColors.primaryGreenSurface)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 20,
                        color: isSelected
                            ? AppColors.primaryGreen
                            : (isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
