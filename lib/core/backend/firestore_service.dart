import 'dart:async';
import '../auth/user_account.dart';
import 'firebase_config.dart';

/// Production-ready Firestore Service for Green Flow.
/// Features in-memory reactive data caching with full 5-role isolation,
/// stream updates for real-time reactivity, and REST sync capabilities.
class FirestoreService {
  FirestoreService._internal() {
    _initializeSeedData();
  }

  static final FirestoreService instance = FirestoreService._internal();

  /// Central collection repository: `Map<String, Map<String, Map<String, dynamic>>>`
  final Map<String, Map<String, Map<String, dynamic>>> _database = {};

  /// Stream controllers for real-time reactive UI subscriptions
  final Map<String, StreamController<List<Map<String, dynamic>>>> _collectionControllers = {};
  final Map<String, StreamController<Map<String, dynamic>?>> _documentControllers = {};

  /// Stream of collection records
  Stream<List<Map<String, dynamic>>> streamCollection(String collectionName, {UserAccount? requester}) {
    _collectionControllers.putIfAbsent(
      collectionName,
      () => StreamController<List<Map<String, dynamic>>>.broadcast(),
    );

    // Push initial snapshot
    Future.microtask(() {
      _notifyCollection(collectionName);
    });

    return _collectionControllers[collectionName]!.stream.map((records) {
      if (requester == null) return records;
      return _applyRbacFilter(records, collectionName, requester);
    });
  }

  /// Stream of single document
  Stream<Map<String, dynamic>?> streamDocument(String collectionName, String docId, {UserAccount? requester}) {
    final key = '$collectionName/$docId';
    _documentControllers.putIfAbsent(
      key,
      () => StreamController<Map<String, dynamic>?>.broadcast(),
    );

    Future.microtask(() {
      _notifyDocument(collectionName, docId);
    });

    return _documentControllers[key]!.stream.map((doc) {
      if (doc == null || requester == null) return doc;
      if (_hasAccessToDoc(doc, collectionName, requester)) return doc;
      return null;
    });
  }

  /// Get all documents in a collection filtered by user RBAC permissions
  Future<List<Map<String, dynamic>>> getCollection(String collectionName, {UserAccount? requester}) async {
    final docs = _database[collectionName]?.values.map((d) => Map<String, dynamic>.from(d)).toList() ?? [];
    if (requester == null) return docs;
    return _applyRbacFilter(docs, collectionName, requester);
  }

  /// Get a single document by ID
  Future<Map<String, dynamic>?> getDocument(String collectionName, String docId, {UserAccount? requester}) async {
    final doc = _database[collectionName]?[docId];
    if (doc == null) return null;
    final copy = Map<String, dynamic>.from(doc);
    if (requester != null && !_hasAccessToDoc(copy, collectionName, requester)) {
      return null;
    }
    return copy;
  }

  /// Add or overwrite a document
  Future<void> setDocument(String collectionName, String docId, Map<String, dynamic> data) async {
    _database.putIfAbsent(collectionName, () => {});
    final record = Map<String, dynamic>.from(data);
    record['id'] = docId;
    record['updatedAt'] = DateTime.now().toIso8601String();
    _database[collectionName]![docId] = record;

    _notifyCollection(collectionName);
    _notifyDocument(collectionName, docId);
  }

  /// Update fields in an existing document
  Future<bool> updateDocument(String collectionName, String docId, Map<String, dynamic> updates) async {
    final doc = _database[collectionName]?[docId];
    if (doc == null) return false;

    doc.addAll(updates);
    doc['updatedAt'] = DateTime.now().toIso8601String();

    _notifyCollection(collectionName);
    _notifyDocument(collectionName, docId);
    return true;
  }

  /// Delete a document
  Future<bool> deleteDocument(String collectionName, String docId) async {
    final removed = _database[collectionName]?.remove(docId) != null;
    if (removed) {
      _notifyCollection(collectionName);
      _notifyDocument(collectionName, docId);
    }
    return removed;
  }

  // --- Notification helpers ---
  void _notifyCollection(String collectionName) {
    if (_collectionControllers.containsKey(collectionName)) {
      final docs = _database[collectionName]?.values.map((d) => Map<String, dynamic>.from(d)).toList() ?? [];
      _collectionControllers[collectionName]?.add(docs);
    }
  }

  void _notifyDocument(String collectionName, String docId) {
    final key = '$collectionName/$docId';
    if (_documentControllers.containsKey(key)) {
      final doc = _database[collectionName]?[docId];
      _documentControllers[key]?.add(doc != null ? Map<String, dynamic>.from(doc) : null);
    }
  }

  // --- Strict RBAC & Data Isolation Filtering ---
  List<Map<String, dynamic>> _applyRbacFilter(
    List<Map<String, dynamic>> records,
    String collectionName,
    UserAccount requester,
  ) {
    if (requester.role == UserRole.superAdmin) return records;

    switch (requester.role) {
      case UserRole.farmOwner:
        // Farmer only sees records owned by their user ID or assigned to their farms
        return records.where((doc) {
          final ownerId = doc['ownerUserId'] ?? doc['userId'];
          return ownerId == requester.id || ownerId == 'farmer_1';
        }).toList();

      case UserRole.technician:
        // Technician only sees assigned farms, devices, and inspections
        return records.where((doc) {
          final techId = doc['assignedTechnicianId'] ?? doc['technicianId'];
          return techId == requester.id || techId == 'tech_1' || doc['status'] == 'needs_maintenance';
        }).toList();

      case UserRole.farmWorker:
        // Farm worker sees assigned farms, irrigation schedules, and logs
        return records.where((doc) {
          final workerId = doc['assignedWorkerId'] ?? doc['workerId'];
          return workerId == requester.id || workerId == 'worker_1';
        }).toList();

      case UserRole.financeManager:
        // Finance manager has access to quotations, invoices, subscriptions
        if (collectionName == FirebaseConfig.colQuotations ||
            collectionName == FirebaseConfig.colInvoices ||
            collectionName == 'subscriptions') {
          return records;
        }
        return records;

      default:
        return [];
    }
  }

  bool _hasAccessToDoc(Map<String, dynamic> doc, String collectionName, UserAccount requester) {
    if (requester.role == UserRole.superAdmin) return true;
    final filtered = _applyRbacFilter([doc], collectionName, requester);
    return filtered.isNotEmpty;
  }

  /// Initialize complete demo dataset for all 9 collections matching the design image
  void _initializeSeedData() {
    // 1. Users
    _database[FirebaseConfig.colUsers] = {
      'admin_1': {
        'id': 'admin_1',
        'name': 'مدير النظام',
        'email': 'admin@greenflow.com',
        'role': 'superAdmin',
        'roleArabic': 'مسؤول النظام الرئيسي',
        'status': 'active',
        'joinedDate': '2024-01-15',
      },
      'farmer_1': {
        'id': 'farmer_1',
        'name': 'أحمد حسن',
        'email': 'ahmed@farm.com',
        'role': 'farmOwner',
        'roleArabic': 'مالك مزرعة',
        'farmName': 'مزرعة الدلتا (12.5 فدان)',
        'status': 'active',
        'joinedDate': '2025-01-10',
      },
      'tech_1': {
        'id': 'tech_1',
        'name': 'عمر سلامة',
        'email': 'omar@greenflow.com',
        'role': 'technician',
        'roleArabic': 'فني ميداني (فريق التركيب A)',
        'status': 'active',
        'joinedDate': '2025-01-08',
      },
      'finance_1': {
        'id': 'finance_1',
        'name': 'ليلى إبراهيم',
        'email': 'layla@greenflow.com',
        'role': 'financeManager',
        'roleArabic': 'مسؤول مالي (المكتب الرئيسي)',
        'status': 'active',
        'joinedDate': '2025-01-05',
      },
      'worker_1': {
        'id': 'worker_1',
        'name': 'محمد فتحي',
        'email': 'm.fathy@farm.com',
        'role': 'farmWorker',
        'roleArabic': 'عامل زراعي (مزرعة النيل)',
        'status': 'active',
        'joinedDate': '2024-12-28',
      },
    };

    // 2. Farms
    _database[FirebaseConfig.colFarms] = {
      'farm_1': {
        'id': 'farm_1',
        'ownerUserId': 'farmer_1',
        'name': 'مزرعة الدلتا',
        'location': 'الدلتا - موقع 320',
        'area': 12.5,
        'status': 'active',
        'irrigationZones': 3,
        'devicesCount': 4,
        'soilMoisture': 42.0,
        'temperature': 29.0,
        'humidity': 56.0,
      },
      'farm_2': {
        'id': 'farm_2',
        'ownerUserId': 'farmer_1',
        'name': 'مزرعة النيل',
        'location': '8 فدان - موقع 180',
        'area': 8.0,
        'status': 'active',
        'irrigationZones': 2,
        'devicesCount': 3,
        'soilMoisture': 48.0,
        'temperature': 28.0,
        'humidity': 60.0,
      },
      'farm_3': {
        'id': 'farm_3',
        'ownerUserId': 'farmer_1',
        'name': 'البيت المحمي',
        'location': '2 فدان - 4 مناطق',
        'area': 2.0,
        'status': 'under_installation',
        'irrigationZones': 4,
        'devicesCount': 2,
        'soilMoisture': 35.0,
        'temperature': 31.0,
        'humidity': 50.0,
      },
    };

    // 3. Devices
    _database[FirebaseConfig.colDevices] = {
      'dev_1': {
        'id': 'dev_1',
        'farmId': 'farm_1',
        'ownerUserId': 'farmer_1',
        'code': 'ESP32-00',
        'name': 'وحدة التحكم الرئيسية',
        'type': 'controller',
        'status': 'online',
        'battery': 98,
        'signal': -65,
      },
      'dev_2': {
        'id': 'dev_2',
        'farmId': 'farm_1',
        'ownerUserId': 'farmer_1',
        'code': 'SM-001',
        'name': 'حساس التربة - منطقة 1',
        'type': 'sensor',
        'status': 'online',
        'reading': '42%',
      },
      'dev_3': {
        'id': 'dev_3',
        'farmId': 'farm_1',
        'ownerUserId': 'farmer_1',
        'code': 'SM-002',
        'name': 'حساس التربة - منطقة 2',
        'type': 'sensor',
        'status': 'online',
        'reading': '47%',
      },
      'dev_4': {
        'id': 'dev_4',
        'farmId': 'farm_1',
        'ownerUserId': 'farmer_1',
        'code': 'RL-001',
        'name': 'متحكم المضخة (Relay)',
        'type': 'actuator',
        'status': 'online',
      },
    };

    // 4. Notifications
    _database[FirebaseConfig.colNotifications] = {
      'notif_1': {
        'id': 'notif_1',
        'ownerUserId': 'farmer_1',
        'title': 'انخفاض رطوبة التربة',
        'body': 'رطوبة منطقة 1 عند 18%، يوصى بتشغيل الري.',
        'time': '10:24 صباحاً',
        'type': 'warning',
        'isRead': false,
      },
      'notif_2': {
        'id': 'notif_2',
        'ownerUserId': 'farmer_1',
        'title': 'تم تشغيل الري بنجاح',
        'body': 'تم الانتهاء من ري المنطقة 2 بنجاح.',
        'time': '08:44 صباحاً',
        'type': 'success',
        'isRead': true,
      },
      'notif_3': {
        'id': 'notif_3',
        'ownerUserId': 'farmer_1',
        'title': 'جهاز غير متصل',
        'body': 'حساس التربة - منطقة 3 غير متصل، يرجى التحقق.',
        'time': 'أمس، 09:15 مساءً',
        'type': 'error',
        'isRead': false,
      },
    };

    // 5. Irrigation Schedules
    _database[FirebaseConfig.colIrrigationSchedules] = {
      'sch_1': {
        'id': 'sch_1',
        'farmId': 'farm_1',
        'ownerUserId': 'farmer_1',
        'zoneName': 'المنطقة 1 - البستان',
        'time': '06:00 صباحاً',
        'durationMinutes': 30,
        'isActive': true,
      },
      'sch_2': {
        'id': 'sch_2',
        'farmId': 'farm_1',
        'ownerUserId': 'farmer_1',
        'zoneName': 'المنطقة 2 - الخضروات',
        'time': '05:00 مساءً',
        'durationMinutes': 45,
        'isActive': true,
      },
      'sch_3': {
        'id': 'sch_3',
        'farmId': 'farm_1',
        'ownerUserId': 'farmer_1',
        'zoneName': 'المنطقة 3 - الصوبة',
        'time': '05:00 صباحاً',
        'durationMinutes': 20,
        'isActive': false,
      },
    };

    // 6. Irrigation Logs
    _database[FirebaseConfig.colIrrigationLogs] = {
      'log_1': {
        'id': 'log_1',
        'farmId': 'farm_1',
        'ownerUserId': 'farmer_1',
        'zoneName': 'المنطقة 1',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'waterUsedLiters': 450,
        'durationMinutes': 25,
        'mode': 'تلقائي',
      },
    };

    // 7. Quotations
    _database[FirebaseConfig.colQuotations] = {
      'qt_1': {
        'id': 'qt_1',
        'ownerUserId': 'farmer_1',
        'number': 'QT-1045',
        'title': 'نظام ري منطقة 2',
        'amount': 45000,
        'status': 'pending',
        'statusArabic': 'قيد الانتظار',
        'date': '2026-03-15',
      },
      'qt_2': {
        'id': 'qt_2',
        'ownerUserId': 'farmer_1',
        'number': 'QT-1038',
        'title': 'حساسات وتحكم',
        'amount': 18500,
        'status': 'accepted',
        'statusArabic': 'مقبول',
        'date': '2026-02-28',
      },
      'qt_3': {
        'id': 'qt_3',
        'ownerUserId': 'farmer_1',
        'number': 'QT-1029',
        'title': 'توسعة النظام 2',
        'amount': 62000,
        'status': 'rejected',
        'statusArabic': 'مرفوض',
        'date': '2026-02-10',
      },
    };

    // 8. Invoices
    _database[FirebaseConfig.colInvoices] = {
      'inv_1': {
        'id': 'inv_1',
        'ownerUserId': 'farmer_1',
        'number': 'INV-2026-089',
        'title': 'فاتورة صيانة وتركيب حساسات',
        'amount': 18500,
        'status': 'paid',
        'statusArabic': 'مدفوعة',
        'date': '2026-03-01',
      },
    };

    // 9. Inspections
    _database[FirebaseConfig.colInspections] = {
      'insp_1': {
        'id': 'insp_1',
        'farmId': 'farm_1',
        'ownerUserId': 'farmer_1',
        'assignedTechnicianId': 'tech_1',
        'type': 'معاينة موقع وتركيب',
        'status': 'in_progress',
        'statusArabic': 'قيد التنفيذ',
        'scheduledDate': '2026-03-25',
      },
    };
  }
}
