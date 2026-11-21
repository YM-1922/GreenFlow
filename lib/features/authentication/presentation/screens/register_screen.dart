import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../widgets/auth_header.dart';

/// Public Farmer Registration Screen.
/// Strictly enforces role = Farm Owner (Farmer) and status = Pending Approval.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onCreateAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.sensorWarning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(AppStrings.mustAcceptTerms(context))),
            ],
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    // Registers as farmer with pending approval status
    final name = _nameController.text.trim();
    _authService.registerFarmer(
      nameEn: name,
      nameAr: name,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    // Direct user to waiting room
    Navigator.of(context).pushReplacementNamed(AppRoutes.approvalWaiting);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.isArabic(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthHeader(
                    title: isAr ? 'تسجيل مزارع جديد' : 'New Farmer Registration',
                    subtitle: isAr
                        ? 'انضم إلى شبكة المزارع الذكية للتحكم في الري والطاقة الشمسية'
                        : 'Join the smart agriculture network to automate irrigation and solar power',
                  ),
                  const SizedBox(height: 20),

                  // Info box clarifying approval workflow
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFF06B6D4), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isAr
                                ? 'سيتم تقديم طلبك لإدارة Green Flow للمراجعة والاعتماد قبل تفعيل حساب المزرعة.'
                                : 'Your application will be submitted for Green Flow Super Admin review before full dashboard activation.',
                            style: const TextStyle(fontSize: 11, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full name
                  CustomTextField(
                    label: AppStrings.fullName(context),
                    hint: isAr ? 'أحمد محمد علي' : 'Ahmed Mohamed Ali',
                    controller: _nameController,
                    prefixIcon: Icons.person_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return AppStrings.enterFullName(context);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Phone
                  CustomTextField(
                    label: AppStrings.phoneNumber(context),
                    hint: '+20 100 123 4567',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return AppStrings.enterPhoneNumber(context);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Email
                  CustomTextField(
                    label: AppStrings.emailAddress(context),
                    hint: 'farmer@domain.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return AppStrings.enterEmailAddress(context);
                      }
                      if (!val.contains('@') || !val.contains('.')) {
                        return AppStrings.enterValidEmail(context);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Password
                  CustomTextField(
                    label: AppStrings.password(context),
                    hint: AppStrings.passwordHint(context),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 20,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return AppStrings.enterPassword(context);
                      }
                      if (val.length < 6) {
                        return AppStrings.passwordTooShort(context);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Confirm Password
                  CustomTextField(
                    label: AppStrings.confirmPassword(context),
                    hint: AppStrings.confirmPasswordHint(context),
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 20,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return AppStrings.enterConfirmPassword(context);
                      }
                      if (val != _passwordController.text) {
                        return AppStrings.passwordsDoNotMatch(context);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Agree to terms checkbox
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          activeColor: AppColors.primaryGreen,
                          onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.agreeToTerms(context),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit
                  CustomButton(
                    label: isAr ? 'تقديم طلب التسجيل' : 'Submit Registration Application',
                    isLoading: _isLoading,
                    icon: Icons.app_registration_rounded,
                    onPressed: _onCreateAccount,
                  ),
                  const SizedBox(height: 16),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount(context),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                        child: Text(
                          AppStrings.loginNow(context),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
