import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../widgets/onboarding_illustration.dart';

/// Interactive 3-screen Onboarding experience for Green Flow.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.authentication);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titles = [
      AppStrings.onboardingTitle1(context),
      AppStrings.onboardingTitle2(context),
      AppStrings.onboardingTitle3(context),
    ];

    final descriptions = [
      AppStrings.onboardingDesc1(context),
      AppStrings.onboardingDesc2(context),
      AppStrings.onboardingDesc3(context),
    ];

    final badges = [
      isArabic ? 'الذكاء الزراعي' : 'Agri-Tech AI',
      isArabic ? 'توفير المياه' : 'Precision Flow',
      isArabic ? 'مجسات ESP32' : 'IoT Telemetry',
    ];

    final badgeIcons = [
      Icons.auto_awesome_rounded,
      Icons.water_drop_rounded,
      Icons.sensors_rounded,
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip button & Language switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language Toggle
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      final newLocale = isArabic
                          ? const Locale('en')
                          : const Locale('ar');
                      GreenFlowApp.setLocale(context, newLocale);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark
                            : AppColors.primaryGreenSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.primaryGreen.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.language_rounded,
                            size: 15,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isArabic ? 'English' : 'العربية',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.primaryGreenDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Skip Action
                  if (_currentIndex < 2)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        AppStrings.skip(context),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Page Content (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final double illustrationSize =
                          (constraints.maxHeight * 0.42).clamp(140.0, 230.0);

                      return Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 8,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Pillar Badge
                              StatusBadge(
                                label: badges[index],
                                color: index == 1
                                    ? AppColors.flowBlue
                                    : AppColors.primaryGreen,
                                icon: badgeIcons[index],
                              ),

                              const SizedBox(height: 20),

                              // Custom Vector Illustration
                              OnboardingIllustration(
                                pageIndex: index,
                                size: illustrationSize,
                              ),

                              const SizedBox(height: 24),

                              // Title
                              Text(
                                titles[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                  letterSpacing: 0.3,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Description
                              Text(
                                descriptions[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot Page Indicators
                  Row(
                    children: List.generate(3, (index) {
                      final isSelected = _currentIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next / Get Started Button
                  SizedBox(
                    width: _currentIndex == 2 ? 160 : 120,
                    height: 48,
                    child: CustomButton(
                      label: _currentIndex == 2
                          ? AppStrings.getStarted(context)
                          : AppStrings.next(context),
                      icon: _currentIndex == 2
                          ? Icons.rocket_launch_rounded
                          : (isArabic
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_forward_rounded),
                      onPressed: _onNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
