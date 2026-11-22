import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Highly detailed, custom-painted nature and smart agricultural scenes matching the reference UI.
class OnboardingIllustration extends StatelessWidget {
  final int pageIndex;
  final double height;

  const OnboardingIllustration({
    super.key,
    required this.pageIndex,
    this.height = 310,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background scenic illustration
          Positioned.fill(
            child: CustomPaint(
              painter: _ScenePainter(pageIndex: pageIndex),
            ),
          ),

          // Overlaid interactive glass-morphic UI telemetry pills / badges
          Positioned(
            bottom: 24,
            child: _buildOverlayBadge(context),
          ),

          // Side telemetry cards on Page 3 (Temperature, Humidity, Soil Moisture)
          if (pageIndex == 2)
            Positioned(
              top: 16,
              right: 16,
              child: _buildTelemetryStack(context),
            ),

          // Top water savings badge on Page 2
          if (pageIndex == 1)
            Positioned(
              top: 18,
              right: 20,
              child: _buildWaterSavingPill(context),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlayBadge(BuildContext context) {
    switch (pageIndex) {
      case 0:
        // 3 Icons Glass Card (Sprout, Bar Chart, Microchip)
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco_outlined, color: AppColors.primaryGreen, size: 22),
              SizedBox(width: 16),
              Icon(Icons.bar_chart_rounded, color: AppColors.primaryGreen, size: 22),
              SizedBox(width: 16),
              Icon(Icons.memory_rounded, color: AppColors.primaryGreen, size: 22),
            ],
          ),
        );
      case 1:
        return const SizedBox.shrink();
      case 2:
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWaterSavingPill(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.water_drop_outlined, color: AppColors.primaryGreen, size: 24),
          const SizedBox(height: 4),
          Text(
            isAr ? 'توفير المياه' : 'Water Savings',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreenDark,
            ),
          ),
          Text(
            isAr ? 'حتى 40%' : 'Up to 40%',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryStack(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _telemetryChip(
          icon: Icons.thermostat_rounded,
          iconColor: const Color(0xFFF97316),
          label: '28°C',
        ),
        const SizedBox(height: 8),
        _telemetryChip(
          icon: Icons.water_drop_rounded,
          iconColor: const Color(0xFF0284C7),
          label: '65%',
        ),
        const SizedBox(height: 8),
        _telemetryChip(
          icon: Icons.grass_rounded,
          iconColor: const Color(0xFF16A34A),
          label: '32%',
        ),
      ],
    );
  }

  Widget _telemetryChip({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final int pageIndex;

  _ScenePainter({required this.pageIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft organic clip
    canvas.save();
    final clipPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(12, 0, w - 24, h),
        const Radius.circular(28),
      ));
    canvas.clipPath(clipPath);

    switch (pageIndex) {
      case 0:
        _drawSmartAgriScene(canvas, size);
        break;
      case 1:
        _drawIrrigationScene(canvas, size);
        break;
      case 2:
      default:
        _drawSensorMonitoringScene(canvas, size);
        break;
    }

    // Bottom soft blending curve fade into background
    final blendPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.backgroundLight.withValues(alpha: 0.35),
          AppColors.backgroundLight,
        ],
        stops: const [0.72, 0.88, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), blendPaint);

    canvas.restore();
  }

  // --- PAGE 1: SMART AGRICULTURE ---
  void _drawSmartAgriScene(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE0F2FE),
          Color(0xFFF0FDF4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.55));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.55), skyPaint);

    // Distant soft mountains
    final mountainPaint = Paint()..color = const Color(0xFF99B99E).withValues(alpha: 0.45);
    final mPath = Path()
      ..moveTo(0, h * 0.38)
      ..cubicTo(w * 0.25, h * 0.32, w * 0.35, h * 0.35, w * 0.55, h * 0.30)
      ..cubicTo(w * 0.75, h * 0.26, w * 0.88, h * 0.34, w, h * 0.32)
      ..lineTo(w, h * 0.5)
      ..lineTo(0, h * 0.5)
      ..close();
    canvas.drawPath(mPath, mountainPaint);

    // Midground rolling green hills
    final hillPaint = Paint()..color = const Color(0xFF65A30D).withValues(alpha: 0.85);
    final hillPath = Path()
      ..moveTo(0, h * 0.44)
      ..quadraticBezierTo(w * 0.4, h * 0.38, w, h * 0.45)
      ..lineTo(w, h * 0.55)
      ..lineTo(0, h * 0.55)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // Modern farm house with solar roof on the right
    _drawSmartFarmHouse(canvas, Offset(w * 0.72, h * 0.38), 58, 42);

    // IoT transmission tower on the left with wifi radio waves
    _drawTransmissionTower(canvas, Offset(w * 0.32, h * 0.28), h * 0.22);

    // Lush green crop field in perspective foreground
    final fieldPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF15803D),
          Color(0xFF166534),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.48, w, h * 0.52));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.48, w, h * 0.52), fieldPaint);

    // Perspective furrow lines with detailed lush green crops
    final cropPaint = Paint()..color = const Color(0xFF22C55E);
    for (int i = 0; i < 9; i++) {
      final startX = w * (0.15 + i * 0.08);
      final endX = w * (-0.2 + i * 0.18);
      final linePaint = Paint()
        ..color = const Color(0xFF14532D)
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(startX, h * 0.48), Offset(endX, h), linePaint);

      // Draw cluster of leaves along furrow
      for (double t = 0.1; t <= 1.0; t += 0.15) {
        final cx = startX + (endX - startX) * t;
        final cy = h * 0.48 + (h * 0.52) * t;
        final r = 3.0 + t * 5.0;
        canvas.drawCircle(Offset(cx - 3, cy), r, cropPaint);
        canvas.drawCircle(Offset(cx + 3, cy), r * 0.9, cropPaint);
      }
    }
  }

  void _drawSmartFarmHouse(Canvas canvas, Offset pos, double w, double h) {
    // House wall
    final wallPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx, pos.dy, w, h), const Radius.circular(3)),
      wallPaint,
    );

    // Solar Panel roof (blue angled)
    final roofPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
      ).createShader(Rect.fromLTWH(pos.dx - 4, pos.dy - 16, w + 8, 16));

    final rPath = Path()
      ..moveTo(pos.dx - 4, pos.dy)
      ..lineTo(pos.dx + w * 0.3, pos.dy - 16)
      ..lineTo(pos.dx + w + 4, pos.dy - 14)
      ..lineTo(pos.dx + w, pos.dy)
      ..close();
    canvas.drawPath(rPath, roofPaint);

    // Roof solar grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(pos.dx + w * 0.35, pos.dy - 12), Offset(pos.dx + w * 0.25, pos.dy), gridPaint);
    canvas.drawLine(Offset(pos.dx + w * 0.65, pos.dy - 13), Offset(pos.dx + w * 0.60, pos.dy), gridPaint);
  }

  void _drawTransmissionTower(Canvas canvas, Offset pos, double towerH) {
    final polePaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(pos.dx, pos.dy + 8), Offset(pos.dx, pos.dy + towerH), polePaint);

    // IoT Node Box
    final boxPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx - 10, pos.dy + 14, 20, 18), const Radius.circular(4)),
      boxPaint,
    );
    final boxBorder = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx - 10, pos.dy + 14, 20, 18), const Radius.circular(4)),
      boxBorder,
    );

    // Antenna tip
    canvas.drawLine(Offset(pos.dx, pos.dy + 14), Offset(pos.dx, pos.dy), polePaint);
    canvas.drawCircle(Offset(pos.dx, pos.dy), 3.5, Paint()..color = AppColors.primaryGreen);

    // Green Wi-Fi Signal Arcs above antenna
    final wavePaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(pos.dx, pos.dy - 2), radius: 8),
      math.pi * 1.25,
      math.pi * 0.5,
      false,
      wavePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(pos.dx, pos.dy - 2), radius: 15),
      math.pi * 1.25,
      math.pi * 0.5,
      false,
      wavePaint,
    );
  }

  // --- PAGE 2: SMART IRRIGATION ---
  void _drawIrrigationScene(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Rich warm agricultural soil background
    final soilPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF854D0E),
          Color(0xFF5A3207),
          Color(0xFF381F05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), soilPaint);

    // Soil texture / pebble specks
    final speckPaint = Paint()..color = const Color(0xFFA16207).withValues(alpha: 0.35);
    final random = math.Random(42);
    for (int i = 0; i < 60; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * w, random.nextDouble() * h),
        random.nextDouble() * 3 + 1,
        speckPaint,
      );
    }

    // Wet moisture zone around drip nozzle
    final wetSoilPaint = Paint()
      ..color = const Color(0xFF2E1A04).withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.62, h * 0.55), width: 140, height: 75),
      wetSoilPaint,
    );

    // Black Drip Irrigation Pipe running horizontally
    final pipePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF475569), Color(0xFF0F172A), Color(0xFF020617)],
      ).createShader(Rect.fromLTWH(0, h * 0.44, w, 24));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.44, w, 22), const Radius.circular(4)),
      pipePaint,
    );

    // Pipe highlight line
    final pipeHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, h * 0.455), Offset(w, h * 0.455), pipeHighlight);

    // Precision drip emitter valve on the pipe
    final emitterX = w * 0.62;
    final emitterY = h * 0.44 + 11;
    final emitterPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(emitterX - 10, emitterY - 4, 20, 20), const Radius.circular(5)),
      emitterPaint,
    );

    // Water droplet hanging and dripping
    final dropPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFBAE6FD), Color(0xFF0284C7)],
      ).createShader(Rect.fromCircle(center: Offset(emitterX, emitterY + 22), radius: 6));

    final dropPath = Path()
      ..moveTo(emitterX, emitterY + 12)
      ..quadraticBezierTo(emitterX + 5, emitterY + 22, emitterX + 5, emitterY + 26)
      ..arcToPoint(Offset(emitterX - 5, emitterY + 26), radius: const Radius.circular(5))
      ..quadraticBezierTo(emitterX - 5, emitterY + 22, emitterX, emitterY + 12)
      ..close();
    canvas.drawPath(dropPath, dropPaint);

    // Secondary splashing water drops
    canvas.drawCircle(Offset(emitterX - 10, emitterY + 36), 3, dropPaint);
    canvas.drawCircle(Offset(emitterX + 12, emitterY + 38), 2.5, dropPaint);
    canvas.drawCircle(Offset(emitterX + 2, emitterY + 44), 3.5, dropPaint);

    // Healthy vibrant seedling growing right behind the pipe
    _drawHealthyPlant(canvas, Offset(w * 0.52, h * 0.43));
    _drawHealthyPlant(canvas, Offset(w * 0.22, h * 0.48), scale: 0.75);
    _drawHealthyPlant(canvas, Offset(w * 0.82, h * 0.49), scale: 0.65);
  }

  void _drawHealthyPlant(Canvas canvas, Offset root, {double scale = 1.0}) {
    final stemPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = 3.5 * scale
      ..strokeCap = StrokeCap.round;

    // Stem going upwards
    final stemTop = Offset(root.dx + 5 * scale, root.dy - 85 * scale);
    canvas.drawLine(root, stemTop, stemPaint);

    // Large Lush Leaves
    _drawLeaf(canvas, stemTop, angle: -0.65, size: 48 * scale, color: const Color(0xFF22C55E));
    _drawLeaf(canvas, stemTop, angle: 0.65, size: 52 * scale, color: const Color(0xFF16A34A));
    _drawLeaf(canvas, Offset(root.dx, root.dy - 40 * scale), angle: -0.9, size: 38 * scale, color: const Color(0xFF15803D));
    _drawLeaf(canvas, Offset(root.dx + 4, root.dy - 45 * scale), angle: 0.85, size: 40 * scale, color: const Color(0xFF22C55E));
  }

  void _drawLeaf(Canvas canvas, Offset origin, {required double angle, required double size, required Color color}) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(size * 0.35, -size * 0.35, size * 0.75, -size * 0.2, size, 0)
      ..cubicTo(size * 0.75, size * 0.2, size * 0.35, size * 0.35, 0, 0)
      ..close();

    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);

    // Vein line
    final vein = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset.zero, Offset(size * 0.85, 0), vein);

    canvas.restore();
  }

  // --- PAGE 3: REAL-TIME IOT SENSOR MONITORING ---
  void _drawSensorMonitoringScene(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Calm clean sky background
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.65));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.65), skyPaint);

    // Soil layer in bottom
    final groundPaint = Paint()..color = const Color(0xFF452207);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.65, w, h * 0.35), groundPaint);

    // ESP32 Smart IoT Station Setup
    final stationX = w * 0.42;

    // Steel pole mounted in ground
    final polePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF94A3B8), Color(0xFF475569), Color(0xFF1E293B)],
      ).createShader(Rect.fromLTWH(stationX - 4, h * 0.25, 8, h * 0.45));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(stationX - 3.5, h * 0.25, 7, h * 0.45), const Radius.circular(2)),
      polePaint,
    );

    // Miniature Monocrystalline Solar Panel tilted at top of pole
    canvas.save();
    canvas.translate(stationX, h * 0.23);
    canvas.rotate(-0.25);
    final panelPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF0F172A)],
      ).createShader(const Rect.fromLTWH(-32, -18, 64, 24));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-32, -18, 64, 24), const Radius.circular(4)), panelPaint);
    // Grid lines on solar panel
    final pGrid = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(-10, -18), const Offset(-10, 6), pGrid);
    canvas.drawLine(const Offset(10, -18), const Offset(10, 6), pGrid);
    canvas.drawLine(const Offset(-32, -6), const Offset(32, -6), pGrid);
    canvas.restore();

    // White Weatherproof IoT Node Enclosure (ESP32 Gateway)
    final boxRect = Rect.fromLTWH(stationX - 26, h * 0.38, 52, 48);
    final boxPaint = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(10)), boxPaint);
    final boxBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(10)), boxBorder);

    // Green sprout logo on IoT box center
    final emblemPaint = Paint()..color = AppColors.primaryGreen;
    canvas.drawCircle(Offset(stationX, h * 0.38 + 24), 6, emblemPaint);

    // Dual Rubber Duck Antennas pointing up
    final antPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(stationX + 22, h * 0.38), Offset(stationX + 22, h * 0.30), antPaint);
    canvas.drawLine(Offset(stationX + 14, h * 0.38), Offset(stationX + 14, h * 0.32), antPaint);

    // Wi-Fi wave radiating from antenna
    final wPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(stationX + 22, h * 0.28), radius: 9),
      math.pi * 1.25,
      math.pi * 0.5,
      false,
      wPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(stationX + 22, h * 0.28), radius: 17),
      math.pi * 1.25,
      math.pi * 0.5,
      false,
      wPaint,
    );

    // Deep soil sensor probe cable going underground
    final cablePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 3.0;
    canvas.drawLine(Offset(stationX, h * 0.48), Offset(stationX, h * 0.78), cablePaint);

    // Stainless steel probe prongs inside soil
    final probePaint = Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 3.0;
    canvas.drawLine(Offset(stationX - 4, h * 0.78), Offset(stationX - 4, h * 0.90), probePaint);
    canvas.drawLine(Offset(stationX + 4, h * 0.78), Offset(stationX + 4, h * 0.90), probePaint);

    // Surrounding green plants
    _drawHealthyPlant(canvas, Offset(stationX + 70, h * 0.65), scale: 0.9);
    _drawHealthyPlant(canvas, Offset(w * 0.88, h * 0.66), scale: 0.7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
