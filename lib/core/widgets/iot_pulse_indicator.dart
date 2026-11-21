import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// An animated radar / IoT telemetry pulse indicator.
/// Demonstrates live hardware connectivity / sensor heartbeat.
class IotPulseIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final String? label;
  final TextStyle? labelStyle;

  const IotPulseIndicator({
    super.key,
    this.size = 14,
    this.color = AppColors.sensorOnline,
    this.label,
    this.labelStyle,
  });

  @override
  State<IotPulseIndicator> createState() => _IotPulseIndicatorState();
}

class _IotPulseIndicatorState extends State<IotPulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indicator = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 1.2);
        final opacity = (1.0 - _controller.value).clamp(0.0, 1.0);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Expanding Outer Wave
            Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size * 1.8,
                height: widget.size * 1.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: opacity * 0.4),
                ),
              ),
            ),
            // Middle Wave
            Container(
              width: widget.size * 1.3,
              height: widget.size * 1.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.25),
              ),
            ),
            // Solid Core
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (widget.label == null) {
      return indicator;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        indicator,
        const SizedBox(width: 8),
        Text(
          widget.label!,
          style: widget.labelStyle ??
              TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
        ),
      ],
    );
  }
}
