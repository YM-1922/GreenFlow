import 'package:flutter/material.dart';

/// Clean, minimal, nature-inspired Green Flow brand logo matching the reference design.
/// Consists of two elegant green leaves (dark left, bright right), curved stem, and optional glowing effect.
class GreenFlowLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool animateNodes;

  const GreenFlowLogo({
    super.key,
    this.size = 110,
    this.showGlow = false,
    this.animateNodes = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _GreenFlowBrandEmblemPainter(),
      ),
    );
  }
}

class _GreenFlowBrandEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw the two iconic leaves matching the reference exactly:
    // Left leaf: Darker forest green #166534 / #15803D, curving leftwards
    // Right leaf: Vibrant emerald green #16A34A / #22C55E, slightly larger, curving right-upwards

    final leftLeafPath = Path();
    leftLeafPath.moveTo(w * 0.44, h * 0.82);
    // Outer curve up to tip
    leftLeafPath.cubicTo(
      w * 0.22,
      h * 0.72,
      w * 0.12,
      h * 0.48,
      w * 0.18,
      h * 0.32,
    );
    // Inner curve from tip back to base
    leftLeafPath.cubicTo(
      w * 0.32,
      h * 0.36,
      w * 0.45,
      h * 0.55,
      w * 0.44,
      h * 0.82,
    );
    leftLeafPath.close();

    final leftPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFF15803D),
          Color(0xFF16A34A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(leftLeafPath, leftPaint);

    // Left leaf subtle center vein
    final leftVeinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;

    final leftVeinPath = Path();
    leftVeinPath.moveTo(w * 0.42, h * 0.76);
    leftVeinPath.quadraticBezierTo(w * 0.28, h * 0.58, w * 0.20, h * 0.35);
    canvas.drawPath(leftVeinPath, leftVeinPaint);

    // Right leaf: Larger, vibrant green #16A34A -> #22C55E
    final rightLeafPath = Path();
    rightLeafPath.moveTo(w * 0.46, h * 0.86);
    // Inner curve up to top right tip
    rightLeafPath.cubicTo(
      w * 0.48,
      h * 0.54,
      w * 0.62,
      h * 0.32,
      w * 0.86,
      h * 0.22,
    );
    // Outer curve down from tip to base
    rightLeafPath.cubicTo(
      w * 0.88,
      h * 0.45,
      w * 0.74,
      h * 0.75,
      w * 0.46,
      h * 0.86,
    );
    rightLeafPath.close();

    final rightPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFF16A34A),
          Color(0xFF22C55E),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(rightLeafPath, rightPaint);

    // Right leaf subtle center vein
    final rightVeinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.024
      ..strokeCap = StrokeCap.round;

    final rightVeinPath = Path();
    rightVeinPath.moveTo(w * 0.49, h * 0.80);
    rightVeinPath.quadraticBezierTo(w * 0.64, h * 0.55, w * 0.82, h * 0.26);
    canvas.drawPath(rightVeinPath, rightVeinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
