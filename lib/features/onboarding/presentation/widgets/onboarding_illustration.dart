import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Custom vector-drawn illustrations representing Green Flow's 3 core pillars:
/// 1. Smart Agriculture
/// 2. Smart Irrigation
/// 3. Plant & Sensor Monitoring
class OnboardingIllustration extends StatelessWidget {
  final int pageIndex;
  final double size;

  const OnboardingIllustration({
    super.key,
    required this.pageIndex,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (pageIndex == 1 ? AppColors.flowBlue : AppColors.primaryGreen)
                .withValues(alpha: 0.22),
            blurRadius: size * 0.35,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _OnboardingIllustrationPainter(pageIndex: pageIndex),
      ),
    );
  }
}

class _OnboardingIllustrationPainter extends CustomPainter {
  final int pageIndex;

  _OnboardingIllustrationPainter({required this.pageIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Common Background circular gradient plate
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (pageIndex == 1 ? AppColors.flowBlueSurface : AppColors.primaryGreenSurface)
              .withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.48))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, w * 0.48, bgPaint);

    // Outer subtle border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = SweepGradient(
        colors: [
          pageIndex == 1 ? AppColors.flowBlueLight : AppColors.primaryGreenLight,
          pageIndex == 1 ? AppColors.flowBlueDark : AppColors.primaryGreenDark,
          pageIndex == 1 ? AppColors.flowBlueLight : AppColors.primaryGreenLight,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.48));

    canvas.drawCircle(center, w * 0.48, borderPaint);

    switch (pageIndex) {
      case 0:
        _drawSmartAgriculture(canvas, size);
        break;
      case 1:
        _drawSmartIrrigation(canvas, size);
        break;
      case 2:
      default:
        _drawPlantMonitoring(canvas, size);
        break;
    }
  }

  // 1. SMART AGRICULTURE: Rolling crop fields, sun, smart broadcast signals, crop plant
  void _drawSmartAgriculture(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sun / Ambient Energy
    final sunPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.28), w * 0.14, sunPaint);

    // Wireless IoT Orbit Rings
    final orbitPaint = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.28), radius: w * 0.22),
      math.pi * 0.7,
      math.pi * 1.6,
      false,
      orbitPaint,
    );

    // Rolling Green Farm Fields
    final hill1 = Path();
    hill1.moveTo(w * 0.05, h * 0.75);
    hill1.quadraticBezierTo(w * 0.35, h * 0.55, w * 0.95, h * 0.78);
    hill1.lineTo(w * 0.95, h * 0.92);
    hill1.lineTo(w * 0.05, h * 0.92);
    hill1.close();

    final hill1Paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primaryGreenLight, AppColors.primaryGreen],
      ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.4));
    canvas.drawPath(hill1, hill1Paint);

    final hill2 = Path();
    hill2.moveTo(w * 0.05, h * 0.85);
    hill2.quadraticBezierTo(w * 0.65, h * 0.65, w * 0.95, h * 0.82);
    hill2.lineTo(w * 0.95, h * 0.95);
    hill2.lineTo(w * 0.05, h * 0.95);
    hill2.close();

    final hill2Paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primaryGreen, AppColors.primaryGreenDark],
      ).createShader(Rect.fromLTWH(0, h * 0.6, w, h * 0.4));
    canvas.drawPath(hill2, hill2Paint);

    // Central Sprouting Smart Crop
    final stemPaint = Paint()
      ..color = AppColors.primaryGreenDark
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.75), Offset(w * 0.5, h * 0.42), stemPaint);

    // Leaves
    final leafPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;

    // Left Leaf
    final leftLeaf = Path();
    leftLeaf.moveTo(w * 0.5, h * 0.55);
    leftLeaf.quadraticBezierTo(w * 0.32, h * 0.48, w * 0.35, h * 0.38);
    leftLeaf.quadraticBezierTo(w * 0.48, h * 0.44, w * 0.5, h * 0.55);
    canvas.drawPath(leftLeaf, leafPaint);

    // Right Leaf
    final rightLeaf = Path();
    rightLeaf.moveTo(w * 0.5, h * 0.50);
    rightLeaf.quadraticBezierTo(w * 0.68, h * 0.44, w * 0.65, h * 0.32);
    rightLeaf.quadraticBezierTo(w * 0.52, h * 0.38, w * 0.5, h * 0.50);
    canvas.drawPath(rightLeaf, leafPaint);

    // Top IoT Sensor Node on Crop
    final nodePaint = Paint()
      ..color = AppColors.flowBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.40), w * 0.035, nodePaint);

    final nodeInner = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.5, h * 0.40), w * 0.015, nodeInner);
  }

  // 2. SMART IRRIGATION: Precision water droplet, pipes, solenoid valve, spray
  void _drawSmartIrrigation(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Central Fluid Droplet
    final dropPath = Path();
    dropPath.moveTo(w * 0.5, h * 0.22);
    dropPath.cubicTo(w * 0.75, h * 0.48, w * 0.75, h * 0.72, w * 0.5, h * 0.82);
    dropPath.cubicTo(w * 0.25, h * 0.72, w * 0.25, h * 0.48, w * 0.5, h * 0.22);
    dropPath.close();

    final dropPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.flowBlueLight, AppColors.flowBlue, AppColors.flowBlueDark],
      ).createShader(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.6, h * 0.6));
    canvas.drawPath(dropPath, dropPaint);

    // Droplet Shimmer / Highlight
    final highlightPath = Path();
    highlightPath.moveTo(w * 0.44, h * 0.32);
    highlightPath.quadraticBezierTo(w * 0.35, h * 0.48, w * 0.38, h * 0.62);
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(highlightPath, highlightPaint);

    // Automated Irrigation Horizontal Pipeline & Valve
    final pipePaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.15, h * 0.78), Offset(w * 0.85, h * 0.78), pipePaint);

    // Smart Solenoid Valve Body
    final valveRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.78), width: 34, height: 26);
    final valvePaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(valveRect, const Radius.circular(6)), valvePaint);

    // Valve Top Actuator
    final actuatorRect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.68), width: 18, height: 12);
    final actuatorPaint = Paint()
      ..color = AppColors.primaryGreenDark
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(actuatorRect, const Radius.circular(4)), actuatorPaint);

    // Water Droplet Micro-Sprays
    final sprayPaint = Paint()
      ..color = AppColors.flowBlueLight
      ..style = PaintingStyle.fill;
    final sprays = [
      Offset(w * 0.38, h * 0.88),
      Offset(w * 0.50, h * 0.92),
      Offset(w * 0.62, h * 0.88),
      Offset(w * 0.28, h * 0.86),
      Offset(w * 0.72, h * 0.86),
    ];
    for (final s in sprays) {
      canvas.drawCircle(s, 4, sprayPaint);
    }
  }

  // 3. PLANT & SENSOR MONITORING: Soil cross section, ESP32 telemetry probe, wave indicators
  void _drawPlantMonitoring(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soil Cross-Section Layer
    final soilRect = Rect.fromLTWH(w * 0.15, h * 0.62, w * 0.7, h * 0.28);
    final soilPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF78350F), Color(0xFF451A03)],
      ).createShader(soilRect);
    canvas.drawRRect(RRect.fromRectAndRadius(soilRect, const Radius.circular(16)), soilPaint);

    // Grass Top on Soil
    final grassPaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.15, h * 0.62), Offset(w * 0.85, h * 0.62), grassPaint);

    // Plant Growing Upwards
    final stem = Path();
    stem.moveTo(w * 0.40, h * 0.62);
    stem.quadraticBezierTo(w * 0.38, h * 0.40, w * 0.42, h * 0.28);
    final stemPaint = Paint()
      ..color = AppColors.primaryGreenDark
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(stem, stemPaint);

    // Plant Leaves
    final leafPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;
    final l1 = Path()
      ..moveTo(w * 0.40, h * 0.45)
      ..quadraticBezierTo(w * 0.25, h * 0.40, w * 0.28, h * 0.32)
      ..quadraticBezierTo(w * 0.38, h * 0.36, w * 0.40, h * 0.45);
    canvas.drawPath(l1, leafPaint);

    final l2 = Path()
      ..moveTo(w * 0.42, h * 0.38)
      ..quadraticBezierTo(w * 0.55, h * 0.32, w * 0.52, h * 0.22)
      ..quadraticBezierTo(w * 0.43, h * 0.28, w * 0.42, h * 0.38);
    canvas.drawPath(l2, leafPaint);

    // Deep Soil Probe Sensor (ESP32 Sensor Probe)
    final probePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.65, h * 0.52), Offset(w * 0.65, h * 0.82), probePaint);

    // Probe Sensor Head (IoT Transmitter)
    final headRect = Rect.fromCenter(center: Offset(w * 0.65, h * 0.50), width: 22, height: 18);
    final headPaint = Paint()
      ..color = AppColors.flowBlue
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, const Radius.circular(5)), headPaint);

    // Wireless Signal Waves radiating from Sensor Head
    final wavePaint = Paint()
      ..color = AppColors.flowBlueLight
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.65, h * 0.50), radius: 18),
      -math.pi * 0.8,
      math.pi * 0.6,
      false,
      wavePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.65, h * 0.50), radius: 26),
      -math.pi * 0.8,
      math.pi * 0.6,
      false,
      wavePaint,
    );

    // Telemetry Vital Stat Badges (Floating Mini Dashboard Card)
    final cardRect = Rect.fromLTWH(w * 0.18, h * 0.16, w * 0.36, 44);
    final cardBg = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final cardShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(RRect.fromRectAndRadius(cardRect.shift(const Offset(0, 3)), const Radius.circular(10)), cardShadow);
    canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(10)), cardBg);

    // Telemetry Mini Data Bars
    final barColors = [AppColors.primaryGreen, AppColors.flowBlue, AppColors.sensorOnline];
    final heights = [18.0, 26.0, 22.0];
    for (int i = 0; i < 3; i++) {
      final barPaint = Paint()..color = barColors[i];
      final r = Rect.fromLTWH(w * 0.22 + (i * 14), h * 0.18 + (28 - heights[i]), 8, heights[i]);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OnboardingIllustrationPainter oldDelegate) =>
      oldDelegate.pageIndex != pageIndex;
}
