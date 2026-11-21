import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../farms/data/datasources/farms_mock_data_source.dart';
import '../../../farms/domain/entities/farm_entities.dart';

/// Dedicated Dashboard for Field Technicians.
/// Manages assigned farms, technical inspection visits, equipment checklists, and installation progress.
class TechnicianDashboardScreen extends StatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  State<TechnicianDashboardScreen> createState() => _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  final FarmsMockDataSource _farmsDataSource = FarmsMockDataSource();
  final AuthService _authService = AuthService();

  late List<FarmInspectionRequestEntity> _assignedInspections;
  late List<FarmEntity> _assignedFarms;

  @override
  void initState() {
    super.initState();
    _loadTechnicianData();
  }

  void _loadTechnicianData() {
    final user = _authService.currentUser;
    final allFarms = _farmsDataSource.getFarms();
    final allInspections = _farmsDataSource.getInspectionRequests();

    // Data ownership & assignment filter
    if (user != null && user.role == UserRole.technician) {
      _assignedFarms = allFarms.where((f) => user.assignedFarmIds.contains(f.id)).toList();
      _assignedInspections = allInspections; // Technicians handle all engineering surveys
    } else {
      _assignedFarms = allFarms;
      _assignedInspections = allInspections;
    }
  }

  void _submitTechnicalAssessment(FarmInspectionRequestEntity req) {
    final isAr = AppStrings.isArabic(context);
    final notesController = TextEditingController(text: 'تم فحص مصدر البئر وضغط المياه والتربة ملائمة للري بالتنقيط.');
    final requiredSensorsController = TextEditingController(text: '6');
    final requiredValvesController = TextEditingController(text: '3');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF06B6D4)),
            const SizedBox(width: 8),
            Text(isAr ? 'تقديم التقرير الهندسي والمواصفات' : 'Submit Technical Assessment'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isAr ? "المزرعة:" : "Farm:"} ${req.farmName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: isAr ? 'الملاحظات الفنية للتربة والمصادر' : 'Engineering Field Notes',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: requiredSensorsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAr ? 'عدد حساسات التربة المقترحة' : 'Recommended Soil Sensors',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: requiredValvesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAr ? 'عدد المحابس الكهرومغناطيسية' : 'Recommended Solenoid Valves',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06B6D4), foregroundColor: Colors.white),
            onPressed: () {
              // Update inspection status to completed with engineer notes
              final updated = req.copyWith(
                status: InspectionStatus.inspectionCompleted,
                engineerNotes: notesController.text.trim(),
              );
              _farmsDataSource.updateInspectionRequest(updated);
              Navigator.pop(ctx);
              setState(() => _loadTechnicianData());

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isAr
                        ? 'تم حفظ التقرير الهندسي وإرساله للإدارة والمالية لإعداد المقايسة'
                        : 'Assessment submitted. Forwarded to Finance to prepare commercial quotation.',
                  ),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            child: Text(isAr ? 'اعتماد التقرير' : 'Submit Assessment'),
          ),
        ],
      ),
    );
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
              isAr ? 'لوحة الفني والتركيبات الميدانية' : 'Field Technician Dashboard',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.nameEn ?? 'Technician Operator',
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
            // KPI Summary Row
            Row(
              children: [
                _TechKpiCard(
                  title: isAr ? 'معاينات هندسية' : 'Inspections',
                  value: '${_assignedInspections.length}',
                  icon: Icons.checklist_rtl_rounded,
                  color: const Color(0xFF06B6D4),
                ),
                const SizedBox(width: 12),
                _TechKpiCard(
                  title: isAr ? 'مزارع مخصصة' : 'Assigned Farms',
                  value: '${_assignedFarms.length}',
                  icon: Icons.landscape_rounded,
                  color: AppColors.primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Inspections & Assessments Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'مهام المعاينات الميدانية والفحص' : 'Field Inspection Tasks',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_assignedInspections.length} ${isAr ? "مهمة" : "Tasks"}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._assignedInspections.map((req) {
              final isCompleted = req.status == InspectionStatus.inspectionCompleted;
              return Card(
                elevation: 0,
                color: isDark ? AppColors.cardDark : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              req.farmName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppColors.primaryGreen.withValues(alpha: 0.15)
                                  : const Color(0xFF06B6D4).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCompleted ? (isAr ? 'تم الفحص' : 'Assessed') : (isAr ? 'قيد المعاينة' : 'Pending Survey'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? AppColors.primaryGreen : const Color(0xFF06B6D4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isAr ? "العميل:" : "Client:"} ${req.customerName} • ${req.phoneNumber}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        '${isAr ? "الموقع:" : "Location:"} ${req.location} • ${req.area} ${req.areaUnit.labelAr()}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.assignment_rounded, size: 16),
                              label: Text(isAr ? 'إجراء التقرير الهندسي' : 'Submit Assessment'),
                              onPressed: () => _submitTechnicalAssessment(req),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                            icon: const Icon(Icons.sensors_rounded, size: 16),
                            label: Text(isAr ? 'تهيئة الحساسات' : 'Config Nodes'),
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.deviceSetup),
                          ),
                        ],
                      ),
                    ],
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

class _TechKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _TechKpiCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
