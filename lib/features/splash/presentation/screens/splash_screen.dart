import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/app.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/iot_pulse_indicator.dart';
import '../../../../core/widgets/status_badge.dart';

/// Modern, animated splash screen showcasing Green Flow branding,
/// agricultural IoT ecosystem readiness, and bilingual (EN/AR) responsiveness.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  int _telemetryStage = 0;
  Timer? _telemetryTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutCubic,
      ),
    );

    _mainController.forward();

    // Telemetry cycle simulation to demonstrate IoT sensor handshake
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (mounted && _telemetryStage < 2) {
        setState(() {
          _telemetryStage++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _navigationTimer?.cancel();
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final size = MediaQuery.sizeOf(context);

    final telemetryLabelsEn = [
      'Calibrating Soil & Ambient Sensors...',
      'Connecting ESP32 Mesh Gateway...',
      'IoT Telemetry & Smart Irrigation Online',
    ];

    final telemetryLabelsAr = [
      'معايرة مجسات التربة والبيئة...',
      'الاتصال ببوابة شبكة ESP32...',
      'جاهزية أتمتة الري وإنترنت الأشياء نشطة',
    ];

    final currentTelemetryLabel = isArabic
        ? telemetryLabelsAr[_telemetryStage]
        : telemetryLabelsEn[_telemetryStage];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 1. Ambient Background Glows
              Positioned(
                top: -size.width * 0.25,
                left: -size.width * 0.2,
                child: Container(
                  width: size.width * 0.9,
                  height: size.width * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: -size.width * 0.3,
                right: -size.width * 0.2,
                child: Container(
                  width: size.width * 1.0,
                  height: size.width * 1.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.flowBlue.withValues(alpha: 0.10),
                  ),
                ),
              ),

              // 2. Top Bar: Language Switcher & Version Badge
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // System Mode Badge
                    StatusBadge(
                      label: isArabic ? 'نظام زراعي ذكي' : 'Smart Agri IoT',
                      color: AppColors.primaryGreenLight,
                      icon: Icons.eco_rounded,
                    ),

                    // Language Toggle (Allows instant live testing of LTR/RTL)
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
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.language_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isArabic ? 'English' : 'العربية',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Central Brand Experience
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Logo with subtle breathing pulse
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                final breathingScale =
                                    1.0 + (_pulseController.value * 0.035);
                                return Transform.scale(
                                  scale: breathingScale,
                                  child: child,
                                );
                              },
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: const GreenFlowLogo(
                                  size: 140,
                                  showGlow: true,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Brand Title with Gradient Shader
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.brandGradient.createShader(bounds),
                              child: Text(
                                isArabic
                                    ? AppConstants.appNameAr
                                    : AppConstants.appName,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Tagline (Bilingual)
                            Text(
                              isArabic
                                  ? AppConstants.appTaglineAr
                                  : AppConstants.appTaglineEn,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE2E8F0),
                                letterSpacing: 0.3,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Subtext / Capabilities
                            Text(
                              isArabic
                                  ? AppConstants.appSubtextAr
                                  : AppConstants.appSubtextEn,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.65),
                                letterSpacing: 0.2,
                              ),
                            ),

                            const SizedBox(height: 40),

                            // IoT Feature Badges (Horizontal Row)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                StatusBadge(
                                  label: isArabic
                                      ? 'رطوبة التربة'
                                      : 'Soil Moisture',
                                  color: AppColors.primaryGreenLight,
                                  icon: Icons.grass_rounded,
                                ),
                                StatusBadge(
                                  label: isArabic
                                      ? 'صمامات الري'
                                      : 'Smart Valves',
                                  color: AppColors.flowBlueLight,
                                  icon: Icons.water_drop_rounded,
                                ),
                                StatusBadge(
                                  label: isArabic ? 'عقد ESP32' : 'ESP32 Telemetry',
                                  color: AppColors.sensorOnline,
                                  icon: Icons.sensors_rounded,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Bottom IoT Initialization Status & Action
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // IoT Telemetry Status Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IotPulseIndicator(
                              size: 10,
                              color: _telemetryStage == 2
                                  ? AppColors.sensorOnline
                                  : AppColors.flowBlueLight,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                currentTelemetryLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFF1F5F9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Manual Explore / Next button for previewing navigation
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _navigateToNext,
                          icon: Icon(
                            isArabic
                                ? Icons.arrow_back_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isArabic ? 'دخول التطبيق' : 'Enter Application',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
