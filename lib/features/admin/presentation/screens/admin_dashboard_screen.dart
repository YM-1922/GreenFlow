import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../farms/data/datasources/farms_mock_data_source.dart';
import '../../../farms/domain/entities/farm_entities.dart';
import '../../../finance/data/datasources/finance_mock_data_source.dart';
import '../../../finance/domain/entities/finance_entities.dart';

/// Comprehensive Enterprise Super Admin Operations Center & Dashboard.
/// Redesigned with executive KPIs, actionable triage queue, visual analytics,
/// real-time system activities, farmer onboarding verification, and complete user RBAC management.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final FarmsMockDataSource _farmsDataSource = FarmsMockDataSource();
  final FinanceMockDataSource _financeDataSource = FinanceMockDataSource();

  // Search & Filters state
  String _userSearchQuery = '';
  UserRole? _userRoleFilter;
  String _farmerSearchQuery = '';

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_add_rounded, color: AppColors.primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAr ? 'إنشاء حساب جديد بواسطة الإدارة' : 'Create Internal User Account',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                      labelText: isAr ? 'اسم المستخدم' : 'Username',
                      prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: isAr ? 'الاسم الكامل' : 'Full Name',
                      prefixIcon: const Icon(Icons.badge_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: isAr ? 'البريد الإلكتروني' : 'Email Address',
                      prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: isAr ? 'رقم الهاتف' : 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<UserRole>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: isAr ? 'الدور الوظيفي' : 'Role Assignment',
                      prefixIcon: const Icon(Icons.security_rounded, size: 20),
                    ),
                    items: [
                      UserRole.technician,
                      UserRole.farmWorker,
                      UserRole.financeManager,
                      UserRole.farmOwner,
                    ].map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(isAr ? r.labelAr : r.labelEn, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.key_rounded, size: 18, color: AppColors.primaryGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? 'كلمة المرور المؤقتة للنظام' : 'Temporary System Password',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              Text(
                                tempPassword,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                              ),
                            ],
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
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check_rounded, size: 18),
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
                label: Text(isAr ? 'إنشاء الحساب' : 'Create Account'),
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

    // Live Data Extraction
    final allAccounts = _authService.allAccounts;
    final farmers = allAccounts.where((a) => a.role == UserRole.farmOwner).toList();
    final technicians = allAccounts.where((a) => a.role == UserRole.technician).toList();
    final workers = allAccounts.where((a) => a.role == UserRole.farmWorker).toList();
    final pendingFarmers = farmers.where((a) => a.isPending).toList();
    final approvedFarmers = farmers.where((a) => a.status == AccountStatus.approved).toList();

    final activeFarms = _farmsDataSource.getFarms();
    final quotations = _financeDataSource.quotations;
    final inspections = _farmsDataSource.getInspectionRequests();

    // Metric Calculations
    final pendingInspections = inspections.where((i) => i.status == InspectionStatus.pending).toList();
    final scheduledInspections = inspections.where((i) => i.status == InspectionStatus.scheduled).toList();
    final inReviewInspections = inspections.where((i) => i.status == InspectionStatus.underReview || i.status == InspectionStatus.quotationPending).toList();
    final completedInspections = inspections.where((i) => i.status == InspectionStatus.approved || i.status == InspectionStatus.inspectionCompleted).toList();

    final pendingQuotations = quotations.where((q) => q.status == QuotationStatus.pendingApproval || q.status == QuotationStatus.sentToFarmer).toList();
    final acceptedQuotations = quotations.where((q) => q.status == QuotationStatus.accepted).toList();

    // Aggregated Request Pipeline Numbers
    final newRequestsCount = pendingFarmers.length + pendingInspections.length;
    final inProgressRequestsCount = scheduledInspections.length + inReviewInspections.length;
    final pendingRequestsCount = pendingFarmers.length + pendingInspections.length + pendingQuotations.length;
    final completedRequestsCount = completedInspections.length + acceptedQuotations.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'لوحة إدارة النظام العامة' : 'Super Admin Management Console',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: isAr ? 'التحليلات الزراعية' : 'Analytics',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.analytics),
          ),
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
          indicatorWeight: 3,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          isScrollable: true,
          tabs: [
            Tab(
              icon: const Icon(Icons.dashboard_rounded, size: 20),
              text: isAr ? 'المؤشرات والعمليات' : 'KPIs & Overview',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: pendingFarmers.isNotEmpty,
                label: Text('${pendingFarmers.length}'),
                backgroundColor: AppColors.sensorWarning,
                child: const Icon(Icons.hourglass_top_rounded, size: 20),
              ),
              text: isAr
                  ? 'طلبات المزارعين المعلقة (${pendingFarmers.length})'
                  : 'Pending Farmers (${pendingFarmers.length})',
            ),
            Tab(
              icon: const Icon(Icons.supervised_user_circle_rounded, size: 20),
              text: isAr ? 'دليل المستخدمين والصلاحيات' : 'User Directory',
            ),
            Tab(
              icon: const Icon(Icons.agriculture_rounded, size: 20),
              text: isAr ? 'العمليات والتركيبات' : 'Field Operations',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: EXECUTIVE OVERVIEW, KPIS, TRIAGE QUEUE, ANALYTICS & ACTIVITY
          _buildOverviewTab(
            isDark: isDark,
            isAr: isAr,
            allAccounts: allAccounts,
            farmers: farmers,
            technicians: technicians,
            workers: workers,
            pendingFarmers: pendingFarmers,
            activeFarms: activeFarms,
            newRequestsCount: newRequestsCount,
            inProgressRequestsCount: inProgressRequestsCount,
            pendingRequestsCount: pendingRequestsCount,
            completedRequestsCount: completedRequestsCount,
            pendingInspectionsCount: pendingInspections.length,
            pendingQuotationsCount: pendingQuotations.length,
            inspections: inspections,
            quotations: quotations,
          ),

          // TAB 2: PENDING FARMER ONBOARDING
          _buildPendingFarmersTab(
            isDark: isDark,
            isAr: isAr,
            pendingFarmers: pendingFarmers,
          ),

          // TAB 3: USER DIRECTORY & ROLE-BASED ACCESS CONTROL
          _buildUserDirectoryTab(
            isDark: isDark,
            isAr: isAr,
            allAccounts: allAccounts,
          ),

          // TAB 4: FIELD OPERATIONS & SITE INSTALLATIONS
          _buildFieldOperationsTab(
            isDark: isDark,
            isAr: isAr,
            activeFarms: activeFarms,
            approvedFarmers: approvedFarmers,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 1: OVERVIEW, STATS, TRIAGE, VISUAL ANALYTICS, RECENT ACTIVITIES
  // =========================================================================
  Widget _buildOverviewTab({
    required bool isDark,
    required bool isAr,
    required List<UserAccount> allAccounts,
    required List<UserAccount> farmers,
    required List<UserAccount> technicians,
    required List<UserAccount> workers,
    required List<UserAccount> pendingFarmers,
    required List<FarmEntity> activeFarms,
    required int newRequestsCount,
    required int inProgressRequestsCount,
    required int pendingRequestsCount,
    required int completedRequestsCount,
    required int pendingInspectionsCount,
    required int pendingQuotationsCount,
    required List<FarmInspectionRequestEntity> inspections,
    required List<CommercialQuotation> quotations,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 720;
        final gridColumns = isWideScreen ? 4 : 2;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // SECTION 1: EXECUTIVE STATISTICS CARDS (4 Focused Core Metrics)
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr ? 'نظرة عامة على مؤشرات النظام' : 'System Key Performance Indicators',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: gridColumns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isWideScreen ? 1.6 : 1.45,
              children: [
                _AdminStatCard(
                  label: isAr ? 'إجمالي الحسابات' : 'Total Accounts',
                  value: '${allAccounts.length}',
                  subText: isAr
                      ? '${allAccounts.where((a) => a.status == AccountStatus.approved).length} حساب نشط'
                      : '${allAccounts.where((a) => a.status == AccountStatus.approved).length} active',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.primaryGreen,
                  isDark: isDark,
                  onTap: () => _tabController.animateTo(2),
                ),
                _AdminStatCard(
                  label: isAr ? 'المزارع النشطة' : 'Active Farms',
                  value: '${activeFarms.length}',
                  subText: isAr
                      ? '${activeFarms.fold<double>(0, (sum, f) => sum + f.area).toStringAsFixed(0)} فدان تحت الإشراف'
                      : '${activeFarms.fold<double>(0, (sum, f) => sum + f.area).toStringAsFixed(0)} Feddans',
                  icon: Icons.landscape_rounded,
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                  onTap: () => _tabController.animateTo(3),
                ),
                _AdminStatCard(
                  label: isAr ? 'الطلبات المعلقة' : 'Pending Requests',
                  value: '$pendingRequestsCount',
                  subText: isAr ? 'تتطلب تدقيقاً وقراراً' : 'Action required',
                  icon: Icons.pending_actions_rounded,
                  color: Colors.redAccent,
                  isDark: isDark,
                ),
                _AdminStatCard(
                  label: isAr ? 'الطلبات المكتملة' : 'Completed Requests',
                  value: '$completedRequestsCount',
                  subText: isAr ? 'معتمدة ومثبتة' : 'Finalized & active',
                  icon: Icons.task_alt_rounded,
                  color: const Color(0xFF0D9488),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // SECTION 2: PENDING ACTIONS (ACTION REQUIRED QUEUE)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAr ? 'الإجراءات المطلوبة' : 'Action Required Queue',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAr ? '$pendingRequestsCount معلق' : '$pendingRequestsCount pending',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              titleEn: 'Pending Farmer Registrations (${pendingFarmers.length})',
              titleAr: 'طلبات تسجيل المزارعين الجديدة (${pendingFarmers.length})',
              subtitleEn: 'New farmer applications waiting for verification, document check, and farm assignment.',
              subtitleAr: 'مزارعون جدد بانتظار التحقق من المستندات، تخصيص المزرعة، واعتماد الحساب.',
              priority: isAr ? 'أولوية قصوى / عاجل' : 'High Priority',
              priorityColor: Colors.redAccent,
              badgeCount: pendingFarmers.length,
              actionLabel: isAr ? 'مراجعة واعتماد المزارعين' : 'Review & Approve',
              onAction: () => _tabController.animateTo(1),
              isDark: isDark,
              isAr: isAr,
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              titleEn: 'Inspections Awaiting Scheduling ($pendingInspectionsCount)',
              titleAr: 'المعاينات الحقلية التي تنتظر الجدولة ($pendingInspectionsCount)',
              subtitleEn: 'Field assessment visits submitted by farmers needing dispatching and technician assignment.',
              subtitleAr: 'طلبات فحص تربة ومصادر مياه بحاجة لجدولة موعد وإسناد مهندس ميداني.',
              priority: isAr ? 'أولوية متوسطة' : 'Medium Priority',
              priorityColor: Colors.orange,
              badgeCount: pendingInspectionsCount,
              actionLabel: isAr ? 'لوحة الفنيين والمعاينات' : 'Open Field Dispatch',
              onAction: () => Navigator.pushNamed(context, AppRoutes.technicianDashboard),
              isDark: isDark,
              isAr: isAr,
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              titleEn: 'Quotations Pending Customer & Admin Audit ($pendingQuotationsCount)',
              titleAr: 'عروض الأسعار والمقايسات المعلقة ($pendingQuotationsCount)',
              subtitleEn: 'Commercial proposals, hardware itemization, and VAT invoices awaiting financial clearance.',
              subtitleAr: 'مقايسات عتاد وحسابات ضريبية 14% جاهزة للمراجعة التجارية والاعتماد المالي.',
              priority: isAr ? 'إجراء مالي' : 'Commercial Review',
              priorityColor: const Color(0xFF0284C7),
              badgeCount: pendingQuotationsCount,
              actionLabel: isAr ? 'الإدارة المالية والمقايسات' : 'Open Finance Ledger',
              onAction: () => Navigator.pushNamed(context, AppRoutes.financeDashboard),
              isDark: isDark,
              isAr: isAr,
            ),
            const SizedBox(height: 28),

            // SECTION 3: VISUAL DASHBOARD ANALYTICS
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr ? 'الإحصائيات والتحليلات' : 'Operations & Activity Analytics',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _buildAnalyticsCard(
              isDark: isDark,
              isAr: isAr,
              allAccounts: allAccounts,
              farmers: farmers,
              technicians: technicians,
              workers: workers,
              activeFarms: activeFarms,
              completedCount: completedRequestsCount,
              inProgressCount: inProgressRequestsCount,
              pendingCount: pendingRequestsCount,
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // =========================================================================
  // SECTION 3 COMPONENT: VISUAL ANALYTICS CARD
  // =========================================================================
  Widget _buildAnalyticsCard({
    required bool isDark,
    required bool isAr,
    required List<UserAccount> allAccounts,
    required List<UserAccount> farmers,
    required List<UserAccount> technicians,
    required List<UserAccount> workers,
    required List<FarmEntity> activeFarms,
    required int completedCount,
    required int inProgressCount,
    required int pendingCount,
  }) {
    final totalRequests = completedCount + inProgressCount + pendingCount;
    final completedPercent = totalRequests > 0 ? (completedCount / totalRequests) : 0.0;
    final inProgressPercent = totalRequests > 0 ? (inProgressCount / totalRequests) : 0.0;
    final pendingPercent = totalRequests > 0 ? (pendingCount / totalRequests) : 0.0;

    final solarFarmsCount = activeFarms.where((f) => f.hasSolarPower).length;
    final solarAdoptionRate = activeFarms.isNotEmpty ? (solarFarmsCount / activeFarms.length) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header 1: Request Status Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'توزيع مسار الطلبات الحالية' : 'Request Fulfillment Distribution',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '$totalRequests ${isAr ? 'إجمالي الطلبات' : 'total items'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Multi-segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (completedPercent > 0)
                    Expanded(
                      flex: (completedPercent * 100).toInt(),
                      child: Container(color: AppColors.primaryGreen),
                    ),
                  if (inProgressPercent > 0)
                    Expanded(
                      flex: (inProgressPercent * 100).toInt(),
                      child: Container(color: const Color(0xFF6366F1)),
                    ),
                  if (pendingPercent > 0)
                    Expanded(
                      flex: (pendingPercent * 100).toInt(),
                      child: Container(color: Colors.redAccent),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Legend for Request Breakdown
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildLegendPill(
                color: AppColors.primaryGreen,
                label: isAr ? 'مكتمل ($completedCount)' : 'Completed ($completedCount)',
                percent: '${(completedPercent * 100).toStringAsFixed(0)}%',
              ),
              _buildLegendPill(
                color: const Color(0xFF6366F1),
                label: isAr ? 'قيد التنفيذ ($inProgressCount)' : 'In Progress ($inProgressCount)',
                percent: '${(inProgressPercent * 100).toStringAsFixed(0)}%',
              ),
              _buildLegendPill(
                color: Colors.redAccent,
                label: isAr ? 'معلق ($pendingCount)' : 'Pending ($pendingCount)',
                percent: '${(pendingPercent * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
          const Divider(height: 28),

          // Sub-header 2: User Role Distribution
          Text(
            isAr ? 'توزيع منظومة المستخدمين حسب الدور' : 'User Ecosystem Role Breakdown',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildRoleMiniCard(
                  label: isAr ? 'مزارعون' : 'Farmers',
                  count: farmers.length,
                  icon: Icons.person_pin_rounded,
                  color: AppColors.primaryGreen,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleMiniCard(
                  label: isAr ? 'فنيون' : 'Technicians',
                  count: technicians.length,
                  icon: Icons.engineering_rounded,
                  color: const Color(0xFF0284C7),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleMiniCard(
                  label: isAr ? 'عمال' : 'Workers',
                  count: workers.length,
                  icon: Icons.handyman_rounded,
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRoleMiniCard(
                  label: isAr ? 'إدارة' : 'Admins',
                  count: allAccounts.where((a) => a.role == UserRole.superAdmin || a.role == UserRole.financeManager).length,
                  icon: Icons.security_rounded,
                  color: const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const Divider(height: 28),

          // Sub-header 3: IoT & Agricultural Infrastructure Health
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'اعتماد الطاقة الشمسية بالمزارع' : 'Solar Adoption Rate',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(solarAdoptionRate * 100).toStringAsFixed(0)}% ($solarFarmsCount/${activeFarms.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFF59E0B)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'إجمالي المساحة المدارة' : 'Total Managed Acreage',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${activeFarms.fold<double>(0, (s, f) => s + f.area).toStringAsFixed(0)} ${isAr ? 'فدان' : 'Feddans'}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill({required Color color, required String label, required String percent}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Text('($percent)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRoleMiniCard({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 2: PENDING FARMER ONBOARDING
  // =========================================================================
  Widget _buildPendingFarmersTab({
    required bool isDark,
    required bool isAr,
    required List<UserAccount> pendingFarmers,
  }) {
    final filtered = pendingFarmers.where((f) {
      if (_farmerSearchQuery.isEmpty) return true;
      final q = _farmerSearchQuery.toLowerCase();
      return f.nameEn.toLowerCase().contains(q) ||
          f.nameAr.contains(q) ||
          f.email.toLowerCase().contains(q) ||
          f.phone.contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tab Header & Search
        Text(
          isAr ? 'طلبات تسجيل المزارعين المعلقة' : 'Pending Farmer Onboarding Applications',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          isAr
              ? 'مراجعة طلبات التسجيل الذاتي، التحقق من المزارعين الجدد وتخصيص المزارع لتفعيل لوحة التحكم.'
              : 'Review self-registration requests, verify farmer profiles and assign farms for activation.',
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 14),

        TextField(
          onChanged: (val) => setState(() => _farmerSearchQuery = val),
          decoration: InputDecoration(
            hintText: isAr ? 'بحث بالاسم، البريد أو الهاتف...' : 'Search applicant by name, email or phone...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.cardDark : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (filtered.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline_rounded, size: 54, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAr ? 'لا توجد طلبات مزارعين معلقة حالياً' : 'All farmer applications have been processed.',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr ? 'تم اعتماد جميع المزارعين وتفعيل حساباتهم بالكامل.' : 'All pending registrations are approved or resolved.',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ...filtered.map((f) {
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              color: isDark ? AppColors.cardDark : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: AppColors.sensorWarning.withValues(alpha: 0.4), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.sensorWarning.withValues(alpha: 0.15),
                          child: Text(
                            f.nameEn.isNotEmpty ? f.nameEn[0].toUpperCase() : 'F',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.sensorWarning, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? f.nameAr : f.nameEn,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${f.email} • ${f.phone}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: isAr ? 'بانتظار الاعتماد' : 'Pending',
                          color: AppColors.sensorWarning,
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _authService.rejectFarmerRegistration(f.id, 'Incomplete verification documents');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isAr ? 'تم رفض طلب التسجيل' : 'Registration request declined.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            },
                            label: Text(isAr ? 'رفض الطلب' : 'Reject'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            onPressed: () {
                              _authService.approveFarmerRegistration(f.id, assignFarmId: 'farm-001');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isAr ? 'تم اعتماد المزارع وتفعيل لوحة التحكم بنجاح' : 'Farmer approved and activated successfully.'),
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                              );
                            },
                            label: Text(isAr ? 'قبول واعتماد' : 'Approve & Activate'),
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
    );
  }

  // =========================================================================
  // TAB 3: USER DIRECTORY & ROLE-BASED ACCESS CONTROL
  // =========================================================================
  Widget _buildUserDirectoryTab({
    required bool isDark,
    required bool isAr,
    required List<UserAccount> allAccounts,
  }) {
    final filtered = allAccounts.where((acc) {
      if (_userRoleFilter != null && acc.role != _userRoleFilter) return false;
      if (_userSearchQuery.isEmpty) return true;
      final q = _userSearchQuery.toLowerCase();
      return acc.nameEn.toLowerCase().contains(q) ||
          acc.nameAr.contains(q) ||
          acc.email.toLowerCase().contains(q) ||
          acc.username.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tab Header & Search
        Text(
          isAr ? 'دليل المستخدمين والصلاحيات (RBAC)' : 'User Directory & Access Control',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          isAr
              ? 'إدارة صلاحيات الوصول، تفعيل وتعليق الحسابات، ومتابعة الأدوار الوظيفية في النظام.'
              : 'Manage permissions, enable or suspend accounts, and audit user roles across Green Flow.',
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 14),

        // Search bar
        TextField(
          onChanged: (val) => setState(() => _userSearchQuery = val),
          decoration: InputDecoration(
            hintText: isAr ? 'بحث بالاسم، اسم المستخدم أو البريد...' : 'Search by name, username or email...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.cardDark : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Role Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: Text(isAr ? 'الكل (${allAccounts.length})' : 'All (${allAccounts.length})'),
                selected: _userRoleFilter == null,
                onSelected: (_) => setState(() => _userRoleFilter = null),
                selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(isAr ? 'مزارعون' : 'Farmers'),
                selected: _userRoleFilter == UserRole.farmOwner,
                onSelected: (_) => setState(() => _userRoleFilter = UserRole.farmOwner),
                selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(isAr ? 'فنيون' : 'Technicians'),
                selected: _userRoleFilter == UserRole.technician,
                onSelected: (_) => setState(() => _userRoleFilter = UserRole.technician),
                selectedColor: const Color(0xFF0284C7).withValues(alpha: 0.2),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(isAr ? 'عمال' : 'Workers'),
                selected: _userRoleFilter == UserRole.farmWorker,
                onSelected: (_) => setState(() => _userRoleFilter = UserRole.farmWorker),
                selectedColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(isAr ? 'إدارة عليا' : 'Admins'),
                selected: _userRoleFilter == UserRole.superAdmin,
                onSelected: (_) => setState(() => _userRoleFilter = UserRole.superAdmin),
                selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ...filtered.map((acc) {
          final isSuper = acc.role == UserRole.superAdmin;
          final isActive = acc.status == AccountStatus.approved;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: isDark ? AppColors.cardDark : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: _getRoleColor(acc.role).withValues(alpha: 0.15),
                child: Text(
                  acc.nameEn.isNotEmpty ? acc.nameEn[0].toUpperCase() : 'U',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _getRoleColor(acc.role)),
                ),
              ),
              title: Text(
                isAr ? acc.nameAr : acc.nameEn,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${acc.email} • @${acc.username}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRoleColor(acc.role).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAr ? acc.role.labelAr : acc.role.labelEn,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getRoleColor(acc.role)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: isAr ? acc.status.labelAr : acc.status.labelEn,
                          color: isActive ? AppColors.sensorOnline : (acc.status == AccountStatus.pendingApproval ? AppColors.sensorWarning : Colors.redAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: isSuper
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Protected Admin', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  : Switch.adaptive(
                      value: isActive,
                      activeTrackColor: AppColors.primaryGreen,
                      onChanged: (val) {
                        _authService.setAccountStatus(
                          acc.id,
                          val ? AccountStatus.approved : AccountStatus.suspended,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val
                                ? (isAr ? 'تم تفعيل الحساب' : 'Account activated')
                                : (isAr ? 'تم تعليق الحساب' : 'Account suspended')),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
            ),
          );
        }),
      ],
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.redAccent;
      case UserRole.farmOwner:
        return AppColors.primaryGreen;
      case UserRole.technician:
        return const Color(0xFF0284C7);
      case UserRole.farmWorker:
        return const Color(0xFFF59E0B);
      case UserRole.financeManager:
        return const Color(0xFF8B5CF6);
    }
  }

  // =========================================================================
  // TAB 4: FIELD OPERATIONS & SITE INSTALLATIONS
  // =========================================================================
  Widget _buildFieldOperationsTab({
    required bool isDark,
    required bool isAr,
    required List<FarmEntity> activeFarms,
    required List<UserAccount> approvedFarmers,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          isAr ? 'المزارع والعمليات الميدانية والتركيبات' : 'Field Installations & Site Surveys',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          isAr
              ? 'متابعة المزارع النشطة، منظومة الطاقة الشمسية، وحالة ربط المحابس والحساسات الميدانية.'
              : 'Monitor connected farms, solar microgrid telemetry, and hardware installation progress.',
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 16),

        ...activeFarms.map((farm) {
          final isSolar = farm.hasSolarPower;
          final statusColor = farm.installationStatus.color();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isDark ? AppColors.cardDark : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE0F2FE),
                        child: const Icon(Icons.landscape_rounded, color: Color(0xFF0284C7), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(farm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('${farm.location} • ${farm.area} ${farm.areaUnit.labelEn()}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: isAr ? farm.installationStatus.labelAr() : farm.installationStatus.labelEn(),
                        color: statusColor,
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(farm.irrigationType.icon(), size: 14, color: AppColors.flowBlue),
                          const SizedBox(width: 4),
                          Text(
                            isAr ? farm.irrigationType.labelAr() : farm.irrigationType.labelEn(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      if (isSolar)
                        Row(
                          children: [
                            const Icon(Icons.solar_power_rounded, size: 14, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(isAr ? 'طاقة شمسية' : 'Solar Microgrid', style: const TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                        label: Text(isAr ? 'التفاصيل' : 'Details', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.farms),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================
  Widget _buildActionCard({
    required String titleEn,
    required String titleAr,
    required String subtitleEn,
    required String subtitleAr,
    required String priority,
    required Color priorityColor,
    required int badgeCount,
    required String actionLabel,
    required VoidCallback onAction,
    required bool isDark,
    required bool isAr,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: priorityColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
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
            alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: priorityColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
              label: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: onAction,
            ),
          ),
        ],
      ),
    );
  }
}

/// Statistics Tile with high visual hierarchy, clean elevation, and dynamic theme support.
class _AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subText;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  const _AdminStatCard({
    required this.label,
    required this.value,
    required this.subText,
    required this.icon,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.withValues(alpha: 0.6)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subText,
                style: const TextStyle(fontSize: 9, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }
    return card;
  }
}
