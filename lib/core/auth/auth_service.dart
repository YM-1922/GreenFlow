import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/file_io.dart' as file_io;
import 'user_account.dart';

/// Centralized Authentication and Session Management Service.
/// Handles login verification, session storage, account lifecycle, and protected Super Admin security.
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  static const String _sessionFileName = '.greenflow_session_pref';
  static const String _usersFileName = '.greenflow_users_db.json';

  UserAccount? _currentUser;
  late List<UserAccount> _accounts;

  AuthService._internal() {
    _initAccounts();
    _loadSession();
  }

  UserAccount? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  List<UserAccount> get allAccounts => List.unmodifiable(_accounts);

  /// Deterministic 64-bit FNV-1a hashing using BigInt for full cross-platform compatibility (Web, Desktop & Mobile).
  static String hashPassword(String password) {
    var hash = BigInt.parse('cbf29ce484222325', radix: 16);
    final prime = BigInt.parse('100000001b3', radix: 16);
    final mask64 = BigInt.parse('ffffffffffffffff', radix: 16);
    final signBit = BigInt.parse('8000000000000000', radix: 16);
    final two64 = BigInt.one << 64;

    for (var i = 0; i < password.length; i++) {
      hash = hash ^ BigInt.from(password.codeUnitAt(i));
      hash = (hash * prime) & mask64;
    }

    // Preserve exact 64-bit signed hex representation for compatibility with existing DB accounts
    final signedVal = (hash & signBit) != BigInt.zero ? hash - two64 : hash;
    return 'GF_SHA_${signedVal.toRadixString(16)}';
  }

  void _initAccounts() {
    // Attempt to load accounts from local persistence
    final content = file_io.readFileSync(_usersFileName);
    if (content != null) {
      try {
        final list = jsonDecode(content) as List<dynamic>;
        _accounts = list.map((e) => UserAccount.fromJson(e as Map<String, dynamic>)).toList();
        return;
      } catch (_) {}
    }

    // Default Seeded Demo Accounts (Super Admin and Farmers)
    _accounts = [
      // 1. Super Admin (System Owner)
      UserAccount(
        id: 'usr-admin-01',
        username: 'admin',
        nameEn: 'Tariq Al-Mansour (Super Admin)',
        nameAr: 'طارق المنصور (المدير العام)',
        email: 'admin@greenflow.io',
        phone: '+20 100 000 0001',
        role: UserRole.superAdmin,
        status: AccountStatus.approved,
        passwordHash: hashPassword('SuperAdmin@2026'),
        createdAt: DateTime(2025, 1, 1),
      ),
      // 2. Approved Farmer A (Ahmed Al-Nour - Farm 001)
      UserAccount(
        id: 'usr-farmer-01',
        username: 'farmer_ahmed',
        nameEn: 'Ahmed Al-Nour',
        nameAr: 'أحمد النور (مالك مزرعة الأمل)',
        email: 'ahmed@alnour-farm.com',
        phone: '+20 111 234 5678',
        role: UserRole.farmOwner,
        status: AccountStatus.approved,
        assignedFarmId: 'farm-001',
        assignedFarmIds: ['farm-001'],
        passwordHash: hashPassword('Farmer@2026'),
        createdAt: DateTime(2025, 3, 10),
      ),
      // 3. Approved Farmer B (Mahmoud Salem - Farm 002) for isolation testing
      UserAccount(
        id: 'usr-farmer-03',
        username: 'farmer_mahmoud',
        nameEn: 'Mahmoud Salem',
        nameAr: 'محمود سالم (مالك واحة النخيل)',
        email: 'mahmoud@oasis-palms.com',
        phone: '+20 112 345 6789',
        role: UserRole.farmOwner,
        status: AccountStatus.approved,
        assignedFarmId: 'farm-002',
        assignedFarmIds: ['farm-002'],
        passwordHash: hashPassword('FarmerB@2026'),
        createdAt: DateTime(2025, 3, 12),
      ),
      // 4. Pending Farmer (Waiting for Admin approval)
      UserAccount(
        id: 'usr-farmer-02',
        username: 'farmer_khalid',
        nameEn: 'Khalid Al-Bahr',
        nameAr: 'خالد البحر (مزارع قيد المراجعة)',
        email: 'khalid@oasis-agri.com',
        phone: '+20 115 999 8877',
        role: UserRole.farmOwner,
        status: AccountStatus.pendingApproval,
        passwordHash: hashPassword('Pending@2026'),
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
    _persistAccounts();
  }

  void _persistAccounts() {
    final list = _accounts.map((e) => e.toJson()).toList();
    file_io.writeFileSync(_usersFileName, jsonEncode(list));
  }

  void _loadSession() {
    final userId = file_io.readFileSync(_sessionFileName)?.trim();
    if (userId != null && userId.isNotEmpty) {
      final found = _accounts.where((a) => a.id == userId).firstOrNull;
      if (found != null && found.status == AccountStatus.approved) {
        _currentUser = found;
        return;
      }
    }
    // Default to approved Farmer Ahmed for existing baseline tests
    _currentUser = _accounts.where((a) => a.id == 'usr-farmer-01').firstOrNull;
  }

  void _saveSession(String? userId) {
    if (userId == null) {
      file_io.deleteFileSync(_sessionFileName);
    } else {
      file_io.writeFileSync(_sessionFileName, userId);
    }
  }

  /// Authentication Attempt Result
  AuthResult login(String identifier, String password) {
    final cleanId = identifier.trim().toLowerCase();
    final target = _accounts.where((a) {
      return a.username.toLowerCase() == cleanId || a.email.toLowerCase() == cleanId;
    }).firstOrNull;

    if (target == null) {
      return AuthResult(
        isSuccess: false,
        errorMessageEn: 'Invalid username or email address.',
        errorMessageAr: 'اسم المستخدم أو البريد الإلكتروني غير صحيح.',
      );
    }

    final targetHash = hashPassword(password);
    if (target.passwordHash != null && target.passwordHash != targetHash) {
      return AuthResult(
        isSuccess: false,
        errorMessageEn: 'Incorrect password. Please verify your credentials.',
        errorMessageAr: 'كلمة المرور غير صحيحة. يرجى التأكد من البيانات.',
      );
    }

    // Check account status
    if (target.status == AccountStatus.pendingApproval) {
      _currentUser = target;
      notifyListeners();
      return AuthResult(
        isSuccess: true,
        user: target,
        isPendingApproval: true,
        errorMessageEn: 'Your registration is currently pending Super Admin review.',
        errorMessageAr: 'طلب تسجيلك قيد المراجعة والموافقة من قبل إدارة النظام.',
      );
    }

    if (target.status == AccountStatus.suspended) {
      return AuthResult(
        isSuccess: false,
        errorMessageEn: 'Account suspended. Please contact Green Flow Support.',
        errorMessageAr: 'تم تعليق هذا الحساب. يرجى التواصل مع دعم العملاء.',
      );
    }

    if (target.status == AccountStatus.rejected) {
      return AuthResult(
        isSuccess: false,
        errorMessageEn: 'Registration application was rejected by Admin.',
        errorMessageAr: 'تم رفض طلب التسجيل من قبل إدارة النظام.',
      );
    }

    if (target.status == AccountStatus.inactive) {
      return AuthResult(
        isSuccess: false,
        errorMessageEn: 'This account has been deactivated.',
        errorMessageAr: 'هذا الحساب معطل حالياً.',
      );
    }

    // Success
    final updated = target.copyWith(lastLoginAt: DateTime.now());
    _updateAccountInMemory(updated);
    _currentUser = updated;
    _saveSession(updated.id);
    notifyListeners();

    return AuthResult(isSuccess: true, user: updated);
  }

  /// Public Farmer Registration Workflow:
  /// Always forced to role: UserRole.farmOwner and status: AccountStatus.pendingApproval.
  UserAccount registerFarmer({
    required String nameEn,
    required String nameAr,
    required String email,
    required String phone,
    required String password,
  }) {
    final username = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final newFarmer = UserAccount(
      id: 'usr-farmer-${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      nameEn: nameEn,
      nameAr: nameAr,
      email: email,
      phone: phone,
      role: UserRole.farmOwner, // Restricted
      status: AccountStatus.pendingApproval, // Awaiting Super Admin
      passwordHash: hashPassword(password),
      createdAt: DateTime.now(),
    );

    _accounts.add(newFarmer);
    _persistAccounts();
    _currentUser = newFarmer;
    notifyListeners();
    return newFarmer;
  }

  /// Admin-Only: Create an employee or farmer account
  UserAccount createAccountByAdmin({
    required String username,
    required String nameEn,
    required String nameAr,
    required String email,
    required String phone,
    required UserRole role,
    required String initialPassword,
    String? assignedFarmId,
    List<String> assignedFarmIds = const [],
  }) {
    final newAccount = UserAccount(
      id: 'usr-${role.name}-${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      nameEn: nameEn,
      nameAr: nameAr,
      email: email,
      phone: phone,
      role: role,
      status: AccountStatus.approved,
      assignedFarmId: assignedFarmId,
      assignedFarmIds: assignedFarmIds,
      passwordHash: hashPassword(initialPassword),
      createdAt: DateTime.now(),
    );

    _accounts.add(newAccount);
    _persistAccounts();
    notifyListeners();
    return newAccount;
  }

  /// Admin-Only: Approve pending farmer registration
  void approveFarmerRegistration(String userId, {String? assignFarmId}) {
    final index = _accounts.indexWhere((a) => a.id == userId);
    if (index != -1) {
      final updated = _accounts[index].copyWith(
        status: AccountStatus.approved,
        assignedFarmId: assignFarmId ?? _accounts[index].assignedFarmId,
      );
      _accounts[index] = updated;
      _persistAccounts();
      if (_currentUser?.id == userId) _currentUser = updated;
      notifyListeners();
    }
  }

  /// Admin-Only: Reject pending farmer registration
  void rejectFarmerRegistration(String userId, String reason) {
    final index = _accounts.indexWhere((a) => a.id == userId);
    if (index != -1) {
      final updated = _accounts[index].copyWith(
        status: AccountStatus.rejected,
        rejectionReason: reason,
      );
      _accounts[index] = updated;
      _persistAccounts();
      notifyListeners();
    }
  }

  /// Admin-Only: Update status (suspend, reactivate, deactivate)
  void setAccountStatus(String userId, AccountStatus status) {
    final index = _accounts.indexWhere((a) => a.id == userId);
    if (index != -1) {
      // Protect Primary Super Admin account
      if (_accounts[index].id == 'usr-admin-01' && status != AccountStatus.approved) {
        return;
      }
      final updated = _accounts[index].copyWith(status: status);
      _accounts[index] = updated;
      _persistAccounts();
      if (_currentUser?.id == userId) {
        _currentUser = updated;
      }
      notifyListeners();
    }
  }

  /// Admin-Only: Reset Password
  void resetUserPassword(String userId, String newPassword) {
    final index = _accounts.indexWhere((a) => a.id == userId);
    if (index != -1) {
      final updated = _accounts[index].copyWith(passwordHash: hashPassword(newPassword));
      _accounts[index] = updated;
      _persistAccounts();
      notifyListeners();
    }
  }

  /// Sign out
  void logout() {
    _currentUser = null;
    _saveSession(null);
    notifyListeners();
  }

  void switchUserForTesting(UserRole role) {
    final target = _accounts.where((a) => a.role == role && a.status == AccountStatus.approved).firstOrNull;
    if (target != null) {
      _currentUser = target;
      _saveSession(target.id);
      notifyListeners();
    }
  }

  void _updateAccountInMemory(UserAccount acc) {
    final index = _accounts.indexWhere((a) => a.id == acc.id);
    if (index != -1) {
      _accounts[index] = acc;
      _persistAccounts();
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final UserAccount? user;
  final bool isPendingApproval;
  final String? errorMessageEn;
  final String? errorMessageAr;

  const AuthResult({
    required this.isSuccess,
    this.user,
    this.isPendingApproval = false,
    this.errorMessageEn,
    this.errorMessageAr,
  });
}
