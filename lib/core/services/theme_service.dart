import 'package:flutter/material.dart';
import '../utils/file_io.dart' as file_io;

/// Service managing the application-wide theme mode (Light, Dark, System).
/// Operates 100% offline and defaults to Light Mode (white theme) on fresh launch.
class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;

  ThemeMode _themeMode = ThemeMode.light; // Light mode as default for first-time users
  static const String _prefFileName = '.greenflow_theme_pref';

  ThemeService._internal() {
    _loadPersistedTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;

  void _loadPersistedTheme() {
    try {
      final content = file_io.readFileSync(_prefFileName)?.trim();
      if (content == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (content == 'light') {
        _themeMode = ThemeMode.light;
      }
    } catch (_) {
      // Gracefully fall back to Light mode default
      _themeMode = ThemeMode.light;
    }
  }

  void _persistTheme(ThemeMode mode) {
    try {
      file_io.writeFileSync(_prefFileName, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {
      // Ignore filesystem permission limitations
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _persistTheme(mode);
      notifyListeners();
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
