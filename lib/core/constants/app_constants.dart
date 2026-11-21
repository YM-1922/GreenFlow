/// Application-wide constants for Green Flow
class AppConstants {
  AppConstants._();

  static const String appName = 'Green Flow';
  static const String appNameAr = 'جرين فلو';
  static const String appTaglineEn = 'Smart Agriculture & IoT Automation';
  static const String appTaglineAr = 'الزراعة الذكية ونظم الأتمتة وإنترنت الأشياء';
  static const String appSubtextEn = 'Precision Irrigation • Soil Telemetry • Edge ESP32';
  static const String appSubtextAr = 'ري دقيق • استشعار التربة • أجهزة ESP32 الذكية';

  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Splash Configuration
  static const Duration splashDuration = Duration(milliseconds: 2800);
  static const Duration animationDurationFast = Duration(milliseconds: 300);
  static const Duration animationDurationMedium = Duration(milliseconds: 600);
  static const Duration animationDurationSlow = Duration(milliseconds: 1200);

  // Supported Locales
  static const String localeEn = 'en';
  static const String localeAr = 'ar';

  // Future Hardware (ESP32) & API Defaults
  static const int defaultEsp32BaudRate = 115200;
  static const int defaultMqttPort = 1883;
  static const Duration defaultApiTimeout = Duration(seconds: 15);
}
