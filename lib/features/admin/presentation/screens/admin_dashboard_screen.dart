import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../finance/data/datasources/finance_mock_data_source.dart';

/// Complete Super Admin Operations Portal & Unified Management System.
/// Built strictly following Reference Image 2:
/// - Tab 0: الرئيسية (Home / Executive Overview & System Health)
/// - Tab 1: المزارع (Farms Management)
/// - Tab 2: المستخدمون (User Management)
/// - Tab 3: الأجهزة (IoT Hardware Nodes Management)
/// - Tab 4: المزيد (More Hub: Subscriptions, Analytics, Notifications, System Settings)
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentTabIndex = 0;
  final AuthService _authService = AuthService();
  final FinanceMockDataSource _financeDataSource = FinanceMockDataSource();

  // Filter states
  String _farmFilter = 'الكل';
  String _userFilter = 'الكل';
  String _deviceFilter = 'الكل';
  String _alertFilter = 'الكل';
  String _moreSubModule = 'subscriptions'; // subscriptions | analytics | alerts | settings
  final String _analyticsTimeframe = 'آخر 30 يوم';
  String _analyticsSubTab = 'عام';

  // Search queries
  String _farmSearch = '';
  String _userSearch = '';
  String _deviceSearch = '';

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onDataChanged);
    _financeDataSource.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onDataChanged);
    _financeDataSource.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.isArabic(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAF7),
      body: SafeArea(
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildHomeTab(isDark, isAr),
            _buildFarmsTab(isDark, isAr),
            _buildUsersTab(isDark, isAr),
            _buildDevicesTab(isDark, isAr),
            _buildMoreTab(isDark, isAr),
          ],
        ),
      ),
      bottomNavigationBar: _buildAdminBottomNav(isDark, isAr),
    );
  }

  // =========================================================================
  // ADMIN BOTTOM NAVIGATION BAR (Matches Reference Image 2)
  // =========================================================================
  Widget _buildAdminBottomNav(bool isDark, bool isAr) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F291E) : const Color(0xFF0B3B24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF4ADE80), // Bright light emerald
        unselectedItemColor: Colors.white.withValues(alpha: 0.65),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded, size: 22),
            activeIcon: const Icon(Icons.home_rounded, size: 24),
            label: isAr ? 'الرئيسية' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.landscape_rounded, size: 22),
            activeIcon: const Icon(Icons.landscape_rounded, size: 24),
            label: isAr ? 'المزارع' : 'Farms',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_alt_rounded, size: 22),
            activeIcon: const Icon(Icons.people_alt_rounded, size: 24),
            label: isAr ? 'المستخدمون' : 'Users',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.memory_rounded, size: 22),
            activeIcon: const Icon(Icons.memory_rounded, size: 24),
            label: isAr ? 'الأجهزة' : 'Devices',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz_rounded, size: 22),
            activeIcon: const Icon(Icons.more_horiz_rounded, size: 24),
            label: isAr ? 'المزيد' : 'More',
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 0: HOME / EXECUTIVE OVERVIEW & SYSTEM HEALTH (Reference Image 2, Panel 3)
  // =========================================================================
  Widget _buildHomeTab(bool isDark, bool isAr) {
    final user = _authService.currentUser;
    final pendingFarmers = _authService.allAccounts
        .where((a) => a.status == AccountStatus.pendingApproval)
        .toList();

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Header: Avatar, Greeting, Notification Bell
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryGreenDark,
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'مرحباً ${user?.nameAr.split(' ').first ?? 'يوسف'}' : 'Welcome, ${user?.nameEn.split(' ').first ?? 'Youssef'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr ? 'مسؤول النظام الرئيسي' : 'System Super Admin',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              // Bell icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      size: 26,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentTabIndex = 4;
                        _moreSubModule = 'alerts';
                      });
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2x2 Core Metrics Grid (Exact values from Reference Image 2)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _buildRefMetricCard(
                label: isAr ? 'المزارعين' : 'Farmers',
                value: '532',
                growth: '+12%',
                icon: Icons.people_outline_rounded,
                isDark: isDark,
                onTap: () => setState(() => _currentTabIndex = 2),
              ),
              _buildRefMetricCard(
                label: isAr ? 'المزارع' : 'Farms',
                value: '148',
                growth: '+8%',
                icon: Icons.spa_outlined,
                isDark: isDark,
                onTap: () => setState(() => _currentTabIndex = 1),
              ),
              _buildRefMetricCard(
                label: isAr ? 'الأجهزة (IoT)' : 'IoT Devices',
                value: '784',
                growth: '+15%',
                icon: Icons.memory_rounded,
                isDark: isDark,
                onTap: () => setState(() => _currentTabIndex = 3),
              ),
              _buildRefMetricCard(
                label: isAr ? 'الاشتراكات الفعالة' : 'Active Subscriptions',
                value: '410',
                growth: '+9%',
                icon: Icons.workspace_premium_outlined,
                isDark: isDark,
                onTap: () {
                  setState(() {
                    _currentTabIndex = 4;
                    _moreSubModule = 'subscriptions';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // System Health Section (Exact Match to Reference Image 2: Server, IoT, Database)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'حالة الأنظمة' : 'System Health',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 14),
                _buildHealthItem(
                  title: isAr ? 'الخادم (Server)' : 'Server Infrastructure',
                  status: isAr ? 'يعمل' : 'Operational',
                  isDark: isDark,
                ),
                const Divider(height: 18),
                _buildHealthItem(
                  title: isAr ? 'خدمة الأجهزة (IoT)' : 'IoT Telemetry Broker',
                  status: isAr ? 'يعمل' : 'Operational',
                  isDark: isDark,
                ),
                const Divider(height: 18),
                _buildHealthItem(
                  title: isAr ? 'قاعدة البيانات' : 'Primary Database',
                  status: isAr ? 'يعمل' : 'Operational',
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pending Farmer Approvals Section (Triage)
          if (pendingFarmers.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isAr ? 'طلبات تسجيل مزارعين معلقة (${pendingFarmers.length})' : 'Pending Registrations (${pendingFarmers.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _currentTabIndex = 2),
                  child: Text(isAr ? 'عرض الكل' : 'View All', style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...pendingFarmers.map(
              (farmer) => Card(
                elevation: 0,
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFFEF3C7),
                        child: const Icon(Icons.person_outline_rounded, color: Color(0xFFD97706), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? farmer.nameAr : farmer.nameEn,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(farmer.phone, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _authService.approveFarmerRegistration(farmer.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isAr ? 'تمت الموافقة وتفعيل الحساب بنجاح' : 'Farmer approved')),
                          );
                        },
                        child: Text(isAr ? 'موافقة' : 'Approve', style: const TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRefMetricCard({
    required String label,
    required String value,
    required String growth,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
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
                Icon(icon, color: AppColors.primaryGreen, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    growth,
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthItem({
    required String title,
    required String status,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF374151),
          ),
        ),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 1: FARMS MANAGEMENT (Reference Image 2, Panel 4)
  // =========================================================================
  Widget _buildFarmsTab(bool isDark, bool isAr) {
    // Exact cards matching Reference Image 2
    final List<Map<String, dynamic>> mockFarmsList = [
      {
        'name': isAr ? 'مزرعة النور' : 'Al-Nour Farm',
        'details': isAr ? 'المنيا - 32 فدان' : 'Minya - 32 Feddans',
        'status': isAr ? 'فعالة' : 'Active',
        'badgeColor': const Color(0xFF16A34A),
        'badgeBg': const Color(0xFFDCFCE7),
      },
      {
        'name': isAr ? 'مزرعة الواحة' : 'Al-Waha Farm',
        'details': isAr ? 'بني سويف - 18 فدان' : 'Beni Suef - 18 Feddans',
        'status': isAr ? 'فعالة' : 'Active',
        'badgeColor': const Color(0xFF16A34A),
        'badgeBg': const Color(0xFFDCFCE7),
      },
      {
        'name': isAr ? 'مزرعة الريان' : 'Al-Rayan Farm',
        'details': isAr ? 'الفيوم - 25 فدان' : 'Fayoum - 25 Feddans',
        'status': isAr ? 'تجريبية' : 'Trial',
        'badgeColor': const Color(0xFFD97706),
        'badgeBg': const Color(0xFFFEF3C7),
      },
      {
        'name': isAr ? 'مزرعة الخير' : 'Al-Khair Farm',
        'details': isAr ? 'أسيوط - 40 فدان' : 'Asyut - 40 Feddans',
        'status': isAr ? 'موقوفة' : 'Suspended',
        'badgeColor': const Color(0xFFDC2626),
        'badgeBg': const Color(0xFFFEE2E2),
      },
    ];

    final filtered = mockFarmsList.where((f) {
      final nameStr = f['name'] as String;
      final detailsStr = f['details'] as String;
      final matchesSearch = _farmSearch.isEmpty ||
          nameStr.toLowerCase().contains(_farmSearch.toLowerCase()) ||
          detailsStr.toLowerCase().contains(_farmSearch.toLowerCase());
      final matchesFilter = _farmFilter == 'الكل' || f['status'] == _farmFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'إدارة المزارع' : 'Farms Management',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Search Field
              TextField(
                onChanged: (val) => setState(() => _farmSearch = val),
                decoration: InputDecoration(
                  hintText: isAr ? 'بحث باسم المزرعة أو المالك ...' : 'Search farm or owner name...',
                  hintStyle: const TextStyle(fontSize: 12),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['الكل', 'فعالة', 'موقوفة', 'تجريبية'].map((chip) {
                    final selected = _farmFilter == chip;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(chip, style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
                        selected: selected,
                        selectedColor: AppColors.primaryGreen,
                        onSelected: (val) {
                          if (val) setState(() => _farmFilter = chip);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // Farms List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final farm = filtered[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    // Farm image placeholder circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.grass_rounded, color: AppColors.primaryGreen, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farm['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            farm['details'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: farm['badgeBg'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        farm['status'] as String,
                        style: TextStyle(
                          color: farm['badgeColor'] as Color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 20),
                  ],
                ),
              );
            },
          ),
        ),
        // Bottom Action Button: + إضافة مزرعة
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.farmAddEdit);
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                isAr ? '+ إضافة مزرعة' : '+ Add New Farm',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 2: USER MANAGEMENT (Reference Image 2, Panel 5)
  // =========================================================================
  Widget _buildUsersTab(bool isDark, bool isAr) {
    // Exact cards matching Reference Image 2
    final List<Map<String, String>> mockUsersList = [
      {
        'name': isAr ? 'أحمد محمود' : 'Ahmed Mahmoud',
        'role': isAr ? 'مزارع' : 'Farmer',
        'status': isAr ? 'فعال' : 'Active',
      },
      {
        'name': isAr ? 'محمد علي' : 'Mohamed Ali',
        'role': isAr ? 'مزارع' : 'Farmer',
        'status': isAr ? 'فعال' : 'Active',
      },
      {
        'name': isAr ? 'سارة حسن' : 'Sara Hassan',
        'role': isAr ? 'مشرف منطقة' : 'Area Supervisor',
        'status': isAr ? 'فعال' : 'Active',
      },
      {
        'name': isAr ? 'محمود إبراهيم' : 'Mahmoud Ibrahim',
        'role': isAr ? 'الدعم الفني' : 'Technical Support',
        'status': isAr ? 'فعال' : 'Active',
      },
    ];

    final filtered = mockUsersList.where((u) {
      final nameStr = u['name'] ?? '';
      final roleStr = u['role'] ?? '';
      final matchesSearch = _userSearch.isEmpty ||
          nameStr.toLowerCase().contains(_userSearch.toLowerCase()) ||
          roleStr.toLowerCase().contains(_userSearch.toLowerCase());
      final matchesFilter = _userFilter == 'الكل' ||
          (_userFilter == 'المزارعون' && u['role'] == 'مزارع') ||
          (_userFilter == 'المشرفون' && u['role'] == 'مشرف منطقة') ||
          (_userFilter == 'الدعم' && u['role'] == 'الدعم الفني');
      return matchesSearch && matchesFilter;
    }).toList();

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'إدارة المستخدمين' : 'User Management',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Search Field
              TextField(
                onChanged: (val) => setState(() => _userSearch = val),
                decoration: InputDecoration(
                  hintText: isAr ? 'بحث عن مستخدم ...' : 'Search for a user...',
                  hintStyle: const TextStyle(fontSize: 12),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['الكل', 'المزارعون', 'المشرفون', 'الدعم'].map((chip) {
                    final selected = _userFilter == chip;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(chip, style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
                        selected: selected,
                        selectedColor: AppColors.primaryGreen,
                        onSelected: (val) {
                          if (val) setState(() => _userFilter = chip);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // Users List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final userItem = filtered[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFDCFCE7),
                      child: const Icon(Icons.person_outline_rounded, color: AppColors.primaryGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userItem['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userItem['role'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        userItem['status'] as String,
                        style: const TextStyle(
                          color: Color(0xFF16A34A),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 20),
                  ],
                ),
              );
            },
          ),
        ),
        // Bottom Action Button: + إضافة مستخدم
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _openCreateUserDialog(isDark, isAr),
              icon: const Icon(Icons.person_add_rounded, size: 20),
              label: Text(
                isAr ? '+ إضافة مستخدم' : '+ Add New User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openCreateUserDialog(bool isDark, bool isAr) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    UserRole selectedRole = UserRole.farmOwner;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isAr ? 'إضافة مستخدم جديد' : 'Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: isAr ? 'الاسم بالكامل' : 'Full Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: isAr ? 'البريد الإلكتروني' : 'Email Address'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(labelText: isAr ? 'رقم الهاتف' : 'Phone Number'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: InputDecoration(labelText: isAr ? 'الدور والنوع' : 'Role'),
                items: [
                  DropdownMenuItem(value: UserRole.farmOwner, child: Text(isAr ? 'مزارع' : 'Farmer')),
                  DropdownMenuItem(value: UserRole.superAdmin, child: Text(isAr ? 'مسؤول نظام' : 'Super Admin')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedRole = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty && emailCtrl.text.trim().isNotEmpty) {
                  _authService.createAccountByAdmin(
                    username: emailCtrl.text.split('@').first,
                    nameEn: nameCtrl.text,
                    nameAr: nameCtrl.text,
                    email: emailCtrl.text,
                    phone: phoneCtrl.text,
                    role: selectedRole,
                    initialPassword: 'Temp@2026Password',
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isAr ? 'تم إنشاء الحساب بنجاح' : 'User created successfully')),
                  );
                }
              },
              child: Text(isAr ? 'حفظ' : 'Save', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // TAB 3: IOT DEVICE MANAGEMENT (Reference Image 2, Panel 6)
  // =========================================================================
  Widget _buildDevicesTab(bool isDark, bool isAr) {
    // Exact cards matching Reference Image 2
    final List<Map<String, dynamic>> mockDevicesList = [
      {
        'id': 'ESP32 - #GF001',
        'zone': isAr ? 'مزرعة النور - منطقة A' : 'Al-Nour Farm - Zone A',
        'status': isAr ? 'متصل' : 'Connected',
        'badgeColor': const Color(0xFF16A34A),
        'badgeBg': const Color(0xFFDCFCE7),
      },
      {
        'id': 'ESP32 - #GF002',
        'zone': isAr ? 'مزرعة الواحة - منطقة B' : 'Al-Waha Farm - Zone B',
        'status': isAr ? 'متصل' : 'Connected',
        'badgeColor': const Color(0xFF16A34A),
        'badgeBg': const Color(0xFFDCFCE7),
      },
      {
        'id': 'ESP32 - #GF003',
        'zone': isAr ? 'مزرعة الريان - منطقة C' : 'Al-Rayan Farm - Zone C',
        'status': isAr ? 'غير متصل' : 'Offline',
        'badgeColor': const Color(0xFFDC2626),
        'badgeBg': const Color(0xFFFEE2E2),
      },
      {
        'id': 'ESP32 - #GF004',
        'zone': isAr ? 'مزرعة الخير - منطقة A' : 'Al-Khair Farm - Zone A',
        'status': isAr ? 'بحاجة صيانة' : 'Needs Maintenance',
        'badgeColor': const Color(0xFFD97706),
        'badgeBg': const Color(0xFFFEF3C7),
      },
    ];

    final filtered = mockDevicesList.where((d) {
      final idStr = d['id'] as String;
      final zoneStr = d['zone'] as String;
      final matchesSearch = _deviceSearch.isEmpty ||
          idStr.toLowerCase().contains(_deviceSearch.toLowerCase()) ||
          zoneStr.toLowerCase().contains(_deviceSearch.toLowerCase());
      final matchesFilter = _deviceFilter == 'الكل' || d['status'] == _deviceFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'إدارة الأجهزة (IoT)' : 'IoT Hardware Management',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Search Field
              TextField(
                onChanged: (val) => setState(() => _deviceSearch = val),
                decoration: InputDecoration(
                  hintText: isAr ? 'بحث برقم الجهاز أو المزرعة ...' : 'Search device ID or farm...',
                  hintStyle: const TextStyle(fontSize: 12),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['الكل', 'متصل', 'غير متصل', 'بحاجة صيانة'].map((chip) {
                    final selected = _deviceFilter == chip;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(chip, style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
                        selected: selected,
                        selectedColor: AppColors.primaryGreen,
                        onSelected: (val) {
                          if (val) setState(() => _deviceFilter = chip);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // Devices List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final device = filtered[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    // ESP32 Graphic Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.memory_rounded, color: Color(0xFF4ADE80), size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device['id'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            device['zone'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: device['badgeBg'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        device['status'] as String,
                        style: TextStyle(
                          color: device['badgeColor'] as Color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 20),
                  ],
                ),
              );
            },
          ),
        ),
        // Bottom Action Button: + إضافة جهاز
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.deviceSetup);
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                isAr ? '+ إضافة جهاز' : '+ Add New IoT Device',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TAB 4: MORE HUB (Subscriptions, Analytics, Notifications, Settings)
  // =========================================================================
  Widget _buildMoreTab(bool isDark, bool isAr) {
    return Column(
      children: [
        // Sub-navigation bar within More tab
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSubNavChip(
                  label: isAr ? 'الاشتراكات والباقات' : 'Subscriptions',
                  id: 'subscriptions',
                  icon: Icons.workspace_premium_rounded,
                ),
                const SizedBox(width: 8),
                _buildSubNavChip(
                  label: isAr ? 'التقارير والتحليلات' : 'Analytics',
                  id: 'analytics',
                  icon: Icons.bar_chart_rounded,
                ),
                const SizedBox(width: 8),
                _buildSubNavChip(
                  label: isAr ? 'التنبيهات والإشعارات' : 'Alerts',
                  id: 'alerts',
                  icon: Icons.notifications_active_rounded,
                ),
                const SizedBox(width: 8),
                _buildSubNavChip(
                  label: isAr ? 'إعدادات النظام' : 'Settings',
                  id: 'settings',
                  icon: Icons.settings_rounded,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Builder(
            builder: (context) {
              switch (_moreSubModule) {
                case 'analytics':
                  return _buildMoreAnalyticsView(isDark, isAr);
                case 'alerts':
                  return _buildMoreAlertsView(isDark, isAr);
                case 'settings':
                  return _buildMoreSettingsView(isDark, isAr);
                case 'subscriptions':
                default:
                  return _buildMoreSubscriptionsView(isDark, isAr);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubNavChip({
    required String label,
    required String id,
    required IconData icon,
  }) {
    final selected = _moreSubModule == id;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: selected ? Colors.white : AppColors.primaryGreen),
      label: Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
      selected: selected,
      selectedColor: AppColors.primaryGreen,
      onSelected: (val) {
        if (val) setState(() => _moreSubModule = id);
      },
    );
  }

  // --- Subscriptions Sub-Module (Reference Image 2, Panel 7) ---
  Widget _buildMoreSubscriptionsView(bool isDark, bool isAr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Two Header Stats Cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'المشتركين النشطين' : 'Active Subscribers',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.grey : const Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('410', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Text('↑ +9%', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'إجمالي الإيرادات' : 'Total Revenue',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.grey : const Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(isAr ? '306,400 ج.م' : '306,400 EGP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Text('↑ +18%', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // إدارة الباقات
        Text(
          isAr ? 'إدارة الباقات' : 'Subscription Plans',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildPlanCard(
          title: isAr ? 'الباقة الأساسية' : 'Basic Plan',
          details: isAr ? '10 أشجار - 500 ج.م / شهر' : '10 Trees - 500 EGP / Month',
          icon: Icons.eco_rounded,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildPlanCard(
          title: isAr ? 'باقة النمو' : 'Growth Plan',
          details: isAr ? '50 شجرة - 750 ج.م / شهر' : '50 Trees - 750 EGP / Month',
          icon: Icons.spa_rounded,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildPlanCard(
          title: isAr ? 'الباقة الاحترافية' : 'Pro Plan',
          details: isAr ? '100 شجرة - 1,000 ج.م / شهر' : '100 Trees - 1,000 EGP / Month',
          icon: Icons.workspace_premium_rounded,
          isDark: isDark,
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isAr ? 'شاشة إضافة باقة جديدة متاحة للإدارة' : 'Add plan dialog')),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(isAr ? '+ إضافة باقة' : '+ Add New Plan', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String details,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(details, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey : const Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  // --- Reports & Analytics Sub-Module (Reference Image 2, Panel 8) ---
  Widget _buildMoreAnalyticsView(bool isDark, bool isAr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Timeframe selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(isAr ? 'التقارير والتحليلات' : 'Reports & Analytics', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Text(_analyticsTimeframe, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Sub-tabs: عام | الري | الأجهزة | المستخدمون
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['عام', 'الري', 'الأجهزة', 'المستخدمون'].map((tab) {
              final selected = _analyticsSubTab == tab;
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: ChoiceChip(
                  label: Text(tab, style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
                  selected: selected,
                  selectedColor: AppColors.primaryGreen,
                  onSelected: (val) {
                    if (val) setState(() => _analyticsSubTab = tab);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Water Saved & Savings % Cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isAr ? 'المياه الموفرة' : 'Water Saved', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const Icon(Icons.water_drop_outlined, color: Color(0xFF0284C7), size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('32,450', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(isAr ? '(ألف لتر)  ↑ +21%' : '(kL) ↑ +21%', style: const TextStyle(fontSize: 10, color: Color(0xFF16A34A))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isAr ? 'نسبة التوفير' : 'Savings Rate', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const Icon(Icons.energy_savings_leaf_outlined, color: Color(0xFF16A34A), size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('28%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('↑ +9%', style: const TextStyle(fontSize: 10, color: Color(0xFF16A34A))),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // استهلاك المياه (Line Chart placeholder matching Reference Image 2)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'استهلاك المياه (ألف لتر)' : 'Water Consumption (kL)',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: CustomPaint(
                  size: const Size(double.infinity, 140),
                  painter: _AdminAnalyticsChartPainter(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isAr ? '1 نوفمبر' : 'Nov 1', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(isAr ? '8 نوفمبر' : 'Nov 8', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(isAr ? '15 نوفمبر' : 'Nov 15', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(isAr ? '22 نوفمبر' : 'Nov 22', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(isAr ? '30 نوفمبر' : 'Nov 30', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Alerts & Notifications Sub-Module (Reference Image 2, Panel 9) ---
  Widget _buildMoreAlertsView(bool isDark, bool isAr) {
    final mockAlerts = [
      {
        'title': isAr ? 'انخفاض رطوبة التربة' : 'Low Soil Moisture',
        'sub': isAr ? 'مزرعة النور - منطقة A\nالرطوبة 18% (أقل من الحد)' : 'Al-Nour Farm - Zone A\nMoisture 18% (Below Threshold)',
        'time': isAr ? 'منذ 5 دقائق' : '5m ago',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFDC2626),
        'bg': const Color(0xFFFEE2E2),
        'category': 'أعطال',
      },
      {
        'title': isAr ? 'جهاز غير متصل' : 'Device Offline',
        'sub': isAr ? 'ESP32 - #GF003\nمزرعة الريان - منطقة C' : 'ESP32 - #GF003\nAl-Rayan Farm - Zone C',
        'time': isAr ? 'منذ 17 دقيقة' : '17m ago',
        'icon': Icons.wifi_off_rounded,
        'color': const Color(0xFFD97706),
        'bg': const Color(0xFFFEF3C7),
        'category': 'أعطال',
      },
      {
        'title': isAr ? 'انتهاء اشتراك قريب' : 'Subscription Expiring Soon',
        'sub': isAr ? 'مزرعة الواحة\nيتبقى 3 أيام على انتهاء الاشتراك' : 'Al-Waha Farm\n3 days remaining',
        'time': isAr ? 'منذ ساعة' : '1h ago',
        'icon': Icons.calendar_month_outlined,
        'color': const Color(0xFF0284C7),
        'bg': const Color(0xFFE0F2FE),
        'category': 'النظام',
      },
      {
        'title': isAr ? 'تم تنفيذ الري تلقائياً' : 'Automatic Irrigation Completed',
        'sub': isAr ? 'مزرعة الخير - منطقة B\nمدة الري: 30 دقيقة' : 'Al-Khair Farm - Zone B\nRuntime: 30 mins',
        'time': isAr ? 'منذ ساعتين' : '2h ago',
        'icon': Icons.check_circle_outline_rounded,
        'color': const Color(0xFF16A34A),
        'bg': const Color(0xFFDCFCE7),
        'category': 'مؤشرات',
      },
    ];

    final filtered = mockAlerts.where((a) {
      if (_alertFilter == 'الكل') return true;
      return a['category'] == _alertFilter;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isAr ? 'التنبيهات والإشعارات' : 'Alerts & Notifications', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['الكل', 'أعطال', 'مؤشرات', 'النظام'].map((chip) {
                    final selected = _alertFilter == chip;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(chip, style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
                        selected: selected,
                        selectedColor: AppColors.primaryGreen,
                        onSelected: (val) {
                          if (val) setState(() => _alertFilter = chip);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final alert = filtered[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: alert['bg'] as Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(alert['icon'] as IconData, color: alert['color'] as Color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(alert['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(alert['time'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert['sub'] as String,
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey : const Color(0xFF4B5563)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- System Settings Sub-Module (Reference Image 2, Panel 10) ---
  Widget _buildMoreSettingsView(bool isDark, bool isAr) {
    final settingsItems = [
      {'title': isAr ? 'إعدادات التطبيق' : 'App Settings', 'icon': Icons.settings_applications_outlined},
      {'title': isAr ? 'إدارة الصلاحيات والأدوار' : 'Roles & Access Permissions', 'icon': Icons.admin_panel_settings_outlined},
      {'title': isAr ? 'إعدادات الأجهزة (IoT)' : 'IoT Hardware Configurations', 'icon': Icons.memory_outlined},
      {'title': isAr ? 'إعدادات الإشعارات' : 'Notification Preferences', 'icon': Icons.notifications_none_outlined},
      {'title': isAr ? 'إعدادات الاشتراكات والدفع' : 'Subscription & Billing Settings', 'icon': Icons.payment_outlined},
      {'title': isAr ? 'نسخ احتياطي للبيانات' : 'Data Backup & Restore', 'icon': Icons.cloud_download_outlined},
      {'title': isAr ? 'سجلات النظام' : 'System Logs & Audit Trail', 'icon': Icons.description_outlined},
      {'title': isAr ? 'حول النظام' : 'About Green Flow Platform', 'icon': Icons.info_outline_rounded},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: settingsItems.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = settingsItems[index];
        return InkWell(
          onTap: () {
            if (index == 7) {
              _showAboutDialog(isAr);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item['title']} - ${isAr ? 'الإعدادات جاهزة' : 'Settings configured'}')),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(item['icon'] as IconData, size: 20, color: AppColors.primaryGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['title'] as String,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_left_rounded, color: Colors.grey, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog(bool isAr) {
    showAboutDialog(
      context: context,
      applicationName: 'Green Flow',
      applicationVersion: '2.0.0',
      applicationIcon: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 40),
      children: [
        Text(
          isAr
              ? 'نظام جرين فلو لإدارة المزارع الذكية، أنظمة الري الدقيق، وحساسات إنترنت الأشياء الموزعة.'
              : 'Green Flow Enterprise Smart Agriculture & IoT Management Platform.',
        ),
      ],
    );
  }
}

/// Custom painter for the water consumption trend line chart in Analytics.
class _AdminAnalyticsChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF16A34A).withValues(alpha: 0.25),
          const Color(0xFF16A34A).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.55),
      Offset(size.width * 0.4, size.height * 0.65),
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width, size.height * 0.35),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
      fillPath.lineTo(points[i].dx, points[i].dy);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw active point
    final dotPaint = Paint()..color = const Color(0xFF16A34A);
    final dotOuter = Paint()..color = Colors.white;
    canvas.drawCircle(points.last, 5, dotOuter);
    canvas.drawCircle(points.last, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
