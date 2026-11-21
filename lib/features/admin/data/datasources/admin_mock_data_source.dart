/// Admin mock data source providing demo users and summary statistics.
library;

import '../../domain/entities/user_role_entities.dart';

class AdminSummaryStats {
  const AdminSummaryStats({
    required this.totalUsers,
    required this.activeFarms,
    required this.pendingInspections,
    required this.activeDevices,
  });

  final int totalUsers;
  final int activeFarms;
  final int pendingInspections;
  final int activeDevices;
}

class AdminMockDataSource {
  static const AdminMockDataSource _instance = AdminMockDataSource._internal();
  factory AdminMockDataSource() => _instance;
  const AdminMockDataSource._internal();

  List<AppUserEntity> getUsers() {
    return [
      AppUserEntity(
        id: 'usr-001',
        nameEn: 'Youssef Al-Mansouri',
        nameAr: 'يوسف المنصوري',
        email: 'youssef@greenflow.io',
        phone: '+20 100 123 4567',
        role: UserRole.systemAdmin,
        farmId: null,
        isActive: true,
        joinedAt: DateTime(2024, 1, 15),
      ),
      AppUserEntity(
        id: 'usr-002',
        nameEn: 'Ahmed Al-Nour',
        nameAr: 'أحمد النور',
        email: 'ahmed@alnour-farm.com',
        phone: '+20 111 234 5678',
        role: UserRole.farmOwner,
        farmId: 'farm-001',
        isActive: true,
        joinedAt: DateTime(2024, 3, 22),
      ),
      AppUserEntity(
        id: 'usr-003',
        nameEn: 'Fatima Khalil',
        nameAr: 'فاطمة خليل',
        email: 'fatima@palmvalley.ag',
        phone: '+20 112 345 6789',
        role: UserRole.farmOwner,
        farmId: 'farm-002',
        isActive: true,
        joinedAt: DateTime(2024, 5, 10),
      ),
      AppUserEntity(
        id: 'usr-004',
        nameEn: 'Hassan Nabil',
        nameAr: 'حسن نبيل',
        email: 'hassan@greenflow.io',
        phone: '+20 100 456 7890',
        role: UserRole.farmWorker,
        farmId: 'farm-001',
        isActive: false,
        joinedAt: DateTime(2024, 7, 1),
      ),
      AppUserEntity(
        id: 'usr-005',
        nameEn: 'Kareem Samir',
        nameAr: 'كريم سمير',
        email: 'kareem@iottech.dev',
        phone: '+20 155 567 8901',
        role: UserRole.technician,
        farmId: null,
        isActive: true,
        joinedAt: DateTime(2024, 9, 14),
      ),
    ];
  }

  AdminSummaryStats getSummaryStats() {
    return const AdminSummaryStats(
      totalUsers: 24,
      activeFarms: 8,
      pendingInspections: 3,
      activeDevices: 47,
    );
  }
}
