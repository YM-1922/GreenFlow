import 'package:flutter/material.dart';

/// General helper utilities for Green Flow
class AppUtils {
  AppUtils._();

  /// Check if the active locale is Right-To-Left (RTL) such as Arabic.
  static bool isRtl(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }

  /// Formats soil moisture percentage
  static String formatMoisture(double value) {
    return '${value.clamp(0, 100).toStringAsFixed(1)}%';
  }

  /// Formats water flow rate in Liters/min
  static String formatFlowRate(double litersPerMin) {
    return '${litersPerMin.toStringAsFixed(2)} L/min';
  }

  /// Formats temperature in Celsius
  static String formatTemperature(double celsius) {
    return '${celsius.toStringAsFixed(1)} °C';
  }
}
