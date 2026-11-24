import 'package:flutter/material.dart';

/// Lightweight bilingual strings dictionary for Green Flow.
/// Supports both English (LTR) and Arabic (RTL).
class AppStrings {
  AppStrings._();

  static bool isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  static String get(
    BuildContext context, {
    required String en,
    required String ar,
  }) {
    return isArabic(context) ? ar : en;
  }

  // Common Branding
  static String appName(BuildContext context) =>
      get(context, en: 'Green Flow', ar: 'جرين فلو');

  static String appTagline(BuildContext context) => get(
    context,
    en: 'Smart Agriculture & IoT Ecosystem',
    ar: 'الزراعة الذكية ونظم الأتمتة وإنترنت الأشياء',
  );

  static String appSubtext(BuildContext context) => get(
    context,
    en: 'Precision Irrigation • Smart Sensors',
    ar: 'ري دقيق • حساسات واستشعار ذكي',
  );

  // Splash & Initialization
  static String initializingTelemetry(BuildContext context) => get(
    context,
    en: 'Preparing your smart experience...',
    ar: 'جاري تجهيز تجربتك الذكية ...',
  );

  static String previous(BuildContext context) =>
      get(context, en: 'Previous', ar: 'السابق');

  static String esp32Ready(BuildContext context) => get(
    context,
    en: 'ESP32 Nodes & Cloud Sync Ready',
    ar: 'عقد ESP32 والمزامنة السحابية جاهزة',
  );

  static String smartFarming(BuildContext context) =>
      get(context, en: 'Smart Farming', ar: 'الزراعة الذكية');

  static String precisionWater(BuildContext context) =>
      get(context, en: 'Precision Water', ar: 'إدارة المياه');

  static String liveTelemetry(BuildContext context) =>
      get(context, en: 'Live Telemetry', ar: 'بيانات حية');

  // Onboarding Strings
  static String skip(BuildContext context) =>
      get(context, en: 'Skip', ar: 'تخطي');

  static String next(BuildContext context) =>
      get(context, en: 'Next', ar: 'التالي');

  static String getStarted(BuildContext context) =>
      get(context, en: 'Get Started', ar: 'ابدأ الآن');

  // Onboarding Page 1: Smart Agriculture
  static String onboardingTitle1(BuildContext context) =>
      get(context, en: 'Smart Agriculture', ar: 'زراعة أكثر ذكاءً');

  static String onboardingDesc1(BuildContext context) => get(
    context,
    en: 'Manage your farm using smart technology, and make every decision more accurate and efficient.',
    ar: 'أدر مزرعتك باستخدام التكنولوجيا الذكية، واجعل كل قرار أكثر دقة وكفاءة.',
  );

  // Onboarding Page 2: Smart Irrigation
  static String onboardingTitle2(BuildContext context) =>
      get(context, en: 'Save Water, Produce More', ar: 'وفر الماء، وانتج أكثر');

  static String onboardingDesc2(BuildContext context) => get(
    context,
    en: 'Smart control of irrigation systems to reduce water waste and improve crop growth.',
    ar: 'تحكّم ذكي في أنظمة الري لتقليل هدر المياه وتحسين نمو المحاصيل.',
  );

  // Onboarding Page 3: Plant & Sensor Monitoring
  static String onboardingTitle3(BuildContext context) =>
      get(context, en: 'Always Connected Farm', ar: 'مزرعتك متصلة دائمًا');

  static String onboardingDesc3(BuildContext context) => get(
    context,
    en: 'Monitor soil moisture, temperature, air humidity, and smart devices in real time from anywhere.',
    ar: 'راقب رطوبة التربة ودرجة الحرارة والرطوبة الجوية وأجهزتك الذكية بشكل لحظي ومن أي مكان.',
  );

  // Authentication Strings
  static String loginTitle(BuildContext context) =>
      get(context, en: 'Welcome Back', ar: 'مرحباً بعودتك');

  static String loginSubtitle(BuildContext context) => get(
    context,
    en: 'Sign in to access your farm telemetry and IoT controls',
    ar: 'سجّل دخولك لمتابعة بيانات مزرعتك والتحكم بأجهزة الري',
  );

  static String emailOrPhone(BuildContext context) => get(
    context,
    en: 'Email or Phone Number',
    ar: 'البريد الإلكتروني أو رقم الهاتف',
  );

  static String emailOrPhoneHint(BuildContext context) => get(
    context,
    en: 'farmer@greenflow.com or +1 234 567 890',
    ar: 'farmer@greenflow.com أو 0501234567',
  );

  static String password(BuildContext context) =>
      get(context, en: 'Password', ar: 'كلمة المرور');

  static String passwordHint(BuildContext context) =>
      get(context, en: 'Enter your password', ar: 'أدخل كلمة المرور');

  static String rememberMe(BuildContext context) =>
      get(context, en: 'Remember me', ar: 'تذكرني');

  static String forgotPassword(BuildContext context) =>
      get(context, en: 'Forgot password?', ar: 'نسيت كلمة المرور؟');

  static String loginButton(BuildContext context) =>
      get(context, en: 'Sign In', ar: 'تسجيل الدخول');

  static String dontHaveAccount(BuildContext context) =>
      get(context, en: "Don't have an account?", ar: 'ليس لديك حساب بعد؟');

  static String registerNow(BuildContext context) =>
      get(context, en: 'Create Account', ar: 'إنشاء حساب جديد');

  // Registration Strings
  static String registerTitle(BuildContext context) =>
      get(context, en: 'Create Account', ar: 'إنشاء حساب جديد');

  static String registerSubtitle(BuildContext context) => get(
    context,
    en: 'Join Green Flow and step into the future of precision farming',
    ar: 'انضم إلى جرين فلو وانطلق نحو مستقبل الزراعة الذكية المستدامة',
  );

  static String fullName(BuildContext context) =>
      get(context, en: 'Full Name', ar: 'الاسم الكامل');

  static String fullNameHint(BuildContext context) =>
      get(context, en: 'e.g. Alex Henderson', ar: 'مثال: عبد الرحمن محمد');

  static String phoneNumber(BuildContext context) =>
      get(context, en: 'Phone Number', ar: 'رقم الهاتف');

  static String phoneNumberHint(BuildContext context) =>
      get(context, en: '+1 234 567 8900', ar: '+966 50 123 4567');

  static String emailAddress(BuildContext context) =>
      get(context, en: 'Email Address', ar: 'البريد الإلكتروني');

  static String emailAddressHint(BuildContext context) =>
      get(context, en: 'alex@example.com', ar: 'user@example.com');

  static String confirmPassword(BuildContext context) =>
      get(context, en: 'Confirm Password', ar: 'تأكيد كلمة المرور');

  static String confirmPasswordHint(BuildContext context) =>
      get(context, en: 'Re-enter your password', ar: 'أعد كتابة كلمة المرور');

  static String agreeToTerms(BuildContext context) => get(
    context,
    en: 'I agree to the Terms of Service and Privacy Policy',
    ar: 'أوافق على الشروط والأحكام وسياسة الخصوصية',
  );

  static String createAccountButton(BuildContext context) =>
      get(context, en: 'Create My Account', ar: 'تأكيد وإنشاء الحساب');

  static String alreadyHaveAccount(BuildContext context) =>
      get(context, en: 'Already have an account?', ar: 'لديك حساب بالفعل؟');

  static String signInLink(BuildContext context) =>
      get(context, en: 'Sign In', ar: 'تسجيل الدخول');

  // Form Validations
  static String enterEmailOrPhone(BuildContext context) => get(
    context,
    en: 'Please enter your email or phone number',
    ar: 'يرجى إدخال البريد الإلكتروني أو رقم الهاتف',
  );

  static String enterValidEmail(BuildContext context) => get(
    context,
    en: 'Please enter a valid email address',
    ar: 'يرجى إدخال بريد إلكتروني صحيح',
  );

  static String enterValidPhone(BuildContext context) => get(
    context,
    en: 'Please enter a valid phone number',
    ar: 'يرجى إدخال رقم هاتف صحيح',
  );

  static String enterFullName(BuildContext context) => get(
    context,
    en: 'Please enter your full name',
    ar: 'يرجى إدخال الاسم الكامل',
  );

  static String enterPassword(BuildContext context) => get(
    context,
    en: 'Please enter your password',
    ar: 'يرجى إدخال كلمة المرور',
  );

  static String passwordTooShort(BuildContext context) => get(
    context,
    en: 'Password must be at least 6 characters',
    ar: 'يجب ألا تقل كلمة المرور عن 6 خانات',
  );

  static String confirmYourPassword(BuildContext context) => get(
    context,
    en: 'Please confirm your password',
    ar: 'يرجى تأكيد كلمة المرور',
  );

  static String passwordsDoNotMatch(BuildContext context) => get(
    context,
    en: 'Passwords do not match',
    ar: 'كلمتا المرور غير متطابقتين',
  );

  static String mustAcceptTerms(BuildContext context) => get(
    context,
    en: 'You must accept the terms and conditions',
    ar: 'يجب الموافقة على الشروط والأحكام للمتابعة',
  );

  static String loginSuccess(BuildContext context) => get(
    context,
    en: 'Signed in successfully! Welcome to Green Flow.',
    ar: 'تم تسجيل الدخول بنجاح! مرحباً بك في جرين فلو.',
  );

  static String registerSuccess(BuildContext context) => get(
    context,
    en: 'Account created successfully! Welcome aboard.',
    ar: 'تم إنشاء الحساب بنجاح! أهلاً بك في المنظومة.',
  );

  static String forgotPasswordSent(BuildContext context) => get(
    context,
    en: 'Password reset link sent to your registered contact.',
    ar: 'تم إرسال رابط استعادة كلمة المرور إلى بيانات الاتصال.',
  );

  // Demo Login Quick Fill
  static String demoQuickFill(BuildContext context) =>
      get(context, en: 'Quick Demo Fill', ar: 'ملء تجريبي سريع');

  // Dashboard Strings
  static String welcomeBackFarmer(BuildContext context) =>
      get(context, en: 'Welcome back,', ar: 'مرحباً بعودتك،');

  static String defaultFarmerName(BuildContext context) =>
      get(context, en: 'Farmer Ahmed', ar: 'المزارع أحمد');

  static String dashboardDate(BuildContext context) => get(
    context,
    en: 'Wednesday, 18 Nov 2026',
    ar: 'الأربعاء، 18 نوفمبر 2026',
  );

  static String totalFarms(BuildContext context) =>
      get(context, en: 'Total Farms', ar: 'إجمالي المزارع');

  static String totalTrees(BuildContext context) =>
      get(context, en: 'Irrigation Zones', ar: 'مناطق الري');

  static String connectedDevices(BuildContext context) =>
      get(context, en: 'IoT Devices', ar: 'الأجهزة والحساسات');

  static String overallHealth(BuildContext context) =>
      get(context, en: 'Overall Health', ar: 'الصحة العامة');

  static String environmentalMonitoring(BuildContext context) => get(
    context,
    en: 'Environmental Monitoring',
    ar: 'المراقبة البيئية الحية',
  );

  static String soilMoisture(BuildContext context) =>
      get(context, en: 'Soil Moisture', ar: 'رطوبة التربة');

  static String temperature(BuildContext context) =>
      get(context, en: 'Temperature', ar: 'درجة الحرارة');

  static String airHumidity(BuildContext context) =>
      get(context, en: 'Air Humidity', ar: 'رطوبة الهواء');

  static String waterConsumption(BuildContext context) =>
      get(context, en: 'Water Consumption', ar: 'استهلاك المياه');

  static String optimal(BuildContext context) =>
      get(context, en: 'Optimal', ar: 'مثالية');

  static String low(BuildContext context) =>
      get(context, en: 'Low', ar: 'منخفضة');

  static String high(BuildContext context) =>
      get(context, en: 'High', ar: 'مرتفعة');

  static String warningHigh(BuildContext context) =>
      get(context, en: 'High Alert', ar: 'تنبيه - مرتفعة');

  static String vsYesterday(BuildContext context, String percent) =>
      get(context, en: '$percent vs yesterday', ar: '$percent مقارنة بالأمس');

  static String smartIrrigationControl(BuildContext context) =>
      get(context, en: 'Smart Irrigation Control', ar: 'التحكم الذكي بالري');

  static String pumpStatus(BuildContext context) =>
      get(context, en: 'Pump Status', ar: 'حالة المضخة');

  static String pumpActive(BuildContext context) =>
      get(context, en: 'Pumping Active', ar: 'المضخة تعمل');

  static String pumpIdle(BuildContext context) =>
      get(context, en: 'Pump Standby', ar: 'المضخة متوقفة');

  static String automaticMode(BuildContext context) =>
      get(context, en: 'Automatic Mode', ar: 'النمط الآلي');

  static String manualMode(BuildContext context) =>
      get(context, en: 'Manual Mode', ar: 'النمط اليدوي');

  static String nextScheduled(BuildContext context) =>
      get(context, en: 'Next Scheduled', ar: 'الري القادم');

  static String lastActivity(BuildContext context) =>
      get(context, en: 'Last Activity', ar: 'آخر دورة ري');

  static String startIrrigation(BuildContext context) =>
      get(context, en: 'Start Irrigation', ar: 'تشغيل الري الآن');

  static String stopIrrigation(BuildContext context) =>
      get(context, en: 'Stop Irrigation', ar: 'إيقاف دورة الري');

  static String demoNotice(BuildContext context) => get(
    context,
    en: 'Interactive Demo • Local Simulation State',
    ar: 'محاكاة تفاعلية • حالة تجريبية محلية',
  );

  static String plantHealthSection(BuildContext context) =>
      get(context, en: 'Plant & Crop Health', ar: 'صحة المحاصيل والنباتات');

  static String healthyPlants(BuildContext context) =>
      get(context, en: 'Healthy', ar: 'سليمة وممتازة');

  static String attentionPlants(BuildContext context) =>
      get(context, en: 'Needs Attention', ar: 'تحتاج متابعة');

  static String criticalPlants(BuildContext context) =>
      get(context, en: 'Critical', ar: 'حالة حرجة');

  static String waterAnalytics(BuildContext context) => get(
    context,
    en: 'Water Consumption Analytics',
    ar: 'تحليلات استهلاك المياه',
  );

  static String weeklyTotal(BuildContext context) =>
      get(context, en: 'Weekly Total', ar: 'الإجمالي الأسبوعي');

  static String dailyAverage(BuildContext context) =>
      get(context, en: 'Daily Average', ar: 'المعدل اليومي');

  static String litersUnit(BuildContext context) =>
      get(context, en: 'Liters', ar: 'لتر');

  static String recentActivities(BuildContext context) =>
      get(context, en: 'Recent Farm Activities', ar: 'أحدث الأنشطة والتنبيهات');

  static String quickAccess(BuildContext context) =>
      get(context, en: 'Quick Access', ar: 'الوصول السريع');

  static String myFarms(BuildContext context) =>
      get(context, en: 'My Farms', ar: 'مزارعي');

  static String devices(BuildContext context) =>
      get(context, en: 'Devices', ar: 'الأجهزة');

  static String irrigation(BuildContext context) =>
      get(context, en: 'Irrigation', ar: 'الري');

  static String analytics(BuildContext context) =>
      get(context, en: 'Analytics', ar: 'التحليلات');

  // Bottom Navigation
  static String navHome(BuildContext context) =>
      get(context, en: 'Home', ar: 'الرئيسية');

  static String navFarms(BuildContext context) =>
      get(context, en: 'Farms', ar: 'المزارع');

  static String navDevices(BuildContext context) =>
      get(context, en: 'Devices', ar: 'الأجهزة');

  static String navAnalytics(BuildContext context) =>
      get(context, en: 'Analytics', ar: 'التحليلات');

  static String navMonitoring(BuildContext context) =>
      get(context, en: 'Monitoring', ar: 'المراقبة');

  static String navIrrigation(BuildContext context) =>
      get(context, en: 'Irrigation', ar: 'الري');

  static String navMore(BuildContext context) =>
      get(context, en: 'More', ar: 'المزيد');

  static String navProfile(BuildContext context) =>
      get(context, en: 'Profile', ar: 'حسابي');

  static String navReports(BuildContext context) =>
      get(context, en: 'Reports', ar: 'التقارير');

  static String navAccount(BuildContext context) =>
      get(context, en: 'Account', ar: 'الحساب');

  // Navigation Placeholders
  static String screenUnderDev(BuildContext context, String title) => get(
    context,
    en: '$title screen will be integrated in the upcoming phase.',
    ar: 'سيتم بناء وتفعيل شاشة $title في المرحلة القادمة.',
  );

  // ==========================================
  // PHASE 4: FARMS MANAGEMENT & INSPECTION
  // ==========================================

  // Farms Screen
  static String farmsTitle(BuildContext context) =>
      get(context, en: 'Farm Management', ar: 'إدارة المزارع والحقول');

  static String farmsSubtitle(BuildContext context) => get(
    context,
    en: 'Monitor parcels, crop zones, solar arrays & inspections',
    ar: 'إدارة القطاعات، مناطق المحاصيل، الطاقة الشمسية والمعاينات',
  );

  static String addFarm(BuildContext context) =>
      get(context, en: 'Add Farm', ar: 'إضافة مزرعة');

  static String editFarm(BuildContext context) =>
      get(context, en: 'Edit Farm', ar: 'تعديل المزرعة');

  static String deleteFarm(BuildContext context) =>
      get(context, en: 'Delete Farm', ar: 'حذف المزرعة');

  static String searchFarmsHint(BuildContext context) => get(
    context,
    en: 'Search by farm name, location, or crop...',
    ar: 'ابحث باسم المزرعة، الموقع، أو المحصول...',
  );

  static String totalFarmArea(BuildContext context) =>
      get(context, en: 'Total Area', ar: 'إجمالي المساحة');

  static String totalZones(BuildContext context) =>
      get(context, en: 'Irrigation Zones', ar: 'مناطق الري');

  static String noFarmsFound(BuildContext context) => get(
    context,
    en: 'No farms match your search criteria',
    ar: 'لا توجد مزارع مطابقة لبحثك',
  );

  static String noFarmsYet(BuildContext context) => get(
    context,
    en: 'No farms registered yet. Add your first farm!',
    ar: 'لم تقم بتسجيل أي مزرعة بعد. أضف مزرعتك الأولى!',
  );

  // Farm Details
  static String farmDetailsTitle(BuildContext context) =>
      get(context, en: 'Farm Details', ar: 'تفاصيل المزرعة');

  static String farmOverview(BuildContext context) =>
      get(context, en: 'Farm Overview', ar: 'نظرة عامة على المزرعة');

  static String farmLocation(BuildContext context) =>
      get(context, en: 'Location & Region', ar: 'الموقع والمنطقة');

  static String cropsAndTrees(BuildContext context) =>
      get(context, en: 'Crops & Trees', ar: 'المحاصيل والأشجار');

  static String waterSource(BuildContext context) =>
      get(context, en: 'Water Supply Source', ar: 'مصدر المياه الرئيسي');

  static String irrigationSystem(BuildContext context) =>
      get(context, en: 'Irrigation System', ar: 'نظام الري المستخدم');

  static String solarPowered(BuildContext context) => get(
    context,
    en: 'Solar-Powered Smart Grid',
    ar: 'مدارة بنظام الطاقة الشمسية',
  );

  static String conventionalPower(BuildContext context) => get(
    context,
    en: 'Grid Electric Powered',
    ar: 'متصلة بشبكة الكهرباء العامة',
  );

  static String irrigationZonesSection(BuildContext context) =>
      get(context, en: 'Irrigation Zones', ar: 'قطاعات ومناطق الري');

  static String addZone(BuildContext context) =>
      get(context, en: 'Add Zone', ar: 'إضافة منطقة ري');

  static String editZone(BuildContext context) =>
      get(context, en: 'Edit Zone', ar: 'تعديل المنطقة');

  static String deleteZone(BuildContext context) =>
      get(context, en: 'Delete Zone', ar: 'حذف المنطقة');

  static String assignedDevices(BuildContext context) => get(
    context,
    en: 'Sensors & Hardware Nodes',
    ar: 'المستشعرات والعتاد المتصل',
  );

  static String inspectionStatusTitle(BuildContext context) => get(
    context,
    en: 'Technical Inspection & Quotation',
    ar: 'حالة المعاينة والمقايسة الفنية',
  );

  static String requestTechnicalInspection(BuildContext context) => get(
    context,
    en: 'Request Technical Inspection',
    ar: 'طلب معاينة فنية ميدانية',
  );

  static String viewInspectionDetails(BuildContext context) => get(
    context,
    en: 'View Inspection & Quote',
    ar: 'عرض تفاصيل المعاينة والمقايسة',
  );

  static String confirmDeleteFarm(BuildContext context) => get(
    context,
    en: 'Are you sure you want to delete this farm? This action will remove all associated zones and records.',
    ar: 'هل أنت متأكد من حذف هذه المزرعة؟ سيؤدي هذا الإجراء إلى حذف جميع مناطق الري والسجلات المرتبطة بها.',
  );

  static String confirmDeleteZone(BuildContext context) => get(
    context,
    en: 'Are you sure you want to delete this irrigation zone?',
    ar: 'هل أنت متأكد من رغبتك في حذف منطقة الري هذه؟',
  );

  static String cancel(BuildContext context) =>
      get(context, en: 'Cancel', ar: 'إلغاء');

  static String delete(BuildContext context) =>
      get(context, en: 'Delete', ar: 'حذف');

  static String save(BuildContext context) =>
      get(context, en: 'Save Changes', ar: 'حفظ التعديلات');

  static String create(BuildContext context) =>
      get(context, en: 'Create Farm', ar: 'إنشاء المزرعة');

  // Form Fields
  static String farmName(BuildContext context) =>
      get(context, en: 'Farm Name', ar: 'اسم المزرعة');

  static String farmNameHint(BuildContext context) => get(
    context,
    en: 'e.g., Al-Amal Olive Farm',
    ar: 'مثال: مزرعة الأمل للزيتون',
  );

  static String locationHint(BuildContext context) => get(
    context,
    en: 'e.g., Wadi El Natrun, Beheira',
    ar: 'مثال: وادي النطرون، البحيرة',
  );

  static String farmArea(BuildContext context) =>
      get(context, en: 'Farm Area', ar: 'المساحة الإجمالية');

  static String areaUnit(BuildContext context) =>
      get(context, en: 'Area Unit', ar: 'وحدة القياس');

  static String treesCount(BuildContext context) =>
      get(context, en: 'Number of Trees / Palms', ar: 'عدد الأشجار / النخيل');

  static String cropsTypes(BuildContext context) =>
      get(context, en: 'Main Crop Types', ar: 'أنواع المحاصيل الرئيسية');

  static String selectOrTypeCrop(BuildContext context) =>
      get(context, en: 'Select or add crops', ar: 'اختر أو أضف محاصيل');

  static String additionalNotes(BuildContext context) => get(
    context,
    en: 'Additional Notes & Soil info',
    ar: 'ملاحظات إضافية ومعلومات التربة',
  );

  static String additionalNotesHint(BuildContext context) => get(
    context,
    en: 'Enter details about soil salinity, well depth, pump specs...',
    ar: 'اكتب تفاصيل عن ملوحة التربة، عمق البئر، قدرة الطلمبة...',
  );

  static String solarPowerOption(BuildContext context) => get(
    context,
    en: 'Equipped with Solar Energy System',
    ar: 'المزرعة مجهزة بمنظومة طاقة شمسية',
  );

  // Validation
  static String fieldRequired(BuildContext context) =>
      get(context, en: 'This field is required', ar: 'هذا الحقل مطلوب');

  static String enterValidNumber(BuildContext context) => get(
    context,
    en: 'Please enter a valid positive number',
    ar: 'يرجى إدخال رقم صحيح وموجب',
  );

  static String selectAtLeastOneCrop(BuildContext context) => get(
    context,
    en: 'Please select or add at least one crop',
    ar: 'يرجى اختيار أو كتابة محصول واحد على الأقل',
  );

  // Zone Form
  static String zoneName(BuildContext context) =>
      get(context, en: 'Zone Name / Sector', ar: 'اسم المنطقة / القطاع');

  static String zoneNameHint(BuildContext context) => get(
    context,
    en: 'e.g., Zone A - East Olives',
    ar: 'مثال: المنطقة أ - زيتون شرقي',
  );

  static String zoneArea(BuildContext context) =>
      get(context, en: 'Zone Area', ar: 'مساحة المنطقة');

  static String zoneCrop(BuildContext context) =>
      get(context, en: 'Zone Crop Type', ar: 'محصول هذا القطاع');

  static String waterRequirements(BuildContext context) => get(
    context,
    en: 'Daily Water Needs (Liters/Day)',
    ar: 'الاحتياج المائي اليومي (لتر/يوم)',
  );

  static String soilType(BuildContext context) =>
      get(context, en: 'Soil Texture / Classification', ar: 'نوع وقوام التربة');

  static String valveCount(BuildContext context) =>
      get(context, en: 'Solenoid Valves', ar: 'عدد المحابس الكهربائية');

  static String sensorCount(BuildContext context) =>
      get(context, en: 'Sensor Nodes', ar: 'مجسات التربة المخصصة');

  // Inspection Request Workflow
  static String inspectionRequestTitle(BuildContext context) => get(
    context,
    en: 'Request Farm Inspection',
    ar: 'طلب معاينة فنية للمزرعة',
  );

  static String inspectionSubtitle(BuildContext context) => get(
    context,
    en: 'Green Flow field engineers visit your farm to measure soil, water pressure & design your solar IoT solution.',
    ar: 'يزور مهندسو Green Flow مزرعتك لفحص التربة، ضغط المياه، وتصميم المنظومة الذكية والطاقة الشمسية.',
  );

  static String customerName(BuildContext context) => get(
    context,
    en: 'Customer / Farm Owner Name',
    ar: 'اسم المزارع / مالك المزرعة',
  );

  static String preferredInspectionDate(BuildContext context) =>
      get(context, en: 'Preferred Visit Date', ar: 'تاريخ الزيارة المفضل');

  static String selectDate(BuildContext context) =>
      get(context, en: 'Select Date', ar: 'اختر التاريخ');

  static String submitInspectionRequest(BuildContext context) => get(
    context,
    en: 'Submit Inspection Request',
    ar: 'إرسال طلب المعاينة الميدانية',
  );

  static String inspectionSubmittedTitle(BuildContext context) => get(
    context,
    en: 'Inspection Request Submitted!',
    ar: 'تم استلام طلب المعاينة بنجاح!',
  );

  static String inspectionSubmittedDesc(BuildContext context) => get(
    context,
    en: 'Our smart agriculture engineering team will review your application and contact you within 24 hours to confirm the visit schedule.',
    ar: 'سيقوم الفريق الهندسي للزراعة الذكية بمراجعة بيانات مزرعتك والتواصل معك خلال 24 ساعة لتأكيد موعد الزيارة الميدانية.',
  );

  static String requestRefNumber(BuildContext context) =>
      get(context, en: 'Request Ref Number', ar: 'رقم مرجع الطلب');

  static String trackInspectionRequests(BuildContext context) => get(
    context,
    en: 'Track Inspection Requests',
    ar: 'متابعة طلبات المعاينة',
  );

  static String inspectionListTitle(BuildContext context) => get(
    context,
    en: 'Inspection & Quotation Requests',
    ar: 'طلبات المعاينة والمقايسات',
  );

  static String allRequests(BuildContext context) =>
      get(context, en: 'All Requests', ar: 'جميع الطلبات');

  static String pendingRequests(BuildContext context) =>
      get(context, en: 'Pending', ar: 'قيد الانتظار');

  static String scheduledRequests(BuildContext context) =>
      get(context, en: 'Scheduled', ar: 'مجدولة');

  static String quotationReadyRequests(BuildContext context) =>
      get(context, en: 'Quotation Ready', ar: 'المقايسة جاهزة');

  // Inspection Details & Quotation Workflow
  static String inspectionDetailsTitle(BuildContext context) => get(
    context,
    en: 'Inspection & Quotation Review',
    ar: 'تفاصيل المعاينة والمقايسة',
  );

  static String engineeringProgress(BuildContext context) => get(
    context,
    en: 'Inspection Progress',
    ar: 'مراحل سير المعاينة والتعاقد',
  );

  static String fieldEngineerNotes(BuildContext context) => get(
    context,
    en: 'Field Engineer Report & Notes',
    ar: 'تقرير وملاحظات المهندس الميداني',
  );

  static String customizedQuotation(BuildContext context) => get(
    context,
    en: 'Hardware & Solar Quotation',
    ar: 'المقايسة الفنية لمنظومة العتاد والطاقة',
  );

  static String hardwareItems(BuildContext context) => get(
    context,
    en: 'Hardware Components & IoT Equipment',
    ar: 'مكونات العتاد ومستشعرات إنترنت الأشياء',
  );

  static String oneTimeHardwareCost(BuildContext context) => get(
    context,
    en: 'One-Time Hardware & Setup Fee',
    ar: 'تكلفة العتاد والتوريد والتركيب (مرة واحدة)',
  );

  static String monthlySubscriptionCost(BuildContext context) => get(
    context,
    en: 'Recurring Monthly IoT Subscription',
    ar: 'الاشتراك الشهري للخدمات السحابية والري الذكي',
  );

  static String quotationPricingNotice(BuildContext context) => get(
    context,
    en: 'Commercial quotation for demonstration. Final pricing is customized according to field inspection measurements.',
    ar: 'المقايسة الاسترشادية لأغراض العرض التوضيحي. يتم تحديد الأسعار النهائية وفق نتائج المعاينة الحقلية.',
  );

  static String acceptQuotation(BuildContext context) => get(
    context,
    en: 'Accept Quotation & Proceed to Contract',
    ar: 'الموافقة على المقايسة ومتابعة التعاقد',
  );

  // Device Management & ESP32 Strings
  static String pingDevice(BuildContext context) => get(
    context,
    en: 'Sending hardware ping to ESP32 node...',
    ar: 'إرسال إشارة اختبار نبضية للعقدة...',
  );

  static String updateFirmware(BuildContext context) => get(
    context,
    en: 'Update Firmware (OTA)',
    ar: 'تحديث البرنامج الثابت (OTA)',
  );

  static String firmwareDemoNote(BuildContext context) => get(
    context,
    en: 'OTA Firmware update simulation: Node will verify SHA256 checksum and flash partition in production.',
    ar: 'محاكاة التحديث عبر الهواء (OTA): ستقوم العقدة بالتحقق من الحزمة وبرمجتها لاسلكياً.',
  );

  static String ok(BuildContext context) => get(context, en: 'OK', ar: 'حسناً');

  static String confirm(BuildContext context) =>
      get(context, en: 'Confirm', ar: 'تأكيد');

  static String removeDevice(BuildContext context) =>
      get(context, en: 'Remove Device', ar: 'حذف الجهاز');

  static String removeDeviceConfirm(BuildContext context) => get(
    context,
    en: 'Are you sure you want to unpair and remove this IoT node?',
    ar: 'هل أنت متأكد من إلغاء اقتران وحذف عقدة إنترنت الأشياء هذه؟',
  );

  static String deviceRemoved(BuildContext context) => get(
    context,
    en: 'Device removed successfully',
    ar: 'تم حذف الجهاز بنجاح',
  );

  static String connectionInfo(BuildContext context) => get(
    context,
    en: 'Hardware & Network Specifications',
    ar: 'مواصفات العتاد والاتصال',
  );

  static String lastSeen(BuildContext context) =>
      get(context, en: 'Last Heartbeat', ar: 'آخر نبضة اتصال');

  static String farm(BuildContext context) =>
      get(context, en: 'Assigned Farm', ar: 'المزرعة المرتبطة');

  static String ping(BuildContext context) =>
      get(context, en: 'Ping Test', ar: 'اختبار الاتصال');

  static String remove(BuildContext context) =>
      get(context, en: 'Delete Node', ar: 'حذف العقدة');

  static String soilMoistureTop(BuildContext context) => get(
    context,
    en: 'Topsoil Moisture (25cm)',
    ar: 'رطوبة الطبقة السطحية (25 سم)',
  );

  static String soilMoistureDeep(BuildContext context) => get(
    context,
    en: 'Root-zone Moisture (50cm)',
    ar: 'رطوبة منطقة الجذور (50 سم)',
  );

  static String soilTemp(BuildContext context) =>
      get(context, en: 'Soil Temperature', ar: 'حرارة التربة');

  static String ambientTemp(BuildContext context) =>
      get(context, en: 'Ambient Temperature', ar: 'درجة حرارة الجو');

  static String humidity(BuildContext context) =>
      get(context, en: 'Relative Air Humidity', ar: 'رطوبة الهواء النسبية');

  static String waterLevel(BuildContext context) =>
      get(context, en: 'Well Water Depth', ar: 'عمق منسوب المياه');

  static String salinity(BuildContext context) =>
      get(context, en: 'Soil Salinity (EC)', ar: 'ملوحة التربة (EC)');

  // Device Setup Wizard Strings
  static String deviceSetupWizard(BuildContext context) => get(
    context,
    en: 'ESP32 Device Setup Wizard',
    ar: 'معالج إعداد وربط أجهزة ESP32',
  );

  static String serialRequired(BuildContext context) => get(
    context,
    en: 'Please enter or scan a valid Serial Number',
    ar: 'يرجى إدخال أو مسح رقم تسلسلي صالح',
  );

  static String deviceAddedDemo(BuildContext context) => get(
    context,
    en: 'IoT Node paired and activated successfully',
    ar: 'تم ربط وتفعيل جهاز إنترنت الأشياء بنجاح',
  );

  static String back(BuildContext context) =>
      get(context, en: 'Back', ar: 'رجوع');

  static String activate(BuildContext context) =>
      get(context, en: 'Activate Node', ar: 'تفعيل العقدة');

  static String chooseCategory(BuildContext context) => get(
    context,
    en: '1. Select Device Category',
    ar: '١. اختر نوع وفئة الجهاز',
  );

  static String enterSerial(BuildContext context) => get(
    context,
    en: '2. Device Serial & Barcode',
    ar: '٢. الرقم التسلسلي والباركود',
  );

  static String serialNumber(BuildContext context) =>
      get(context, en: 'Serial Number / MAC', ar: 'الرقم التسلسلي / MAC');

  static String simulateQrScan(BuildContext context) =>
      get(context, en: 'Simulate QR Code Scan', ar: 'محاكاة مسح رمز QR');

  static String assignFarm(BuildContext context) => get(
    context,
    en: '3. Assign to Farm & Zone',
    ar: '٣. التخصيص للمزرعة والقطاع',
  );

  static String selectFarm(BuildContext context) =>
      get(context, en: 'Select Farm', ar: 'اختر المزرعة');

  static String confirmActivate(BuildContext context) => get(
    context,
    en: '4. Summary & Activation',
    ar: '٤. ملخص التكوين والتفعيل',
  );

  static String category(BuildContext context) =>
      get(context, en: 'Device Type', ar: 'نوع الجهاز');

  static String reviewInfo(BuildContext context) => get(
    context,
    en: 'Please verify the hardware specifications and antenna line-of-sight before final activation.',
    ar: 'يرجى مراجعة مواصفات العتاد وضمان وضوح مسار الهوائي قبل التفعيل النهائي.',
  );

  // Authentication & Registration Form Strings
  static String enterPhoneNumber(BuildContext context) =>
      get(context, en: 'Enter phone number', ar: 'أدخل رقم الهاتف');

  static String enterEmailAddress(BuildContext context) =>
      get(context, en: 'Enter email address', ar: 'أدخل البريد الإلكتروني');

  static String enterConfirmPassword(BuildContext context) =>
      get(context, en: 'Confirm your password', ar: 'تأكيد كلمة المرور');

  static String loginNow(BuildContext context) =>
      get(context, en: 'Sign in now', ar: 'تسجيل الدخول الآن');
}
