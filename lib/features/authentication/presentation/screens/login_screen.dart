import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../widgets/auth_header.dart';

/// Role-aware Login Screen with credentials validation, account status checks, and route dispatching.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Smooth local handshake

    if (!mounted) return;
    final result = _authService.login(
      _identifierController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    final isAr = AppStrings.isArabic(context);

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.sensorAlert,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(isAr ? (result.errorMessageAr ?? '') : (result.errorMessageEn ?? '')),
        ),
      );
      return;
    }

    // Account is pending approval: route to waiting room
    if (result.isPendingApproval) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.approvalWaiting);
      return;
    }

    final user = result.user!;
    // Route dynamically based on user role (Super Admin vs Farmer)
    final destinationRoute = user.role == UserRole.superAdmin ? AppRoutes.admin : AppRoutes.home;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isAr
                    ? 'مرحباً بك ${user.nameAr} (${user.role.labelAr})'
                    : 'Welcome, ${user.nameEn} (${user.role.labelEn})',
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.of(context).pushReplacementNamed(destinationRoute);
  }

  void _selectQuickRole(UserRole role) {
    String username;
    String password;

    switch (role) {
      case UserRole.superAdmin:
        username = 'admin';
        password = 'SuperAdmin@2026';
        break;
      case UserRole.farmOwner:
        username = 'farmer_ahmed';
        password = 'Farmer@2026';
        break;
      case UserRole.technician:
        username = 'technician_omar';
        password = 'Tech@2026';
        break;
      case UserRole.farmWorker:
        username = 'worker_fathy';
        password = 'Worker@2026';
        break;
      case UserRole.financeManager:
        username = 'finance_layla';
        password = 'Finance@2026';
        break;
    }

    setState(() {
      _identifierController.text = username;
      _passwordController.text = password;
    });
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
                    title: AppStrings.loginTitle(context),
                    subtitle: isAr
                        ? 'نظام إدارة الزراعة الذكية والطاقة الموزعة'
                        : 'Smart Agriculture & Distributed Solar IoT Management',
                  ),
                  const SizedBox(height: 24),

                  // Username / Email input
                  CustomTextField(
                    label: isAr ? 'اسم المستخدم أو البريد' : 'Username or Email',
                    hint: isAr ? 'أدخل اسم المستخدم' : 'Enter username or email',
                    controller: _identifierController,
                    prefixIcon: Icons.account_circle_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return isAr ? 'يرجى إدخال اسم المستخدم أو البريد' : 'Enter username or email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password input
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
                  const SizedBox(height: 12),

                  // Remember me
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.primaryGreen,
                            onChanged: (val) => setState(() => _rememberMe = val ?? true),
                          ),
                          Text(
                            AppStrings.rememberMe(context),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit Login
                  CustomButton(
                    label: AppStrings.loginButton(context),
                    isLoading: _isLoading,
                    icon: Icons.login_rounded,
                    onPressed: _onLogin,
                  ),
                  const SizedBox(height: 20),

                  // Development Demo Accounts Selector
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primaryGreen),
                            const SizedBox(width: 6),
                            Text(
                              isAr ? 'حسابات التجربة والاختبار (Demo Roles):' : 'Demo Test Accounts (Click to Fill):',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _RoleChip(
                              label: isAr ? 'مدير عام (Super Admin)' : 'Super Admin',
                              onTap: () => _selectQuickRole(UserRole.superAdmin),
                              color: const Color(0xFF166534),
                            ),
                            _RoleChip(
                              label: isAr ? 'مزارع (Farmer)' : 'Farmer',
                              onTap: () => _selectQuickRole(UserRole.farmOwner),
                              color: AppColors.primaryGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Public Registration Link (Farmers only)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount(context),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.register),
                        child: Text(
                          AppStrings.registerNow(context),
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

class _RoleChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _RoleChip({required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}
