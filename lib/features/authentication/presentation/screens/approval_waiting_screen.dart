import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';

/// Screen displayed to newly registered farmers whose account is awaiting Super Admin verification.
class ApprovalWaitingScreen extends StatelessWidget {
  const ApprovalWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.isArabic(context);
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Hourglass / Shield Animated Badge
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.sensorWarning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.sensorWarning.withValues(alpha: 0.4), width: 2),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 48,
                  color: AppColors.sensorWarning,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                isAr ? 'طلب التسجيل قيد المراجعة' : 'Account Pending Approval',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                isAr
                    ? 'شكراً لتسجيلك في Green Flow يا ${user?.nameAr ?? "عزيزنا المزارع"}.\nطلبك الآن قيد التدقيق لدى الإدارة العامة للتحقق من هوية المزرعة.'
                    : 'Thank you for registering with Green Flow, ${user?.nameEn ?? "Dear Farmer"}.\nYour application is currently being reviewed by the Super Admin team.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Demo Testing Shortcut: Allow instant admin approval in development mode
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.developer_mode_rounded, size: 16, color: AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          isAr ? 'تجربة المحاكاة السريعة (Demo Mode)' : 'Demo Testing Simulation',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isAr
                          ? 'يمكنك محاكاة موافقة الإدارة فوراً للدخول إلى لوحة تحكم المزارع:'
                          : 'You can simulate immediate Super Admin approval to enter the Farmer Dashboard:',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: Text(isAr ? 'محاكاة اعتماد الحساب ودخول المزرعة' : 'Simulate Approval & Enter Dashboard'),
                      onPressed: () {
                        if (user != null) {
                          AuthService().approveFarmerRegistration(user.id);
                        }
                        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Logout / Back to Login
              CustomButton(
                label: isAr ? 'العودة لشاشة تسجيل الدخول' : 'Back to Login',
                isOutlined: true,
                onPressed: () {
                  AuthService().logout();
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
