import 'dart:convert';
import '../utils/file_io.dart' as file_io;

/// Firebase Configuration & Integration Settings for Green Flow.
/// Supports both live Firebase REST endpoints and high-fidelity reactive simulation.
class FirebaseConfig {
  FirebaseConfig._();

  static const String _configFile = '.greenflow_firebase_config.json';

  /// Project identification
  static const String projectId = 'green-flow-smart-agriculture';
  static const String storageBucket = '$projectId.appspot.com';
  static const String defaultRealtimeDatabaseUrl =
      'https://$projectId-default-rtdb.firebaseio.com';

  /// User-configured Live Credentials
  static String customRealtimeDbUrl = '';
  static String customAuthToken = '';

  /// Mode switcher: Toggle between simulated local reactive cloud store and live Firebase REST API.
  static bool useLiveBackend = false;

  /// Active Realtime Database URL
  static String get realtimeDatabaseUrl {
    if (customRealtimeDbUrl.trim().isNotEmpty) {
      return customRealtimeDbUrl.trim();
    }
    return defaultRealtimeDatabaseUrl;
  }

  /// Active Auth Token
  static String get authToken => customAuthToken.trim();

  /// Check if active configuration is still using placeholders
  static bool get isPlaceholderConfig {
    return realtimeDatabaseUrl.contains('YOUR_PROJECT_ID') ||
        realtimeDatabaseUrl.contains('green-flow-smart-agriculture') ||
        customRealtimeDbUrl.trim().isEmpty;
  }

  /// REST API Base URLs
  static String get firestoreRestBaseUrl =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  static String get realtimeDbRestBaseUrl => realtimeDatabaseUrl;

  /// Load persisted configuration from local storage
  static void loadPersistedConfig() {
    final content = file_io.readFileSync(_configFile);
    if (content != null && content.isNotEmpty) {
      try {
        final data = jsonDecode(content) as Map<String, dynamic>;
        customRealtimeDbUrl = data['realtimeDbUrl'] ?? '';
        customAuthToken = data['authToken'] ?? '';
        useLiveBackend = data['useLiveBackend'] == true;
      } catch (_) {}
    }
  }

  /// Save configuration to local storage
  static void savePersistedConfig({
    required String url,
    required String token,
    required bool liveMode,
  }) {
    customRealtimeDbUrl = url;
    customAuthToken = token;
    useLiveBackend = liveMode;

    final data = {
      'realtimeDbUrl': customRealtimeDbUrl,
      'authToken': customAuthToken,
      'useLiveBackend': useLiveBackend,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    file_io.writeFileSync(_configFile, jsonEncode(data));
  }

  /// Default collections
  static const String colUsers = 'users';
  static const String colFarms = 'farms';
  static const String colDevices = 'devices';
  static const String colNotifications = 'notifications';
  static const String colIrrigationSchedules = 'irrigationSchedules';
  static const String colIrrigationLogs = 'irrigationLogs';
  static const String colQuotations = 'quotations';
  static const String colInvoices = 'invoices';
  static const String colInspections = 'inspections';
}
