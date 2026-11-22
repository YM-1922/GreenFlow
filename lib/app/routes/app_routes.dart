import 'package:flutter/material.dart';
import '../../core/auth/auth.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/authentication/presentation/screens/approval_waiting_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/devices/presentation/screens/device_details_screen.dart';
import '../../features/devices/presentation/screens/device_setup_wizard_screen.dart';
import '../../features/devices/presentation/screens/devices_list_screen.dart';
import '../../features/farms/domain/entities/farm_entities.dart';
import '../../features/farms/presentation/screens/farm_add_edit_screen.dart';
import '../../features/farms/presentation/screens/farm_details_screen.dart';
import '../../features/farms/presentation/screens/farms_list_screen.dart';
import '../../features/farms/presentation/screens/inspection_details_screen.dart';
import '../../features/farms/presentation/screens/inspection_request_screen.dart';
import '../../features/farms/presentation/screens/inspections_list_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/irrigation/presentation/screens/irrigation_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/solar/presentation/screens/solar_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/subscriptions/presentation/screens/subscriptions_screen.dart';
import '../../features/weather/presentation/screens/weather_screen.dart';

/// Centralized route definitions, role guards, and route generator for Green Flow.
/// Supports exclusively the two primary platform roles: Super Admin and Farmer.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String authentication = '/auth';
  static const String login = '/login';
  static const String register = '/register';
  static const String approvalWaiting = '/approval-waiting';
  static const String home = '/home';
  static const String farms = '/farms';
  static const String farmDetails = '/farm-details';
  static const String farmAddEdit = '/farm-add-edit';
  static const String inspectionRequest = '/inspection-request';
  static const String inspectionsList = '/inspections';
  static const String inspectionDetails = '/inspection-details';
  static const String devices = '/devices';
  static const String deviceDetails = '/device-details';
  static const String deviceSetup = '/device-setup';
  static const String irrigation = '/irrigation';
  static const String solar = '/solar';
  static const String analytics = '/analytics';
  static const String notifications = '/notifications';
  static const String subscriptions = '/subscriptions';
  static const String admin = '/admin';
  static const String weather = '/weather';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final user = AuthService().currentUser;

    // Route Guards for Restricted Super Admin Role
    if (settings.name == admin) {
      if (user != null && !PermissionService.canAccessSuperAdmin(user.role)) {
        return _accessDeniedRoute('Super Admin permissions required.', settings);
      }
    }

    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: settings);
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen(), settings: settings);
      case authentication:
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: settings);
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen(), settings: settings);
      case approvalWaiting:
        return MaterialPageRoute(builder: (_) => const ApprovalWaitingScreen(), settings: settings);
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);
      case farms:
        return MaterialPageRoute(builder: (_) => const FarmsListScreen(), settings: settings);
      case farmDetails:
        final farmId = settings.arguments as String? ?? 'farm-001';
        return MaterialPageRoute(builder: (_) => FarmDetailsScreen(farmId: farmId), settings: settings);
      case farmAddEdit:
        final initialFarm = settings.arguments as FarmEntity?;
        return MaterialPageRoute(builder: (_) => FarmAddEditScreen(initialFarm: initialFarm), settings: settings);
      case inspectionRequest:
        final initialFarm = settings.arguments as FarmEntity?;
        return MaterialPageRoute(builder: (_) => InspectionRequestScreen(initialFarm: initialFarm), settings: settings);
      case inspectionsList:
        return MaterialPageRoute(builder: (_) => const InspectionsListScreen(), settings: settings);
      case inspectionDetails:
        final requestId = settings.arguments as String? ?? 'INS-2026-081';
        return MaterialPageRoute(builder: (_) => InspectionDetailsScreen(requestId: requestId), settings: settings);
      case devices:
        return MaterialPageRoute(builder: (_) => const DevicesListScreen(), settings: settings);
      case deviceDetails:
        final deviceId = settings.arguments as String? ?? 'dev-001';
        return MaterialPageRoute(builder: (_) => DeviceDetailsScreen(deviceId: deviceId), settings: settings);
      case deviceSetup:
        return MaterialPageRoute(builder: (_) => const DeviceSetupWizardScreen(), settings: settings);
      case irrigation:
        return MaterialPageRoute(builder: (_) => const IrrigationScreen(), settings: settings);
      case solar:
        final farmId = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => SolarScreen(initialFarmId: farmId), settings: settings);
      case analytics:
        final farmId = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) => AnalyticsScreen(initialFarmId: farmId), settings: settings);
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen(), settings: settings);
      case subscriptions:
        return MaterialPageRoute(builder: (_) => const SubscriptionsScreen(), settings: settings);
      case admin:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen(), settings: settings);
      case weather:
        return MaterialPageRoute(builder: (_) => const WeatherScreen(), settings: settings);
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen(), settings: settings);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
          settings: settings,
        );
    }
  }

  static MaterialPageRoute _accessDeniedRoute(String reason, RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Access Denied / غير مصرح')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gpp_bad_rounded, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'Access Denied / محظور',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  reason,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back / العودة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
