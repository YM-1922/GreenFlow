import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/file_io.dart' as file_io;
import '../widgets/onboarding_illustration.dart';

/// Interactive 3-screen Onboarding experience for Green Flow.
/// Recreates the reference design layout, typography, navigation controls,
/// and smooth horizontal page transitions with RTL/LTR responsiveness.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const String _onboardingPrefFile = '.greenflow_onboarding_pref';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _finishOnboarding() {
    file_io.writeFileSync(_onboardingPrefFile, 'completed');
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _toggleLanguage() {
    final isArabic = AppStrings.isArabic(context);
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');
    GreenFlowApp.setLocale(context, newLocale);
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip button on start & Language dropdown badge on end
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button (visible on screens 1 & 2, or replaced with spacer)
                  _currentIndex < 2
                      ? TextButton(
                          onPressed: _finishOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryGreenDark,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          child: Text(
                            AppStrings.skip(context),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreenDark,
                            ),
                          ),
                        )
                      : const SizedBox(width: 48),

                  // Language Dropdown Selector Badge
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _toggleLanguage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            size: 16,
                            color: AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isArabic ? 'العربية' : 'English',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: AppColors.textSecondaryLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Middle: Illustration & Text content inside horizontal PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),

                        // Scenic Visual Illustration
                        OnboardingIllustration(
                          pageIndex: index,
                          height: MediaQuery.of(context).size.height * 0.38,
                        ),

                        const Spacer(flex: 2),

                        // Title
                        Text(
                          titles[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: AppColors.primaryGreenDark,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            descriptions[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14.5,
                              height: 1.55,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Animated Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isSelected = _currentIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),

            const SizedBox(height: 28),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _buildBottomActions(isArabic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isArabic) {
    if (_currentIndex == 0) {
      // Screen 1: Full-width Next Button with Arrow
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 2,
          shadowColor: AppColors.primaryGreen.withValues(alpha: 0.35),
        ),
        onPressed: _onNext,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.next(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Icon(
              isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
              size: 20,
            ),
          ],
        ),
      );
    } else if (_currentIndex == 1) {
      // Screen 2: Next (Primary Green) and Previous (Light Pill Button)
      return Row(
        children: [
          // Next Button
          Expanded(
            flex: 3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 2,
                shadowColor: AppColors.primaryGreen.withValues(alpha: 0.35),
              ),
              onPressed: _onNext,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.next(context),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Previous Button (Soft White Pill matching reference)
          Expanded(
            flex: 2,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimaryLight,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 1,
                shadowColor: Colors.black.withValues(alpha: 0.04),
              ),
              onPressed: _onPrevious,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.previous(context),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      // Screen 3: "ابدأ الآن" / "Get Started" Full-width Button
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 2,
          shadowColor: AppColors.primaryGreen.withValues(alpha: 0.35),
        ),
        onPressed: _finishOnboarding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.getStarted(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Icon(
              isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
              size: 20,
            ),
          ],
        ),
      );
    }
  }
}
