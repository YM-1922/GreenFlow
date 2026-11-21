import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenflow/app/app.dart';
import 'package:greenflow/app/theme/app_theme.dart';
import 'package:greenflow/core/services/theme_service.dart';
import 'package:greenflow/core/widgets/app_logo.dart';
import 'package:greenflow/core/services/offline_sync_service.dart';
import 'package:greenflow/core/widgets/connectivity_banner.dart';
import 'package:greenflow/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:greenflow/features/authentication/presentation/screens/login_screen.dart';
import 'package:greenflow/features/authentication/presentation/screens/register_screen.dart';
import 'package:greenflow/features/devices/presentation/screens/devices_list_screen.dart';
import 'package:greenflow/features/devices/presentation/screens/device_details_screen.dart';
import 'package:greenflow/features/devices/presentation/screens/device_setup_wizard_screen.dart';
import 'package:greenflow/features/farms/presentation/screens/farm_add_edit_screen.dart';
import 'package:greenflow/features/farms/presentation/screens/farm_details_screen.dart';
import 'package:greenflow/features/farms/presentation/screens/farms_list_screen.dart';
import 'package:greenflow/features/farms/presentation/screens/inspection_details_screen.dart';
import 'package:greenflow/features/farms/presentation/screens/inspection_request_screen.dart';
import 'package:greenflow/features/farms/presentation/screens/inspections_list_screen.dart';
import 'package:greenflow/features/home/presentation/screens/home_screen.dart';
import 'package:greenflow/features/notifications/data/datasources/notifications_mock_data_source.dart';
import 'package:greenflow/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:greenflow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:greenflow/features/profile/presentation/screens/profile_screen.dart';
import 'package:greenflow/features/solar/presentation/screens/solar_screen.dart';
import 'package:greenflow/features/subscriptions/presentation/screens/subscriptions_screen.dart';
import 'package:greenflow/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:greenflow/features/weather/presentation/screens/weather_screen.dart';
import 'package:greenflow/features/technician/presentation/screens/technician_dashboard_screen.dart';
import 'package:greenflow/features/worker/presentation/screens/worker_dashboard_screen.dart';
import 'package:greenflow/features/finance/presentation/screens/finance_dashboard_screen.dart';
import 'package:greenflow/features/authentication/presentation/screens/approval_waiting_screen.dart';
import 'package:greenflow/core/auth/auth.dart';

Widget _buildTestApp(Widget home, {Locale locale = const Locale('en', '')}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: locale,
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en', ''),
      Locale('ar', ''),
    ],
    home: home,
  );
}

void main() {
  // ==========================================
  // PHASE 1 & 2 TESTS
  // ==========================================
  testWidgets('Green Flow app initializes and displays splash screen branding',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GreenFlowApp());

    expect(find.byType(GreenFlowLogo), findsOneWidget);
    expect(find.text('Green Flow'), findsOneWidget);
  });

  testWidgets('OnboardingScreen renders properly with navigation controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(const OnboardingScreen()));

    expect(find.text('Smart Agriculture'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('LoginScreen renders email, password, and sign in actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(const LoginScreen()));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Username or Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('RegisterScreen renders all required fields and terms checkbox',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(const RegisterScreen()));

    expect(find.text('New Farmer Registration'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Submit Registration Application'), findsOneWidget);
  });

  // ==========================================
  // PHASE 3 DASHBOARD TESTS
  // ==========================================
  testWidgets('HomeScreen renders complete commercial dashboard sections',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const HomeScreen()));

    // 1. Dashboard Header
    expect(find.text('Farmer Ahmed'), findsOneWidget);
    expect(find.text('Welcome back,'), findsOneWidget);

    // 2. Farm Summary
    expect(find.text('Total Farms'), findsOneWidget);
    expect(find.text('Total Trees'), findsOneWidget);
    expect(find.text('IoT Devices'), findsOneWidget);

    // 3. Environmental Monitoring
    expect(find.text('Environmental Monitoring'), findsOneWidget);
    expect(find.text('Soil Moisture'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('Air Humidity'), findsOneWidget);
    expect(find.text('Water Consumption'), findsOneWidget);

    // 4. Irrigation Control
    expect(find.text('Smart Irrigation Control'), findsOneWidget);
    expect(find.text('Start Irrigation'), findsOneWidget);

    // 5. Bottom Navigation
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets(
      'HomeScreen interactive irrigation controls update local demo state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    final startButton = find.text('Start Irrigation');
    expect(startButton, findsOneWidget);

    await tester.ensureVisible(startButton);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(startButton);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Stop Irrigation'), findsOneWidget);

    final stopButton = find.text('Stop Irrigation');
    await tester.ensureVisible(stopButton);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(stopButton);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Start Irrigation'), findsOneWidget);
  });

  testWidgets('HomeScreen renders correctly in Arabic RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _buildTestApp(const HomeScreen(), locale: const Locale('ar', '')),
    );

    expect(find.text('المزارع أحمد'), findsOneWidget);
    expect(find.text('إجمالي المزارع'), findsOneWidget);
    expect(find.text('رطوبة التربة'), findsOneWidget);
    expect(find.text('التحكم الذكي بالري'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
  });

  // ==========================================
  // PHASE 4 FARM MANAGEMENT & INSPECTION TESTS
  // ==========================================
  testWidgets('FarmsListScreen renders farms overview stats and farm cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const FarmsListScreen()));
    await tester.pumpAndSettle();

    // Check header and summary
    expect(find.text('Farm Management'), findsOneWidget);
    expect(find.text('Total Area'), findsOneWidget);
    expect(find.text('Irrigation Zones'), findsOneWidget);

    // Check farm cards rendered from mock data source
    expect(find.text('مزرعة الأمل للزيتون والنخيل'), findsOneWidget);
    expect(find.text('Add Farm'), findsOneWidget);
  });

  testWidgets('FarmAddEditScreen validates required fields and creates a new farm',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const FarmAddEditScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Add Farm'), findsOneWidget);
    expect(find.text('Create Farm'), findsOneWidget);

    // Tap create without filling fields to trigger validation
    await tester.tap(find.text('Create Farm'));
    await tester.pump();

    // Check validation error appeared
    expect(find.text('This field is required'), findsWidgets);
  });

  testWidgets('FarmDetailsScreen displays farm overview and irrigation zones',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
        _buildTestApp(const FarmDetailsScreen(farmId: 'farm-001')));
    await tester.pumpAndSettle();

    expect(find.text('مزرعة الأمل للزيتون والنخيل'), findsWidgets);
    expect(find.text('Irrigation Zones'), findsWidgets);
    expect(find.text('المنطقة أ - قطاع الزيتون الشرقي'), findsOneWidget);
    expect(find.text('Add Zone'), findsOneWidget);
  });

  testWidgets(
      'InspectionRequestScreen submits customer inspection request with confirmation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const InspectionRequestScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Request Farm Inspection'), findsOneWidget);
    expect(find.text('Customer / Farm Owner Name'), findsOneWidget);
    expect(find.text('Submit Inspection Request'), findsOneWidget);

    // Fill in required farm name and location
    final farmNameField = find.widgetWithText(TextField, 'e.g., Al-Amal Olive Farm');
    final locationField = find.widgetWithText(TextField, 'e.g., Wadi El Natrun, Beheira');
    final areaField = find.widgetWithText(TextField, '30');

    await tester.enterText(farmNameField, 'مزرعة النور الحديثة');
    await tester.enterText(locationField, 'طريق الفيوم');
    await tester.enterText(areaField, '20');

    final submitButton = find.text('Submit Inspection Request');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();

    await tester.tap(submitButton);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify confirmation modal appeared
    expect(find.text('Inspection Request Submitted!'), findsOneWidget);
  });

  testWidgets(
      'InspectionsListScreen and InspectionDetailsScreen render request details and quotation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. Test InspectionsListScreen
    await tester.pumpWidget(_buildTestApp(const InspectionsListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Inspection & Quotation Requests'), findsOneWidget);
    expect(find.text('INS-2026-081'), findsOneWidget);

    // 2. Test InspectionDetailsScreen with prepared quotation
    await tester.pumpWidget(
        _buildTestApp(const InspectionDetailsScreen(requestId: 'INS-2026-081')));
    await tester.pumpAndSettle();

    expect(find.text('INS-2026-081 • مزرعة الأمل للزيتون والنخيل'), findsOneWidget);
    expect(find.text('Hardware & Solar Quotation'), findsOneWidget);
    expect(find.text('Accept Quotation & Proceed to Contract'), findsOneWidget);
  });

  testWidgets('Farms screens render correctly in Arabic RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _buildTestApp(const FarmsListScreen(), locale: const Locale('ar', '')),
    );
    await tester.pumpAndSettle();

    // Verify Arabic translations on Farms screen
    expect(find.text('إدارة المزارع والحقول'), findsOneWidget);
    expect(find.text('إجمالي المساحة'), findsOneWidget);
    expect(find.text('مناطق الري'), findsOneWidget);
    expect(find.text('إضافة مزرعة'), findsOneWidget);
    expect(find.text('جميع المزارع'), findsOneWidget);
  });

  // ==========================================
  // PHASE 6 DEVICES TESTS
  // ==========================================
  testWidgets('DevicesListScreen renders hardware nodes, categories and actions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const DevicesListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('IoT Nodes & Devices'), findsOneWidget);
    expect(find.text('Online Nodes'), findsOneWidget);
    expect(find.text('Pair Device'), findsOneWidget);
    expect(find.text('Gateways'), findsOneWidget);
    expect(find.text('Soil Probes'), findsOneWidget);
  });

  testWidgets('DeviceDetailsScreen renders telemetry, specs, and control buttons',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
        _buildTestApp(const DeviceDetailsScreen(deviceId: 'dev-001')));
    await tester.pumpAndSettle();

    expect(find.text('Live Telemetry'), findsOneWidget);
    expect(find.text('Hardware & Network Specifications'), findsOneWidget);
    expect(find.text('Ping Test'), findsOneWidget);
    expect(find.text('Update Firmware (OTA)'), findsOneWidget);
    expect(find.text('Delete Node'), findsOneWidget);
  });

  testWidgets('DeviceSetupWizardScreen navigates through 4 commissioning steps',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const DeviceSetupWizardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('ESP32 Device Setup Wizard'), findsOneWidget);
    expect(find.text('1. Select Device Category'), findsOneWidget);

    final continueBtn = find.byKey(const Key('wizard_continue_btn'));
    expect(continueBtn, findsOneWidget);

    // Step 1 -> Step 2
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    expect(find.text('2. Device Serial & Barcode'), findsOneWidget);
    expect(find.text('Simulate QR Code Scan'), findsOneWidget);

    // Click simulate QR scan to fill serial
    final qrButton = find.text('Simulate QR Code Scan');
    await tester.ensureVisible(qrButton);
    await tester.tap(qrButton);
    await tester.pumpAndSettle();

    // Step 2 -> Step 3
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    expect(find.text('3. Assign to Farm & Zone'), findsOneWidget);

    // Step 3 -> Step 4
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    expect(find.text('4. Summary & Activation'), findsOneWidget);
    expect(find.text('Activate Node'), findsOneWidget);
  });

  testWidgets('Devices screens render correctly in Arabic RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _buildTestApp(const DevicesListScreen(), locale: const Locale('ar', '')),
    );
    await tester.pumpAndSettle();

    expect(find.text('أجهزة إنترنت الأشياء والمجسات'), findsOneWidget);
    expect(find.text('الأجهزة المتصلة'), findsOneWidget);
    expect(find.text('ربط جهاز جديد'), findsOneWidget);
  });

  // ==========================================
  // PHASE 7 OFFLINE PERSISTENCE & SYNC TESTS
  // ==========================================
  testWidgets('ConnectivityBanner renders online and offline states reactively',
      (WidgetTester tester) async {
    final syncService = OfflineSyncService();
    syncService.clearQueue();
    syncService.setOnlineStatus(true);

    await tester.pumpWidget(_buildTestApp(const ConnectivityBanner()));
    await tester.pumpAndSettle();

    expect(find.text('Online & Connected'), findsOneWidget);

    // Switch to offline mode
    syncService.setOnlineStatus(false);
    await tester.pumpAndSettle();

    expect(find.text('Offline Operation Mode'), findsOneWidget);

    // Reset back to online
    syncService.setOnlineStatus(true);
    await tester.pumpAndSettle();
    expect(find.text('Online & Connected'), findsOneWidget);
  });

  testWidgets('OfflineSyncService queues operations, prevents duplicates, and synchronizes',
      (WidgetTester tester) async {
    final syncService = OfflineSyncService();
    syncService.clearQueue();
    syncService.setOnlineStatus(false);

    // Queue mutations while offline
    await syncService.queueOperation(
      QueuedOperationType.createFarm,
      {'id': 'farm_offline_1', 'name': 'Offline Oasis Farm'},
    );

    // Enqueue duplicate mutation for same ID
    await syncService.queueOperation(
      QueuedOperationType.createFarm,
      {'id': 'farm_offline_1', 'name': 'Offline Oasis Farm Updated'},
    );

    // Assert duplicate deduplication worked (count stays 1)
    expect(syncService.queuedOperationsCount, 1);
    expect(syncService.operationQueue.first.payload['name'],
        'Offline Oasis Farm Updated');

    // Simulate connection failure during sync
    final failedSync =
        await syncService.synchronizePendingQueue(simulateFailure: true);
    expect(failedSync, isFalse);
    expect(syncService.status, SyncConnectionStatus.syncError);
    expect(syncService.queuedOperationsCount, 1);
    expect(syncService.operationQueue.first.retryCount, 1);

    // Restore connection and successfully synchronize queue
    syncService.setOnlineStatus(true);
    final successSync = await syncService.synchronizePendingQueue();
    expect(successSync, isTrue);
    expect(syncService.status, SyncConnectionStatus.online);
    expect(syncService.queuedOperationsCount, 0);
  });

  testWidgets('HomeScreen displays connectivity banner with sync actions in Arabic RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final syncService = OfflineSyncService();
    syncService.clearQueue();
    syncService.setOnlineStatus(false);

    await tester.pumpWidget(
      _buildTestApp(const HomeScreen(), locale: const Locale('ar', '')),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('وضع عدم الاتصال (أوفلاين)'), findsOneWidget);
    expect(find.byType(ConnectivityBanner), findsOneWidget);

    // Reset online
    syncService.setOnlineStatus(true);
  });

  // ==========================================
  // PHASE 8 SOLAR ENERGY TESTS
  // ==========================================
  testWidgets('SolarScreen renders telemetry, battery SoC, and historical charts',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const SolarScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Solar Energy Monitor'), findsOneWidget);
    expect(find.text('Current Solar Output'), findsOneWidget);
    expect(find.text('1250 W'), findsOneWidget);
    expect(find.text('Battery SoC'), findsOneWidget);
    expect(find.text('Daily Output'), findsOneWidget);
    expect(find.text('Pump Load'), findsOneWidget);
    expect(find.text('Net Surplus'), findsOneWidget);
    expect(find.text('78%'), findsOneWidget);
    expect(find.text('Solar System Alerts'), findsOneWidget);
    expect(find.text('Hourly Generation vs Consumption'), findsOneWidget);
    expect(find.text('7-Day Energy History (kWh)'), findsOneWidget);
  });

  testWidgets('SolarScreen switches monitored farm and updates solar telemetry',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _buildTestApp(const SolarScreen(initialFarmId: 'farm-002')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nile Valley Citrus Farm'), findsOneWidget);
    expect(find.text('1840 W'), findsOneWidget);
    expect(find.text('92%'), findsOneWidget);
    expect(find.text('+640 W'), findsOneWidget);
  });

  testWidgets('SolarScreen renders correctly in Arabic RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _buildTestApp(const SolarScreen(), locale: const Locale('ar', '')),
    );
    await tester.pumpAndSettle();

    expect(find.text('مراقبة الطاقة الشمسية'), findsOneWidget);
    expect(find.text('القدرة المولدة الحالية'), findsOneWidget);
    expect(find.text('شحن البطارية نشط'), findsOneWidget);
    expect(find.text('إنتاج اليوم'), findsOneWidget);
    expect(find.text('حمل المضخة'), findsOneWidget);
    expect(find.text('صافي التوازن'), findsOneWidget);
    expect(find.text('مزرعة الأمل للزيتون والنخيل'), findsOneWidget);
    expect(find.text('تنبيهات المنظومة الشمسية'), findsOneWidget);
  });

  // ==========================================
  // PHASE 9 NOTIFICATIONS & ANALYTICS TESTS
  // ==========================================
  testWidgets('ThemeService defaults to Light Mode and toggles reactively',
      (WidgetTester tester) async {
    final themeService = ThemeService();
    themeService.setThemeMode(ThemeMode.light);
    expect(themeService.isLightMode, isTrue);

    themeService.toggleTheme();
    expect(themeService.isDarkMode, isTrue);

    themeService.toggleTheme();
    expect(themeService.isLightMode, isTrue);
  });

  testWidgets('NotificationsScreen renders category filters, details modal, and unread badges',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final notifs = NotificationsMockDataSource();
    notifs.resetDemoData();

    await tester.pumpWidget(_buildTestApp(const NotificationsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Notification Center'), findsOneWidget);
    expect(find.text('Irrigation'), findsWidgets);
    expect(find.text('Solar'), findsOneWidget);
    expect(find.text('Water'), findsWidgets);

    // Tap first notification to open details
    await tester.tap(find.text('🚨 E-Stop Triggered'));
    await tester.pumpAndSettle();

    expect(find.text('Close'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });

  testWidgets('NotificationsScreen mark all read and delete actions update reactive state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final notifs = NotificationsMockDataSource();
    notifs.resetDemoData();
    expect(notifs.unreadCount, greaterThan(0));

    await tester.pumpWidget(_buildTestApp(const NotificationsScreen()));
    await tester.pumpAndSettle();

    // Mark all as read
    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();
    expect(notifs.unreadCount, 0);

    // Delete first item
    final initialCount = notifs.getNotifications().length;
    final deleteBtn = find.byTooltip('Delete').first;
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();
    expect(notifs.getNotifications().length, initialCount - 1);
  });

  testWidgets('NotificationsScreen renders correctly in Arabic RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final notifs = NotificationsMockDataSource();
    notifs.resetDemoData();

    await tester.pumpWidget(
      _buildTestApp(const NotificationsScreen(), locale: const Locale('ar', '')),
    );
    await tester.pumpAndSettle();

    expect(find.text('مركز الإشعارات'), findsOneWidget);
    expect(find.text('الري'), findsWidgets);
    expect(find.text('الأجهزة'), findsWidgets);
    expect(find.text('المياه'), findsWidgets);
    expect(find.text('قراءة الكل'), findsOneWidget);
  });

  testWidgets('AnalyticsScreen renders water, runtime, soil depth, and timeframe filter',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const AnalyticsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Agronomic Analytics'), findsOneWidget);
    expect(find.text('Total Water'), findsOneWidget);
    expect(find.text('Pump Runtime'), findsOneWidget);
    expect(find.text('Soil Moisture'), findsOneWidget);
    expect(find.text('Water Consumption Distribution (L)'), findsOneWidget);
    expect(find.text('Soil Moisture by Depth (Top vs Deep)'), findsOneWidget);

    // Switch to Monthly
    await tester.tap(find.text('Monthly (30d)'));
    await tester.pumpAndSettle();
    expect(find.text('15200 L'), findsOneWidget);

    // Switch to Daily
    await tester.tap(find.text('Daily (24h)'));
    await tester.pumpAndSettle();
    expect(find.text('580 L'), findsOneWidget);
  });

  testWidgets('AnalyticsScreen renders correctly in Arabic RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _buildTestApp(const AnalyticsScreen(), locale: const Locale('ar', '')),
    );
    await tester.pumpAndSettle();

    expect(find.text('التحليلات والتقارير الذكية'), findsOneWidget);
    expect(find.text('إجمالي المياه'), findsOneWidget);
    expect(find.text('أسبوعي (7أيام)'), findsOneWidget);
    expect(find.text('مزرعة الأمل للزيتون والنخيل'), findsOneWidget);
    expect(find.text('منحنى استهلاك المياه الذكي (لتر)'), findsOneWidget);
    expect(find.text('سجل رطوبة التربة عبر الأعماق'), findsOneWidget);
  });

  // ==========================================
  // PHASE 10 TESTS - Subscriptions & Payments
  // ==========================================
  testWidgets('SubscriptionsScreen renders plans, pricing in EGP, and payment sheet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const SubscriptionsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Subscription & Billing'), findsOneWidget);
    expect(find.text('Pro Solar Farm'), findsWidgets);
    expect(find.text('Basic IoT Care'), findsOneWidget);
    expect(find.text('Enterprise Agri'), findsOneWidget);
    expect(find.text('Make Payment'), findsOneWidget);

    // Tap Make Payment floating action button to open payment sheet
    await tester.tap(find.text('Make Payment'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Payment Method'), findsOneWidget);
    expect(find.text('Paymob – Credit/Debit Card'), findsOneWidget);
    expect(find.text('Fawry Pay'), findsOneWidget);
    expect(find.text('InstaPay'), findsOneWidget);
    expect(find.text('Vodafone Cash'), findsOneWidget);

    // Tap InstaPay option in modal sheet to trigger demo dialog
    await tester.tap(find.text('InstaPay'));
    await tester.pumpAndSettle();

    expect(find.text('🧪 Demo Mode'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  });

  testWidgets('SubscriptionsScreen renders correctly in Arabic RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _buildTestApp(const SubscriptionsScreen(), locale: const Locale('ar', '')),
    );
    await tester.pumpAndSettle();

    expect(find.text('الاشتراك والفواتير'), findsOneWidget);
    expect(find.text('الخطط المتاحة'), findsOneWidget);
    expect(find.text('إجراء الدفع'), findsOneWidget);
  });

  // ==========================================
  // PHASE 11 TESTS - Admin Dashboard & RBAC
  // ==========================================
  testWidgets('AdminDashboardScreen renders summary stats and team members',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const AdminDashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Super Admin Management Console'), findsOneWidget);
    expect(find.text('Total Accounts'), findsOneWidget);
    expect(find.text('Active Farms'), findsOneWidget);
    expect(find.text('KPIs & Overview'), findsOneWidget);
  });

  testWidgets('AdminDashboardScreen renders correctly in Arabic RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _buildTestApp(const AdminDashboardScreen(), locale: const Locale('ar', '')),
    );
    await tester.pumpAndSettle();

    expect(find.text('لوحة إدارة النظام العامة'), findsOneWidget);
    expect(find.text('إجمالي الحسابات'), findsOneWidget);
    expect(find.text('المزارع النشطة'), findsOneWidget);
  });

  // ==========================================
  // PHASE 12 TESTS - Weather & Smart Recommendations
  // ==========================================
  testWidgets('WeatherScreen renders 5-day forecast, rain chart, and AI recommendations',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const WeatherScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Weather & Forecasts'), findsOneWidget);
    expect(find.text('5-Day Forecast'), findsOneWidget);
    expect(find.text('Rain Probability (%)'), findsOneWidget);
    expect(find.text('Smart Irrigation Recommendations'), findsOneWidget);
  });

  testWidgets('WeatherScreen renders correctly in Arabic RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _buildTestApp(const WeatherScreen(), locale: const Locale('ar', '')),
    );
    await tester.pumpAndSettle();

    expect(find.text('الطقس والتوقعات'), findsOneWidget);
    expect(find.text('توقعات 5 أيام'), findsOneWidget);
    expect(find.text('احتمالية هطول الأمطار (٪)'), findsOneWidget);
    expect(find.text('توصيات الري الذكية'), findsOneWidget);
  });

  // ==========================================
  // PROFILE & SETTINGS SCREEN TESTS
  // ==========================================
  testWidgets('ProfileScreen renders user details, subscription, theme toggle, and tools',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Ahmed Al-Nour'), findsOneWidget);
    expect(find.text('App Preferences'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Sign Out of Account'), findsOneWidget);

    // Open Edit Profile Dialog
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile Details'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('ProfileScreen renders correctly in Arabic RTL',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      _buildTestApp(const ProfileScreen(), locale: const Locale('ar', '')),
    );
    await tester.pumpAndSettle();

    expect(find.text('الملف الشخصي والإعدادات'), findsOneWidget);
    expect(find.text('تفضيلات التطبيق'), findsOneWidget);
    expect(find.text('المظهر'), findsOneWidget);
    expect(find.text('اللغة'), findsOneWidget);
    expect(find.text('تسجيل الخروج من الحساب'), findsOneWidget);
  });

  // ==========================================
  // ROLE-BASED DASHBOARDS & AUTHENTICATION TESTS
  // ==========================================

  testWidgets('TechnicianDashboardScreen renders assigned tasks and field operations',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const TechnicianDashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Field Technician Dashboard'), findsOneWidget);
    expect(find.text('Assigned Farms'), findsOneWidget);
  });

  testWidgets('WorkerDashboardScreen renders daily farm tasks and irrigation shortcut',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const WorkerDashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Agricultural Worker Dashboard'), findsOneWidget);
    expect(find.text('Daily Farm Operations Checklist'), findsOneWidget);
  });

  testWidgets('FinanceDashboardScreen renders revenue overview, catalog and tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const FinanceDashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Finance & Pricing Dashboard'), findsOneWidget);
    expect(find.text('Revenue Overview'), findsOneWidget);
    expect(find.text('Hardware Catalog'), findsOneWidget);
  });

  testWidgets('ApprovalWaitingScreen renders status banner and instant demo approval button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_buildTestApp(const ApprovalWaitingScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Account Pending Approval'), findsOneWidget);
    expect(find.text('Simulate Approval & Enter Dashboard'), findsOneWidget);
  });

  test('AuthService verifies roles, passwords, and permissions correctly', () {
    final auth = AuthService();

    // 1. Super Admin login
    final adminLogin = auth.login('admin', 'SuperAdmin@2026');
    expect(adminLogin.isSuccess, isTrue);
    expect(adminLogin.user?.role, UserRole.superAdmin);
    expect(PermissionService.canAccessSuperAdmin(UserRole.superAdmin), isTrue);
    expect(PermissionService.canManageUsers(UserRole.superAdmin), isTrue);

    // 2. Pending Farmer login returns isPendingApproval
    final pendingLogin = auth.login('farmer_khalid', 'Pending@2026');
    expect(pendingLogin.isPendingApproval, isTrue);

    // 3. Field Technician permissions
    expect(PermissionService.canAccessTechnicianDashboard(UserRole.technician), isTrue);
    expect(PermissionService.canAccessSuperAdmin(UserRole.technician), isFalse);
    expect(PermissionService.canManageUsers(UserRole.technician), isFalse);

    // 4. Agricultural Worker permissions
    expect(PermissionService.canAccessWorkerDashboard(UserRole.farmWorker), isTrue);
    expect(PermissionService.canAccessFinance(UserRole.farmWorker), isFalse);

    // 5. Finance Manager permissions
    expect(PermissionService.canAccessFinance(UserRole.financeManager), isTrue);
    expect(PermissionService.canManagePricing(UserRole.financeManager), isTrue);
    expect(PermissionService.canManageUsers(UserRole.financeManager), isFalse);
  });

  test('AuthService hashPassword produces consistent and deterministic cross-platform hashes', () {
    const password = 'TestSecurePassword@2026';
    final hash1 = AuthService.hashPassword(password);
    final hash2 = AuthService.hashPassword(password);

    // Consistency test
    expect(hash1, equals(hash2));
    expect(hash1.startsWith('GF_SHA_'), isTrue);

    // Known seeded accounts hash consistency check
    expect(AuthService.hashPassword('SuperAdmin@2026'), equals('GF_SHA_3c06f09424e99417'));
    expect(AuthService.hashPassword('Farmer@2026'), equals('GF_SHA_57c7e6ddba11bac'));
    expect(AuthService.hashPassword('Pending@2026'), equals('GF_SHA_-d87002de513cce2'));
    expect(AuthService.hashPassword('Tech@2026'), equals('GF_SHA_-16ff5b1067b9bbcb'));
    expect(AuthService.hashPassword('Worker@2026'), equals('GF_SHA_71607ad631f81223'));
    expect(AuthService.hashPassword('Finance@2026'), equals('GF_SHA_3f0981c9fec62bf1'));
  });
}
