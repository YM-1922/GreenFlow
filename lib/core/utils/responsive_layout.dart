import 'package:flutter/material.dart';

/// Utility class for responsive mobile calculations and screen sizing.
class ResponsiveLayout {
  ResponsiveLayout._();

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 360;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 600;
  }

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double horizontalPadding(BuildContext context) {
    return isTablet(context) ? 32.0 : 20.0;
  }
}
