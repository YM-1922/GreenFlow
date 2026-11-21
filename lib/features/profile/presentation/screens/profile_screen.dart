import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../app/app.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/utils/file_io.dart' as file_io;

/// User profile model for local persistence and editing.
class UserProfileData {
  String name;
  String email;
  String phone;
  String farmName;
  UserRole role;

  UserProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.farmName,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'farmName': farmName,
        'role': role.index,
      };

  factory UserProfileData.fromJson(Map<String, dynamic> json) => UserProfileData(
        name: json['name'] as String? ?? 'Ahmed Al-Nour',
        email: json['email'] as String? ?? 'ahmed@alnour-farm.com',
        phone: json['phone'] as String? ?? '+20 111 234 5678',
        farmName: json['farmName'] as String? ?? 'Al-Nour Olive & Date Palms',
        role: UserRole.values[(json['role'] as int? ?? 1).clamp(0, UserRole.values.length - 1)],
      );
}

/// Service managing user profile data persistence locally.
class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;

  static const String _prefFileName = '.greenflow_profile_pref';

  late UserProfileData _profile;

  UserProfileService._internal() {
    _loadProfile();
  }

  UserProfileData get profile => _profile;

  void _loadProfile() {
    try {
      final content = file_io.readFileSync(_prefFileName);
      if (content != null) {
        final map = jsonDecode(content) as Map<String, dynamic>;
        _profile = UserProfileData.fromJson(map);
        return;
      }
    } catch (_) {}
    _profile = UserProfileData(
      name: 'Ahmed Al-Nour',
      email: 'ahmed@alnour-farm.com',
      phone: '+20 111 234 5678',
      farmName: 'Al-Nour Olive & Date Palms',
      role: UserRole.farmOwner,
    );
  }

  void saveProfile(UserProfileData updated) {
    _profile = updated;
    try {
      file_io.writeFileSync(_prefFileName, jsonEncode(_profile.toJson()));
    } catch (_) {}
    notifyListeners();
  }
}

/// Full functional Profile & Settings Screen (Task 4).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final ThemeService _themeService = ThemeService();

  late UserProfileData _user;

  @override
  void initState() {
    super.initState();
    _user = _profileService.profile;
    _profileService.addListener(_onProfileChanged);
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _profileService.removeListener(_onProfileChanged);
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {
        _user = _profileService.profile;
      });
    }
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  bool get _isArabic {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar';
  }

  String _t(String en, String ar) => _isArabic ? ar : en;

  void _openEditProfileDialog() {
    final nameController = TextEditingController(text: _user.name);
    final emailController = TextEditingController(text: _user.email);
    final phoneController = TextEditingController(text: _user.phone);
    final farmController = TextEditingController(text: _user.farmName);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              _t('Edit Profile Details', 'تعديل البيانات الشخصية'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: _t('Full Name', 'الاسم الكامل'),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: _t('Email Address', 'البريد الإلكتروني'),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: _t('Phone Number', 'رقم الهاتف'),
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: farmController,
                    decoration: InputDecoration(
                      labelText: _t('Farm Name', 'اسم المزرعة'),
                      prefixIcon: const Icon(Icons.landscape_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Security Rule: Role cannot be modified by user through profile
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_t("Assigned Role:", "الدور الوظيفي المعتمد:")} ${_isArabic ? _user.role.labelAr : _user.role.labelEn}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(_t('Cancel', 'إلغاء')),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final updated = UserProfileData(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                    farmName: farmController.text.trim(),
                    role: _user.role,
                  );
                  _profileService.saveProfile(updated);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _t('Profile updated successfully', 'تم تحديث البيانات بنجاح'),
                      ),
                      backgroundColor: AppColors.primaryGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(_t('Save Changes', 'حفظ التغييرات')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(_t('Sign Out', 'تسجيل الخروج')),
          ],
        ),
        content: Text(
          _t(
            'Are you sure you want to sign out from Green Flow?',
            'هل أنت متأكد من رغبتك في تسجيل الخروج من Green Flow؟',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('Cancel', 'إلغاء')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            child: Text(_t('Sign Out', 'خروج')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryGreen;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          _t('Profile & Settings', 'الملف الشخصي والإعدادات'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: _t('Edit Profile', 'تعديل الملف'),
            onPressed: _openEditProfileDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // ── User Header Card ─────────────────────────────────────
            _buildUserHeaderCard(isDark, primaryColor),
            const SizedBox(height: 20),

            // ── Subscription Status Card ─────────────────────────────
            _buildSubscriptionCard(isDark, primaryColor),
            const SizedBox(height: 20),

            // ── Preferences Section ──────────────────────────────────
            _buildSectionHeader(_t('App Preferences', 'تفضيلات التطبيق')),
            const SizedBox(height: 8),
            _buildPreferencesCard(isDark, primaryColor),
            const SizedBox(height: 20),

            // ── Management & Navigation ──────────────────────────────
            _buildSectionHeader(_t('Management & Tools', 'الإدارة والأدوات')),
            const SizedBox(height: 8),
            _buildManagementCard(isDark, primaryColor),
            const SizedBox(height: 20),

            // ── Sign Out Button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: Text(
                  _t('Sign Out of Account', 'تسجيل الخروج من الحساب'),
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _showLogoutConfirmation,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${AppConstants.appName} v${AppConstants.appVersion} • Smart Agri IoT',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: _isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildUserHeaderCard(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Photo Placeholder with edit badge
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: primaryColor.withValues(alpha: 0.15),
                child: Text(
                  _user.name.isNotEmpty ? _user.name.substring(0, 1).toUpperCase() : 'A',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              PositionCircleBadge(primaryColor: primaryColor),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _user.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _user.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isArabic ? _user.role.labelAr : _user.role.labelEn,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFECFDF5), Colors.white],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.workspace_premium_rounded, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('Pro Solar Farm Plan', 'باقة مزرعة الطاقة الاحترافية'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _t('Active • 399 EGP/month', 'نشط • 399 ج.م/شهرياً'),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.subscriptions);
            },
            child: Text(
              _t('Manage', 'إدارة'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(bool isDark, Color primaryColor) {
    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            // Theme Switcher Tile
            ListTile(
              leading: Icon(
                _themeService.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: primaryColor,
              ),
              title: Text(_t('Appearance', 'المظهر')),
              subtitle: Text(
                _themeService.isDarkMode
                    ? _t('Dark Mode active', 'الوضع الداكن نشط')
                    : _t('Light Mode active (Default)', 'الوضع الفاتح نشط (الافتراضي)'),
              ),
              trailing: Switch.adaptive(
                value: _themeService.isDarkMode,
                activeTrackColor: primaryColor,
                onChanged: (val) {
                  _themeService.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            // Language Switcher Tile
            ListTile(
              leading: Icon(Icons.language_rounded, color: primaryColor),
              title: Text(_t('Language', 'اللغة')),
              subtitle: Text(_isArabic ? 'العربية (RTL)' : 'English (LTR)'),
              trailing: DropdownButton<String>(
                value: _isArabic ? 'ar' : 'en',
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (lang) {
                  if (lang != null) {
                    GreenFlowApp.setLocale(context, Locale(lang));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(bool isDark, Color primaryColor) {
    final canAccessAdmin = PermissionService.canManageUsers(_user.role);

    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            // Weather & Smart Recommendations
            ListTile(
              leading: const Icon(Icons.cloud_outlined, color: Color(0xFF06B6D4)),
              title: Text(_t('Weather & Agronomic AI', 'الأرصاد والتوصيات الزراعية')),
              subtitle: Text(_t('5-day forecasts & rain index', 'توقعات 5 أيام ومؤشرات المطر')),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pushNamed(context, AppRoutes.weather),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            // Subscriptions & Billing
            ListTile(
              leading: const Icon(Icons.credit_card_rounded, color: Color(0xFFF59E0B)),
              title: Text(_t('Billing & Egyptian Payments', 'الفواتير وبوابات الدفع')),
              subtitle: Text(_t('Paymob, Fawry, InstaPay & Vodafone', 'بيموب، فوري، انستاباي، فودافون كاش')),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pushNamed(context, AppRoutes.subscriptions),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            // Solar Energy
            ListTile(
              leading: const Icon(Icons.solar_power_rounded, color: Colors.amber),
              title: Text(_t('Solar Energy Monitoring', 'مراقبة الطاقة الشمسية')),
              subtitle: Text(_t('Inverters, Battery SoC & Net Surplus', 'الإنفرتر والبطاريات وفائض الطاقة')),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pushNamed(context, AppRoutes.solar),
            ),
            // Role-based Navigation: Admin Dashboard ONLY for Super Admin, Support for Farmers
            if (canAccessAdmin) ...[
              Divider(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              ListTile(
                leading: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: primaryColor,
                ),
                title: Text(
                  _t('Admin Dashboard & Team', 'لوحة الإدارة وأعضاء الفريق'),
                ),
                subtitle: Text(
                  _t('Manage roles, team members & permissions', 'إدارة الأدوار والأعضاء والصلاحيات'),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pushNamed(context, AppRoutes.admin),
              ),
            ] else ...[
              Divider(
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              ListTile(
                leading: const Icon(Icons.support_agent_rounded, color: AppColors.primaryGreen),
                title: Text(_t('Customer Support & Agronomy Help', 'الدعم الفني والاستشارات الزراعية')),
                subtitle: Text(_t('24/7 agricultural hotline & inquiries', 'خط ساخن ودعم فني وهندسي 24/7')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showSupportDialog(context, isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context, bool isDark) {
    final messageCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.support_agent_rounded, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(_t('Customer Support', 'الدعم الفني والاستفسارات')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t(
                'Green Flow Agronomy & IoT Support Team is ready to assist your farm.',
                'فريق الدعم الفني والهندسي في Green Flow في خدمتك على مدار الساعة.',
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk_rounded, color: AppColors.primaryGreen, size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    '+20 111 000 9988 (Hotline)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: _t('Describe your issue or technical inquiry...', 'اكتب استفسارك أو مشكلتك الفنية...'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('Cancel', 'إلغاء')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _t(
                      'Support ticket submitted. A technical specialist will contact you shortly.',
                      'تم إرسال تذكرة الدعم بنجاح. سيتواصل معك أحد المهندسين قريباً.',
                    ),
                  ),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            child: Text(_t('Submit Ticket', 'إرسال التذكرة')),
          ),
        ],
      ),
    );
  }
}

class PositionCircleBadge extends StatelessWidget {
  const PositionCircleBadge({super.key, required this.primaryColor});
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.check, size: 12, color: Colors.white),
      ),
    );
  }
}
