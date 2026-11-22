import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/file_io.dart' as file_io;
import '../../../../core/widgets/app_logo.dart';

/// Clean, nature-inspired Splash Screen faithfully matching the Green Flow reference design.
/// Features the Green Flow logo, brand typography, subtitle, lower agricultural landscape,
/// and smooth circular loading animation with bilingual status.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navTimer;

  static const String _onboardingPrefFile = '.greenflow_onboarding_pref';

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();

    // 2.8s smooth splash delay, checking onboarding completion
    _navTimer = Timer(const Duration(milliseconds: 2800), _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;

    final pref = file_io.readFileSync(_onboardingPrefFile)?.trim();
    final bool hasCompletedOnboarding = pref == 'completed';

    if (hasCompletedOnboarding) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Subtle natural leaf decorations in background corners
          Positioned(
            top: -20,
            left: -20,
            child: Opacity(
              opacity: 0.18,
              child: Transform.rotate(
                angle: 0.4,
                child: const Icon(
                  Icons.eco_rounded,
                  size: 140,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: -30,
            child: Opacity(
              opacity: 0.12,
              child: Transform.rotate(
                angle: -0.6,
                child: const Icon(
                  Icons.eco_rounded,
                  size: 110,
                  color: AppColors.primaryGreenLight,
                ),
              ),
            ),
          ),

          // Lower Section: Natural Agricultural Landscape
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.40,
            child: CustomPaint(
              painter: _SplashLandscapePainter(),
            ),
          ),

          // Center Branding Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Animated Logo and Typography
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Iconic Double Leaf Emblem
                        const GreenFlowLogo(size: 110),
                        const SizedBox(height: 18),

                        // Brand Name "Green Flow"
                        const Text(
                          'Green Flow',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: AppColors.primaryGreenDark,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle: "— Smart Agriculture —"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 1.5,
                              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Smart Agriculture',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.8,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 24,
                              height: 1.5,
                              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 4),

                // Lower section: Circular loading indicator & status
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.2,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                            backgroundColor: AppColors.softSage.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          isArabic
                              ? 'جاري تجهيز تجربتك الذكية ...'
                              : 'Preparing your smart experience...',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the lower natural agricultural landscape seen in the design reference.
class _SplashLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Distant morning misty hills
    final distantHill = Paint()..color = const Color(0xFFC7D2FE).withValues(alpha: 0.35);
    final dPath = Path()
      ..moveTo(0, h * 0.35)
      ..cubicTo(w * 0.3, h * 0.28, w * 0.6, h * 0.38, w, h * 0.30)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(dPath, distantHill);

    // Warm morning sun glow horizon
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.4),
        radius: 0.8,
        colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.6));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.6), glowPaint);

    // Treeline silhouette along horizon
    final treePaint = Paint()..color = const Color(0xFF14532D).withValues(alpha: 0.55);
    for (double x = 0; x < w; x += 14) {
      canvas.drawCircle(Offset(x, h * 0.36), 7, treePaint);
    }

    // Rich perspective agricultural crop rows
    final fieldPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF15803D),
          Color(0xFF166534),
          Color(0xFF14532D),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.38, w, h * 0.62));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.38, w, h * 0.62), fieldPaint);

    // Perspective furrow lines with detailed lush green crops
    final furrowPaint = Paint()
      ..color = const Color(0xFF0F3E1E)
      ..strokeWidth = 2.0;
    final plantPaint = Paint()..color = const Color(0xFF22C55E);

    final vanishPoint = Offset(w * 0.5, h * 0.38);

    for (int i = 0; i <= 10; i++) {
      final bottomX = -w * 0.2 + (w * 1.4) * (i / 10);
      canvas.drawLine(vanishPoint, Offset(bottomX, h), furrowPaint);

      // Plant mounds along furrow
      for (double t = 0.15; t <= 1.0; t += 0.12) {
        final cx = vanishPoint.dx + (bottomX - vanishPoint.dx) * t;
        final cy = vanishPoint.dy + (h - vanishPoint.dy) * t;
        final r = 2.5 + t * 6.5;
        canvas.drawCircle(Offset(cx - 3, cy), r, plantPaint);
        canvas.drawCircle(Offset(cx + 3, cy), r * 0.9, plantPaint);
      }
    }

    // Organic soft top wave overlay transition into white
    final topWave = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.backgroundLight,
          AppColors.backgroundLight.withValues(alpha: 0.75),
          Colors.transparent,
        ],
        stops: const [0.0, 0.28, 0.55],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), topWave);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
