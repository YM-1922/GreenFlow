import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/theme_service.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../farms/presentation/screens/farmer_installation_screen.dart';
import '../../../farms/presentation/screens/inspections_list_screen.dart';
import '../../../finance/presentation/screens/farmer_invoices_screen.dart';
import '../../../finance/presentation/screens/farmer_quotations_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../solar/presentation/screens/solar_screen.dart';
import '../../../subscriptions/presentation/screens/subscriptions_screen.dart';
import '../../../weather/presentation/screens/weather_screen.dart';

/// "More" Hub Screen for Farmers (Tab 5 in FarmerShell).
/// Provides structured access to all secondary modules while preserving
/// the persistent bottom navigation bar.
class FarmerMoreHubScreen extends StatelessWidget {
  const FarmerMoreHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.isArabic(context);
    final user = AuthService().currentUser;

    final modules = [
      _MoreModuleItem(
        titleEn: 'Weather & AI Agronomics',
        titleAr: 'الأرصاد والتوصيات الزراعية',
        subtitleEn: '5-day forecasts & rain index',
        subtitleAr: 'توقعات 5 أيام ومؤشرات المطر',
        icon: Icons.cloud_outlined,
        color: const Color(0xFF06B6D4),
        pageBuilder: () => const WeatherScreen(),
      ),
      _MoreModuleItem(
        titleEn: 'Solar Energy Monitoring',
        titleAr: 'مراقبة الطاقة الشمسية',
        subtitleEn: 'Inverters, Battery SoC & PV',
        subtitleAr: 'الإنفرتر والبطاريات وتوليد الطاقة',
        icon: Icons.solar_power_rounded,
        color: Colors.amber,
        pageBuilder: () => const SolarScreen(),
      ),
      _MoreModuleItem(
        titleEn: 'Water Analytics & Conservation',
        titleAr: 'تحليلات استهلاك المياه',
        subtitleEn: 'Consumption graphs & pump runtime',
        subtitleAr: 'رسوم بيانية لاستهلاك الري والضخ',
        icon: Icons.insights_rounded,
        color: const Color(0xFF8B5CF6),
        pageBuilder: () => const AnalyticsScreen(),
      ),
      _MoreModuleItem(
        titleEn: 'Inspection Requests & Reports',
        titleAr: 'طلبات وتقارير المعاينة الفنية',
        subtitleEn: 'Site visits & engineer assessments',
        subtitleAr: 'زيارات المهندسين وفحص التربة',
        icon: Icons.assignment_outlined,
        color: AppColors.flowBlue,
        pageBuilder: () => const InspectionsListScreen(),
      ),
      _MoreModuleItem(
        titleEn: 'Commercial Quotations',
        titleAr: 'عروض الأسعار والمقايسات',
        subtitleEn: 'Review, accept or decline quotes',
        subtitleAr: 'مراجعة وقبول المقايسات المعتمدة',
        icon: Icons.request_quote_rounded,
        color: const Color(0xFF059669),
        pageBuilder: () => FarmerQuotationsScreen(farmerId: user?.id),
      ),
      _MoreModuleItem(
        titleEn: 'Installation Progress Tracker',
        titleAr: 'متابعة مراحل التركيب الميداني',
        subtitleEn: 'Hardware setup & node pairing',
        subtitleAr: 'جدول تركيب العتاد وربط الأجهزة',
        icon: Icons.handyman_rounded,
        color: Colors.teal,
        pageBuilder: () => const FarmerInstallationScreen(),
      ),
      _MoreModuleItem(
        titleEn: 'Subscriptions & Egyptian Plans',
        titleAr: 'الباقات والاشتراكات الشهرية',
        subtitleEn: 'Basic, Pro & Enterprise tiers',
        subtitleAr: 'باقات الدعم الفني والأتمتة',
        icon: Icons.credit_card_rounded,
        color: const Color(0xFFF59E0B),
        pageBuilder: () => const SubscriptionsScreen(),
      ),
      _MoreModuleItem(
        titleEn: 'Invoices & Payment History',
        titleAr: 'سجل الفواتير والمدفوعات',
        subtitleEn: 'Paymob, Fawry, InstaPay & Vodafone',
        subtitleAr: 'سداد فوري، انستاباي، بيموب ومحافظ',
        icon: Icons.receipt_long_rounded,
        color: AppColors.primaryGreen,
        pageBuilder: () => FarmerInvoicesScreen(farmerId: user?.id),
      ),
      _MoreModuleItem(
        titleEn: 'Notifications Center',
        titleAr: 'مركز الإشعارات والتنبيهات',
        subtitleEn: 'System, weather & irrigation alerts',
        subtitleAr: 'تنبيهات الري والمحابس والطقس',
        icon: Icons.notifications_outlined,
        color: AppColors.sensorAlert,
        pageBuilder: () => const NotificationsScreen(),
      ),
      _MoreModuleItem(
        titleEn: 'Farmer Profile & Settings',
        titleAr: 'الملف الشخصي وإعدادات التطبيق',
        subtitleEn: 'Themes, language & farm details',
        subtitleAr: 'المظهر واللغة وبيانات المزرعة',
        icon: Icons.person_outline_rounded,
        color: Colors.indigo,
        pageBuilder: () => const ProfileScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'المزيد من الخدمات والعمليات' : 'Services & Management Hub',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: Icon(ThemeService().isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: isAr ? 'تبديل المظهر' : 'Toggle Theme',
            onPressed: () => ThemeService().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: isAr ? 'تسجيل الخروج' : 'Logout',
            onPressed: () {
              AuthService().logout();
              Navigator.of(context, rootNavigator: true).pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final m = modules[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: isDark ? AppColors.cardDark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: m.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(m.icon, color: m.color, size: 22),
                ),
                title: Text(
                  isAr ? m.titleAr : m.titleEn,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  isAr ? m.subtitleAr : m.subtitleEn,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () {
                  // Push on the current tab's Navigator so bottom navigation remains visible!
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => m.pageBuilder()),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MoreModuleItem {
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final IconData icon;
  final Color color;
  final Widget Function() pageBuilder;

  _MoreModuleItem({
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.icon,
    required this.color,
    required this.pageBuilder,
  });
}
