import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../farms/data/datasources/farms_mock_data_source.dart';
import '../../../farms/domain/entities/farm_entities.dart';
import '../../../finance/data/datasources/finance_mock_data_source.dart';
import '../../../finance/domain/entities/finance_entities.dart';

/// Comprehensive Super Admin Operations Center.
/// Full enterprise control over Executive Metrics, Action Required Items,
/// Farmer Approvals, Team Accounts, Technical Assessments, Quotations, and Global IoT Monitoring.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final FarmsMockDataSource _farmsDataSource = FarmsMockDataSource();
  final FinanceMockDataSource _financeDataSource = FinanceMockDataSource();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _authService.addListener(_onDataChanged);
    _financeDataSource.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onDataChanged);
    _financeDataSource.removeListener(_onDataChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _openCreateAccountDialog() {
    final isAr = AppStrings.isArabic(context);
    final usernameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    var selectedRole = UserRole.technician;
    final tempPassword = 'GF@${DateTime.now().millisecond}Temp';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isAr ? 'إنشاء حساب جديد بواسطة الإدارة' : 'Create Internal User Account'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(labelText: isAr ? 'اسم المستخدم' : 'Username'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: isAr ? 'الاسم الكامل' : 'Full Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(labelText: isAr ? 'البريد الإلكتروني' : 'Email Address'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(labelText: isAr ? 'رقم الهاتف' : 'Phone Number'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<UserRole>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(labelText: isAr ? 'الدور الوظيفي' : 'Role Assignment'),
                    items: [
                      UserRole.technician,
                      UserRole.farmWorker,
                      UserRole.financeManager,
                      UserRole.farmOwner,
                    ].map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(isAr ? r.labelAr : r.labelEn),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.key_rounded, size: 16, color: AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isAr ? 'كلمة المرور المؤقتة: $tempPassword' : 'Temp Password: $tempPassword',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                child: Text(isAr ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (usernameCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) return;

                  _authService.createAccountByAdmin(
                    username: usernameCtrl.text.trim(),
                    nameEn: nameCtrl.text.trim(),
                    nameAr: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    role: selectedRole,
                    initialPassword: tempPassword,
                  );

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAr
                            ? 'تم إنشاء الحساب بنجاح. كلمة المرور المؤقتة: $tempPassword'
                            : 'Account created. Temp password: $tempPassword',
                      ),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                child: Text(isAr ? 'إنشاء الحساب' : 'Create Account'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.isArabic(context);

    final allAccounts = _authService.allAccounts;
    final farmers = allAccounts.where((a) => a.role == UserRole.farmOwner).toList();
    final pendingFarmers = farmers.where((a) => a.isPending).toList();
    final activeFarms = _farmsDataSource.getFarms();
    final quotations = _financeDataSource.quotations;
    final inspections = _farmsDataSource.getInspectionRequests();

    final overdueInspections = inspections.where((i) => i.status == InspectionStatus.pending).length;
    final pendingQuotations = quotations.where((q) => q.status == QuotationStatus.pendingApproval || q.status == QuotationStatus.sentToFarmer).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'لوحة إدارة النظام العامة' : 'Super Admin Management Console',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: isAr ? 'إنشاء حساب جديد' : 'Create Account',
            onPressed: _openCreateAccountDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: isAr ? 'خروج' : 'Logout',
            onPressed: () {
              _authService.logout();
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          labelColor: AppColors.primaryGreen,
          isScrollable: true,
          tabs: [
            Tab(text: isAr ? 'المؤشرات والعمليات' : 'KPIs & Overview'),
            Tab(
              text: isAr
                  ? 'طلبات المزارعين المعلقة (${pendingFarmers.length})'
                  : 'Pending Farmers (${pendingFarmers.length})',
            ),
            Tab(text: isAr ? 'دليل المستخدمين والصلاحيات' : 'User Directory'),
            Tab(text: isAr ? 'العمليات والتركيبات' : 'Field Operations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Executive Overview & Action Required
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Executive KPI Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.8,
                children: [
                  _AdminStatTile(
                    label: isAr ? 'إجمالي الحسابات' : 'Total Accounts',
                    value: '${allAccounts.length}',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.primaryGreen,
                  ),
                  _AdminStatTile(
                    label: isAr ? 'طلبات بانتظار الاعتماد' : 'Pending Registrations',
                    value: '${pendingFarmers.length}',
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.sensorWarning,
                  ),
                  _AdminStatTile(
                    label: isAr ? 'المزارع النشطة' : 'Active Farms',
                    value: '${activeFarms.length}',
                    icon: Icons.landscape_rounded,
                    color: const Color(0xFF059669),
                  ),
                  _AdminStatTile(
                    label: isAr ? 'عروض الأسعار' : 'Quotations',
                    value: '${quotations.length}',
                    icon: Icons.request_quote_rounded,
                    color: const Color(0xFF06B6D4),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Required Section
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAr ? 'إجراءات عاجلة تتطلب تدخلاً (Action Required)' : 'Action Required Queue',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildActionCard(
                titleEn: 'Pending Farmer Registrations (${pendingFarmers.length})',
                titleAr: 'طلبات تسجيل مزارعين معلقة (${pendingFarmers.length})',
                subtitleEn: 'New farmer applications waiting for ID verification and farm assignment.',
                subtitleAr: 'مزارعون جدد بانتظار التحقق من المستندات وتخصيص المزرعة.',
                priority: 'High / عاجل',
                priorityColor: Colors.redAccent,
                actionLabel: isAr ? 'مراجعة واعتماد' : 'Review Applications',
                onAction: () => _tabController.animateTo(1),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildActionCard(
                titleEn: 'Overdue Engineering Inspections ($overdueInspections)',
                titleAr: 'معاينات هندسية بانتظار جدولة الفني ($overdueInspections)',
                subtitleEn: 'Survey visits requested by farmers needing technician dispatch.',
                subtitleAr: 'طلبات فحص تربة ومصادر مياه بحاجة لإسناد مهندس ميداني.',
                priority: 'Medium / متوسط',
                priorityColor: Colors.orange,
                actionLabel: isAr ? 'لوحة الفنيين' : 'Open Field Dispatch',
                onAction: () => Navigator.pushNamed(context, AppRoutes.technicianDashboard),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildActionCard(
                titleEn: 'Pending Commercial Quotations ($pendingQuotations)',
                titleAr: 'مقايسات فنية بانتظار موافقة الإدارة والعميل ($pendingQuotations)',
                subtitleEn: 'Cost calculations and 14% VAT invoices ready for commercial audit.',
                subtitleAr: 'مقايسات عتاد وحسابات ضريبية بحاجة للتدقيق المالي.',
                priority: 'Normal / اعتيادي',
                priorityColor: AppColors.primaryGreen,
                actionLabel: isAr ? 'لوحة المالية' : 'Open Finance Ledger',
                onAction: () => Navigator.pushNamed(context, AppRoutes.financeDashboard),
                isDark: isDark,
              ),

              const SizedBox(height: 24),
              Text(
                isAr ? 'روابط الوصول السريع للإدارات' : 'System Operational Modules',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ListTile(
                tileColor: isDark ? AppColors.cardDark : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.account_balance_rounded, color: Color(0xFF8B5CF6)),
                title: Text(isAr ? 'الإدارة المالية والتسعير والمقايسات' : 'Finance, Pricing & Invoices'),
                subtitle: Text(isAr ? 'إدارة كتالوج المنتجات والفواتير' : 'Manage catalog, margins & invoices'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => Navigator.pushNamed(context, AppRoutes.financeDashboard),
              ),
              const SizedBox(height: 8),

              ListTile(
                tileColor: isDark ? AppColors.cardDark : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.engineering_rounded, color: Color(0xFF06B6D4)),
                title: Text(isAr ? 'لوحة الفنيين والتركيبات الميدانية' : 'Field Technician Operations'),
                subtitle: Text(isAr ? 'متابعة المعاينات وتقارير الفحص' : 'Surveys, assessments & checklists'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => Navigator.pushNamed(context, AppRoutes.technicianDashboard),
              ),
            ],
          ),

          // Tab 2: Farmer Approvals
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendingFarmers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.primaryGreen),
                        const SizedBox(height: 12),
                        Text(
                          isAr ? 'لا توجد طلبات مزارعين معلقة حالياً' : 'No pending farmer registrations.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...pendingFarmers.map((f) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isDark ? AppColors.cardDark : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.sensorWarning.withValues(alpha: 0.4)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isAr ? f.nameAr : f.nameEn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.sensorWarning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isAr ? 'طلب جديد' : 'New Request',
                                  style: const TextStyle(color: AppColors.sensorWarning, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${f.email} • ${f.phone}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                                  onPressed: () {
                                    _authService.rejectFarmerRegistration(f.id, 'Incomplete verification documents');
                                  },
                                  child: Text(isAr ? 'رفض الطلب' : 'Reject'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                                  onPressed: () {
                                    _authService.approveFarmerRegistration(f.id, assignFarmId: 'farm-001');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isAr ? 'تم اعتماد المزارع وتفعيل لوحة التحكم' : 'Farmer approved and activated.'),
                                        backgroundColor: AppColors.primaryGreen,
                                      ),
                                    );
                                  },
                                  child: Text(isAr ? 'قبول واعتماد' : 'Approve'),
                                ),
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

          // Tab 3: All User Directory & Status Toggles
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...allAccounts.map((acc) {
                final isSuper = acc.role == UserRole.superAdmin;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: isDark ? AppColors.cardDark : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                      child: Text(
                        acc.nameEn.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                    ),
                    title: Text(isAr ? acc.nameAr : acc.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${acc.email} • ${isAr ? acc.role.labelAr : acc.role.labelEn}'),
                    trailing: isSuper
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Super Admin', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        : Switch.adaptive(
                            value: acc.status == AccountStatus.approved,
                            activeTrackColor: AppColors.primaryGreen,
                            onChanged: (val) {
                              _authService.setAccountStatus(
                                acc.id,
                                val ? AccountStatus.approved : AccountStatus.suspended,
                              );
                            },
                          ),
                  ),
                );
              }),
            ],
          ),

          // Tab 4: Field Operations & Installations
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                isAr ? 'إدارة المعاينات والتركيبات الميدانية' : 'Field Installations & Site Surveys',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...activeFarms.map((farm) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: isDark ? AppColors.cardDark : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE0F2FE),
                      child: Icon(Icons.handyman_rounded, color: Color(0xFF0284C7)),
                    ),
                    title: Text(farm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${farm.location} • ${farm.area} ${farm.areaUnit.labelEn()}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAr ? farm.installationStatus.labelAr() : farm.installationStatus.labelEn(),
                        style: const TextStyle(color: AppColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String titleEn,
    required String titleAr,
    required String subtitleEn,
    required String subtitleAr,
    required String priority,
    required Color priorityColor,
    required String actionLabel,
    required VoidCallback onAction,
    required bool isDark,
  }) {
    final isAr = AppStrings.isArabic(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isAr ? titleAr : titleEn,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  priority,
                  style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(isAr ? subtitleAr : subtitleEn, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
              onPressed: onAction,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminStatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
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
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
