import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A custom-rendered, resolution-independent vector emblem for Green Flow.
/// Synthesizes an agricultural sprout (Green), a water droplet/flow (Blue),
/// and smart IoT telemetry signal rings.
class GreenFlowLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool animateNodes;

  const GreenFlowLogo({
    super.key,
    this.size = 120,
    this.showGlow = true,
    this.animateNodes = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showGlow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.35),
                  blurRadius: size * 0.4,
                  spreadRadius: size * 0.05,
                ),
                BoxShadow(
                  color: AppColors.flowBlue.withValues(alpha: 0.25),
                  blurRadius: size * 0.5,
                  spreadRadius: size * 0.08,
                ),
              ],
            )
          : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: _GreenFlowLogoPainter(),
      ),
    );
  }
}

class _GreenFlowLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Background Halo Ring (IoT Orbital Signal)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..shader = const SweepGradient(
        colors: [
          AppColors.primaryGreen,
          AppColors.flowBlue,
          AppColors.flowBlueLight,
          AppColors.primaryGreenLight,
          AppColors.primaryGreen,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.46));

    canvas.drawCircle(center, w * 0.44, ringPaint);

    // 2. Water Flow Droplet (Secondary - Flow Blue to Cyan)
    final dropletPath = Path();
    dropletPath.moveTo(w * 0.5, h * 0.16);
    // Right curve down
    dropletPath.cubicTo(
      w * 0.72,
      h * 0.42,
      w * 0.76,
      h * 0.68,
      w * 0.55,
      h * 0.82,
    );
    // Bottom curve to left
    dropletPath.cubicTo(
      w * 0.40,
      h * 0.90,
      w * 0.28,
      h * 0.76,
      w * 0.30,
      h * 0.60,
    );
    // Curve back up to top
    dropletPath.cubicTo(
      w * 0.32,
      h * 0.42,
      w * 0.44,
      h * 0.26,
      w * 0.5,
      h * 0.16,
    );
    dropletPath.close();

    final dropletPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
        colors: [
          AppColors.flowBlueLight,
          AppColors.flowBlue,
          AppColors.flowBlueDark,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(dropletPath, dropletPaint);

    // 3. Sprouting Plant Leaf (Primary - Emerald to Mint)
    final leafPath = Path();
    leafPath.moveTo(w * 0.48, h * 0.82);
    // Curve up-right toward top
    leafPath.cubicTo(
      w * 0.58,
      h * 0.62,
      w * 0.74,
      h * 0.48,
      w * 0.72,
      h * 0.28,
    );
    // Leaf tip and left side
    leafPath.cubicTo(
      w * 0.52,
      h * 0.32,
      w * 0.42,
      h * 0.50,
      w * 0.48,
      h * 0.82,
    );
    leafPath.close();

    final leafPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          AppColors.primaryGreenDark,
          AppColors.primaryGreen,
          AppColors.primaryGreenLight,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(leafPath, leafPaint);

    // 4. Central Leaf Vein / Circuit Trace (IoT Connectivity Line)
    final veinPaint = Paint()
      ..color = AppColors.pureWhite.withValues(alpha: 0.85)
      ..strokeWidth = w * 0.025
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final veinPath = Path();
    veinPath.moveTo(w * 0.49, h * 0.76);
    veinPath.quadraticBezierTo(w * 0.54, h * 0.55, w * 0.66, h * 0.36);
    canvas.drawPath(veinPath, veinPaint);

    // 5. IoT Sensor Telemetry Nodes (3 Smart Sensor Nodes on orbit)
    final nodePoints = [
      Offset(w * 0.18, h * 0.38), // Node 1 (Soil Moisture)
      Offset(w * 0.82, h * 0.42), // Node 2 (Irrigation Valve)
      Offset(w * 0.50, h * 0.94), // Node 3 (ESP32 Controller)
    ];

    final nodeColors = [
      AppColors.primaryGreenLight,
      AppColors.flowBlueLight,
      AppColors.sensorOnline,
    ];

    for (int i = 0; i < nodePoints.length; i++) {
      final point = nodePoints[i];
      final col = nodeColors[i];

      // Node Outer Pulse
      final outerPulsePaint = Paint()
        ..color = col.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, w * 0.05, outerPulsePaint);

      // Node Core
      final nodePaint = Paint()
        ..color = col
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, w * 0.025, nodePaint);

      // Center white dot
      final innerDot = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, w * 0.012, innerDot);
    }

    // 6. Subtle Water Ripple Arc at bottom
    final ripplePaint = Paint()
      ..color = AppColors.flowBlueLight.withValues(alpha: 0.5)
      ..strokeWidth = w * 0.02
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.72), radius: w * 0.16),
      math.pi * 0.1,
      math.pi * 0.8,
      false,
      ripplePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
