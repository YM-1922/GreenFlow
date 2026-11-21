import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/services/theme_service.dart';

/// Root application widget for Green Flow.
/// Configures Material 3, route navigation, bilingual support, and reactive theme modes.
class GreenFlowApp extends StatefulWidget {
  const GreenFlowApp({super.key});

  /// Allows dynamic locale switching from any child widget.
  static void setLocale(BuildContext context, Locale newLocale) {
    final state = context.findAncestorStateOfType<_GreenFlowAppState>();
    state?.changeLocale(newLocale);
  }

  /// Allows dynamic theme toggling.
  static void toggleTheme(BuildContext context) {
    ThemeService().toggleTheme();
  }

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    ThemeService().setThemeMode(mode);
  }

  @override
  State<GreenFlowApp> createState() => _GreenFlowAppState();
}

class _GreenFlowAppState extends State<GreenFlowApp> {
  Locale _locale = const Locale(AppConstants.localeEn);
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeService.themeMode,
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''), // English (LTR)
        Locale('ar', ''), // Arabic (RTL)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
