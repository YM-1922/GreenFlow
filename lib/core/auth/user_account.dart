/// Centralized User Roles, Account Statuses, and Unified User Account Entity.
library;

/// Five primary business roles supported across Green Flow.
enum UserRole {
  superAdmin,
  farmOwner,
  technician,
  farmWorker,
  financeManager;

  String get labelEn {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.farmOwner:
        return 'Farm Owner (Farmer)';
      case UserRole.technician:
        return 'Field Technician';
      case UserRole.farmWorker:
        return 'Agricultural Worker';
      case UserRole.financeManager:
        return 'Finance & Pricing Manager';
    }
  }

  String get labelAr {
    switch (this) {
      case UserRole.superAdmin:
        return 'المدير العام للنظام (Super Admin)';
      case UserRole.farmOwner:
        return 'مالك المزرعة (مزارع)';
      case UserRole.technician:
        return 'فني التركيبات والصيانة';
      case UserRole.farmWorker:
        return 'عامل زراعي ميداني';
      case UserRole.financeManager:
        return 'مدير المالية والتسعير';
    }
  }
}

/// Lifecycle status for all accounts.
enum AccountStatus {
  pendingApproval,
  approved,
  rejected,
  suspended,
  inactive;

  String get labelEn {
    switch (this) {
      case AccountStatus.pendingApproval:
        return 'Pending Approval';
      case AccountStatus.approved:
        return 'Active / Approved';
      case AccountStatus.rejected:
        return 'Registration Rejected';
      case AccountStatus.suspended:
        return 'Account Suspended';
      case AccountStatus.inactive:
        return 'Deactivated';
    }
  }

  String get labelAr {
    switch (this) {
      case AccountStatus.pendingApproval:
        return 'قيد المراجعة والموافقة';
      case AccountStatus.approved:
        return 'مفعل ومعتمد';
      case AccountStatus.rejected:
        return 'مرفوض';
      case AccountStatus.suspended:
        return 'حساب معلق';
      case AccountStatus.inactive:
        return 'غير نشط';
    }
  }
}

/// User account entity across the centralized identity system.
class UserAccount {
  final String id;
  final String username;
  final String nameEn;
  final String nameAr;
  final String email;
  final String phone;
  final UserRole role;
  final AccountStatus status;
  final String? assignedFarmId; // For farmer, worker, or assigned technician
  final List<String> assignedFarmIds; // For technicians managing multiple farms
  final String? passwordHash;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? rejectionReason;

  const UserAccount({
    required this.id,
    required this.username,
    required this.nameEn,
    required this.nameAr,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.assignedFarmId,
    this.assignedFarmIds = const [],
    this.passwordHash,
    required this.createdAt,
    this.lastLoginAt,
    this.rejectionReason,
  });

  bool get isActive => status == AccountStatus.approved;
  bool get isPending => status == AccountStatus.pendingApproval;
  bool get isSuspended => status == AccountStatus.suspended;

  UserAccount copyWith({
    String? id,
    String? username,
    String? nameEn,
    String? nameAr,
    String? email,
    String? phone,
    UserRole? role,
    AccountStatus? status,
    String? assignedFarmId,
    List<String>? assignedFarmIds,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? rejectionReason,
  }) {
    return UserAccount(
      id: id ?? this.id,
      username: username ?? this.username,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      assignedFarmId: assignedFarmId ?? this.assignedFarmId,
      assignedFarmIds: assignedFarmIds ?? this.assignedFarmIds,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'email': email,
        'phone': phone,
        'role': role.index,
        'status': status.index,
        'assignedFarmId': assignedFarmId,
        'assignedFarmIds': assignedFarmIds,
        'passwordHash': passwordHash,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        id: json['id'] as String,
        username: json['username'] as String? ?? json['email'] as String,
        nameEn: json['nameEn'] as String? ?? 'User',
        nameAr: json['nameAr'] as String? ?? 'مستخدم',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        role: UserRole.values[(json['role'] as int? ?? 1).clamp(0, UserRole.values.length - 1)],
        status: AccountStatus.values[(json['status'] as int? ?? 1).clamp(0, AccountStatus.values.length - 1)],
        assignedFarmId: json['assignedFarmId'] as String?,
        assignedFarmIds: (json['assignedFarmIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        passwordHash: json['passwordHash'] as String?,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
        lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt'] as String) : null,
        rejectionReason: json['rejectionReason'] as String?,
      );
}
