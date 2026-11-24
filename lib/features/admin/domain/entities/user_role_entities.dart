/// Admin domain entities: user roles, app user, and permission matrix.
library;

enum UserRole { systemAdmin, farmOwner, technician, farmWorker, financeManager }

extension UserRoleLabel on UserRole {
  String get labelEn {
    switch (this) {
      case UserRole.systemAdmin:
        return 'System Admin';
      case UserRole.farmOwner:
        return 'Farm Owner';
      case UserRole.technician:
        return 'Field Technician';
      case UserRole.farmWorker:
        return 'Agricultural Worker';
      case UserRole.financeManager:
        return 'Finance Manager';
    }
  }

  String get labelAr {
    switch (this) {
      case UserRole.systemAdmin:
        return 'مدير النظام';
      case UserRole.farmOwner:
        return 'مالك مزرعة';
      case UserRole.technician:
        return 'فني ميداني';
      case UserRole.farmWorker:
        return 'عامل زراعي';
      case UserRole.financeManager:
        return 'مسؤول مالي';
    }
  }
}

class AppUserEntity {
  const AppUserEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.email,
    required this.phone,
    required this.role,
    this.farmId,
    required this.isActive,
    required this.joinedAt,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String email;
  final String phone;
  final UserRole role;
  final String? farmId;
  final bool isActive;
  final DateTime joinedAt;
}

class PermissionMatrix {
  const PermissionMatrix._();

  static bool canManageUsers(UserRole role) => role == UserRole.systemAdmin;
  static bool canManageFarms(UserRole role) =>
      role == UserRole.systemAdmin || role == UserRole.farmOwner;
  static bool canControlIrrigation(UserRole role) =>
      role == UserRole.systemAdmin ||
      role == UserRole.farmOwner ||
      role == UserRole.farmWorker;
  static bool canApproveQuotations(UserRole role) =>
      role == UserRole.systemAdmin || role == UserRole.financeManager;
  static bool canViewAnalytics(UserRole role) => true;
  static bool canManageDevices(UserRole role) =>
      role == UserRole.systemAdmin || role == UserRole.technician;
}
