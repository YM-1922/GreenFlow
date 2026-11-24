import 'package:flutter/material.dart';

/// Design tokens and color palette for Green Flow.
/// Blends fresh agriculture green, water flow cyan/blue, and pure crisp white.
class AppColors {
  AppColors._();

  // Primary Agriculture Greens
  static const Color primaryGreen = Color(0xFF10B981); // Primary Green #10B981
  static const Color primaryGreenDark = Color(0xFF047857); // Dark Green #047857
  static const Color primaryGreenLight = Color(0xFF34D399); // Fresh Mint Green
  static const Color softSage = Color(0xFFE8F5E9); // Soft Sage Background Tint
  static const Color primaryGreenSurface = Color(0xFFECFDF5); // Ultra-light green tint

  // Secondary Irrigation & Water Flow Blues
  static const Color flowBlue = Color(0xFF0284C7); // Clean Water Blue #0284C7
  static const Color flowBlueDark = Color(0xFF0369A1); // Deep Ocean Blue
  static const Color flowBlueLight = Color(0xFF38BDF8); // Sky Flow Aqua
  static const Color flowBlueSurface = Color(0xFFF0F9FF); // Ultra-light water tint

  // IoT & Sensor State Colors
  static const Color sensorOnline = Color(0xFF10B981); // Active / Optimal
  static const Color sensorConnecting = Color(0xFF0EA5E9); // Syncing
  static const Color sensorWarning = Color(0xFFF59E0B); // Low Moisture / Attention
  static const Color sensorAlert = Color(0xFFEF4444); // Critical / High Temp
  static const Color sensorOffline = Color(0xFF94A3B8); // Inactive

  // Neutral Colors (Light Theme)
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC); // Reference Background #F8FAFC
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color textPrimaryLight = Color(0xFF1F2937); // Reference Primary Text #1F2937
  static const Color textSecondaryLight = Color(0xFF6B7280); // Reference Secondary Text #6B7280
  static const Color textMutedLight = Color(0xFF9CA3AF);

  // Neutral Colors (Dark Theme)
  static const Color backgroundDark = Color(0xFF0B131E);
  static const Color surfaceDark = Color(0xFF131F33);
  static const Color cardDark = Color(0xFF182740);
  static const Color borderDark = Color(0xFF223656);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Brand Gradients
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, flowBlue],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF03261D), // Deep botanical teal
      Color(0xFF081C2B), // Deep water flow slate
      Color(0xFF0B131E), // Dark IoT background
    ],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A10B981),
      Color(0x1A0284C7),
    ],
  );
}
