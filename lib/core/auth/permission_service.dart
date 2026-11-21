/// Role-based access control and security matrix for Green Flow.
library;

import 'user_account.dart';

class PermissionService {
  PermissionService._();

  /// Whether user can access system-wide super admin tools and settings.
  static bool canAccessSuperAdmin(UserRole role) => role == UserRole.superAdmin;

  /// Whether user can create, update, or deactivate accounts.
  static bool canManageUsers(UserRole role) => role == UserRole.superAdmin;

  /// Whether user can approve/reject farmer registration applications.
  static bool canApproveFarmers(UserRole role) => role == UserRole.superAdmin;

  /// Whether user can access Finance & Pricing dashboard.
  static bool canAccessFinance(UserRole role) =>
      role == UserRole.superAdmin || role == UserRole.financeManager;

  /// Whether user can manage products, hardware catalog and service prices.
  static bool canManagePricing(UserRole role) =>
      role == UserRole.superAdmin || role == UserRole.financeManager;

  /// Whether user can prepare, approve, and send quotations.
  static bool canManageQuotations(UserRole role) =>
      role == UserRole.superAdmin || role == UserRole.financeManager;

  /// Whether user can manage invoices and process simulated payments.
  static bool canManageInvoices(UserRole role) =>
      role == UserRole.superAdmin || role == UserRole.financeManager;

  /// Whether user can access field technician tasks, inspections & installations.
  static bool canAccessTechnicianDashboard(UserRole role) =>
      role == UserRole.superAdmin || role == UserRole.technician;

  /// Whether user can access agricultural worker tasks and daily irrigation.
  static bool canAccessWorkerDashboard(UserRole role) =>
      role == UserRole.superAdmin || role == UserRole.farmWorker;

  /// Whether user can view and manage farms.
  static bool canManageFarms(UserRole role) =>
      role == UserRole.superAdmin || role == UserRole.farmOwner;

  /// Verify if current user owns or is assigned to a specific farm.
  static bool canAccessFarm(UserAccount? user, String farmId, {String? ownerUserId}) {
    if (user == null) return false;
    if (user.role == UserRole.superAdmin) {
      return true; // Super Admin has system-wide access
    }
    if (user.role == UserRole.farmOwner) {
      // Must be owner of the farm or assigned explicitly
      if (ownerUserId != null && ownerUserId == user.id) return true;
      return user.assignedFarmId == farmId || user.assignedFarmIds.contains(farmId);
    }
    if (user.role == UserRole.technician) {
      return user.assignedFarmIds.contains(farmId) || user.assignedFarmId == farmId;
    }
    if (user.role == UserRole.farmWorker) {
      return user.assignedFarmId == farmId;
    }
    if (user.role == UserRole.financeManager) {
      return true; // Finance has read-only farm access for pricing/billing context
    }
    return false;
  }

  /// Whether user can execute irrigation pump/solenoid actuators.
  static bool canControlIrrigation(UserAccount? user, String farmId, {String? ownerUserId}) {
    if (user == null || !canAccessFarm(user, farmId, ownerUserId: ownerUserId)) return false;
    // Farm workers can control only assigned farm irrigation, owners control their farm, superAdmin controls all
    return user.role == UserRole.superAdmin ||
        user.role == UserRole.farmOwner ||
        user.role == UserRole.farmWorker;
  }

  /// Whether user can access a specific inspection request.
  static bool canAccessInspection(UserAccount? user, {String? customerUserId, String? farmId, String? assignedTechnicianId}) {
    if (user == null) return false;
    if (user.role == UserRole.superAdmin) return true;
    if (user.role == UserRole.farmOwner) {
      return customerUserId == user.id || (farmId != null && canAccessFarm(user, farmId));
    }
    if (user.role == UserRole.technician) {
      if (assignedTechnicianId != null && assignedTechnicianId == user.id) return true;
      if (farmId != null && (user.assignedFarmIds.contains(farmId) || user.assignedFarmId == farmId)) return true;
      return false;
    }
    return false;
  }

  /// Whether user can view financial details (quotations / invoices).
  static bool canAccessFinancialRecord(UserAccount? user, {required String recordFarmerId}) {
    if (user == null) return false;
    if (user.role == UserRole.superAdmin || user.role == UserRole.financeManager) return true;
    if (user.role == UserRole.farmOwner) return user.id == recordFarmerId;
    return false;
  }

  /// Whether user can access a specific IoT device.
  static bool canAccessDevice(UserAccount? user, String farmId, {String? farmOwnerUserId}) {
    if (user == null) return false;
    return canAccessFarm(user, farmId, ownerUserId: farmOwnerUserId);
  }

  /// Verify that a non-admin cannot elevate their own role or modify other users.
  static bool canModifyUser(UserAccount? actor, String targetUserId) {
    if (actor == null) return false;
    if (actor.role == UserRole.superAdmin) return true;
    return false;
  }
}
