import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../farms/data/datasources/farms_mock_data_source.dart';
import '../../../farms/domain/entities/farm_entities.dart';

/// Dedicated Dashboard for Agricultural Farm Workers.
/// Restricted strictly to the assigned farm, daily task completion, and manual zone irrigation control.
class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  final FarmsMockDataSource _farmsDataSource = FarmsMockDataSource();
  final AuthService _authService = AuthService();

  FarmEntity? _assignedFarm;
  final List<String> _completedTasks = [];

  final List<String> _dailyTasks = [
    'فحص رطوبة قطاع الزيتون الشرقي عند الصباح',
    'تشغيل دورة ري نخيل البرحي لمدة 45 دقيقة',
    'معاينة صمامات تصريف الفلاتر والتأكد من الضغط',
    'تنظيف مصفاة مدخل مضخة البئر الرئيسي',
  ];

  @override
  void initState() {
    super.initState();
    _loadWorkerFarm();
  }

  void _loadWorkerFarm() {
    final user = _authService.currentUser;
    final farmId = user?.assignedFarmId ?? 'farm-001';
    _assignedFarm = _farmsDataSource.getFarmById(farmId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.isArabic(context);
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'لوحة العامل والتشغيل الحقلي' : 'Agricultural Worker Dashboard',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${user?.nameEn ?? "Worker"} • ${_assignedFarm?.name ?? "Assigned Farm"}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: isAr ? 'خروج' : 'Logout',
            onPressed: () {
              _authService.logout();
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assigned Farm Hero Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFFECFDF5), Colors.white],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _assignedFarm?.name ?? (isAr ? 'المزرعة المعينة' : 'Assigned Farm'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_assignedFarm?.location ?? (isAr ? "وادي النطرون" : "Wadi El Natrun")} • ${_assignedFarm?.area ?? 45} ${_assignedFarm != null ? _assignedFarm!.areaUnit.labelAr() : (isAr ? "فدان" : "Feddan")}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Irrigation Actuator Shortcut
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.water_drop_rounded),
              label: Text(isAr ? 'لوحة التحكم في المحابس ومضخة المزرعة' : 'Open Assigned Farm Irrigation Controls'),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.irrigation),
            ),
            const SizedBox(height: 24),

            // Daily Operational Checklist
            Text(
              isAr ? 'جدول المهام اليومية للمزرعة' : 'Daily Farm Operations Checklist',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ..._dailyTasks.map((task) {
              final isDone = _completedTasks.contains(task);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: CheckboxListTile(
                    value: isDone,
                    activeColor: AppColors.primaryGreen,
                    title: Text(
                      task,
                      style: TextStyle(
                        fontSize: 13,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? Colors.grey : null,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _completedTasks.add(task);
                        } else {
                          _completedTasks.remove(task);
                        }
                      });
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
