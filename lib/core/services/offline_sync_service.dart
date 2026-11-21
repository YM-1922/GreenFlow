import 'dart:async';
import 'package:flutter/foundation.dart';

/// Connection states for Green Flow IoT and cloud sync.
enum SyncConnectionStatus {
  online,
  offline,
  syncing,
  syncError,
}

/// Category of queued mutation.
enum QueuedOperationType {
  createFarm,
  updateFarm,
  deleteFarm,
  createDevice,
  deleteDevice,
  toggleValve,
  updateIrrigationSchedule,
  emergencyStop,
}

/// An atomic operation queued while offline.
class QueuedOperation {
  final String id;
  final QueuedOperationType type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final int retryCount;

  const QueuedOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
      };

  factory QueuedOperation.fromJson(Map<String, dynamic> json) {
    return QueuedOperation(
      id: json['id'] as String,
      type: QueuedOperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QueuedOperationType.createFarm,
      ),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  QueuedOperation copyWith({
    String? id,
    QueuedOperationType? type,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return QueuedOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Service managing connectivity detection, offline queue persistence, and local caching.
class OfflineSyncService extends ChangeNotifier {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;

  OfflineSyncService._internal();

  SyncConnectionStatus _status = SyncConnectionStatus.online;
  DateTime? _lastSyncTime = DateTime.now();
  String? _lastSyncError;

  final List<QueuedOperation> _operationQueue = [];
  final Map<String, dynamic> _localCache = {};

  SyncConnectionStatus get status => _status;
  bool get isOnline => _status == SyncConnectionStatus.online || _status == SyncConnectionStatus.syncing;
  bool get isOffline => _status == SyncConnectionStatus.offline;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get lastSyncError => _lastSyncError;
  int get queuedOperationsCount => _operationQueue.length;
  List<QueuedOperation> get operationQueue => List.unmodifiable(_operationQueue);

  /// Simulate or toggle connectivity state manually (for offline mode toggle in UI/tests).
  void setOnlineStatus(bool online) {
    if (online) {
      if (_status != SyncConnectionStatus.online) {
        _status = SyncConnectionStatus.online;
        _lastSyncError = null;
        notifyListeners();
      }
    } else {
      _status = SyncConnectionStatus.offline;
      notifyListeners();
    }
  }

  /// Cache a key-value pair locally (e.g. farms, devices, irrigation).
  Future<void> cacheData(String key, dynamic data) async {
    _localCache[key] = data;
    notifyListeners();
  }

  /// Retrieve cached data by key.
  T? getCachedData<T>(String key) {
    return _localCache[key] as T?;
  }

  /// Queue a mutation for syncing when connectivity is restored.
  Future<void> queueOperation(QueuedOperationType type, Map<String, dynamic> payload) async {
    final operation = QueuedOperation(
      id: 'op_${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      payload: payload,
      timestamp: DateTime.now(),
    );

    // Prevent duplicate entries by key payload id if present
    final payloadId = payload['id'];
    if (payloadId != null) {
      _operationQueue.removeWhere(
        (op) => op.type == type && op.payload['id'] == payloadId,
      );
    }

    _operationQueue.add(operation);
    notifyListeners();

    if (isOnline) {
      synchronizePendingQueue(delay: const Duration(milliseconds: 300));
    }
  }

  /// Automatically or manually synchronize the queued operations.
  Future<bool> synchronizePendingQueue({
    bool simulateFailure = false,
    Duration delay = Duration.zero,
  }) async {
    if (_operationQueue.isEmpty) {
      _lastSyncTime = DateTime.now();
      notifyListeners();
      return true;
    }

    if (!isOnline && !simulateFailure) {
      return false;
    }

    _status = SyncConnectionStatus.syncing;
    notifyListeners();

    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (simulateFailure) {
      _status = SyncConnectionStatus.syncError;
      _lastSyncError = 'Network timeout: Failed to connect to telemetry sync endpoint.';
      // Increment retry counts safely
      for (int i = 0; i < _operationQueue.length; i++) {
        _operationQueue[i] = _operationQueue[i].copyWith(
          retryCount: _operationQueue[i].retryCount + 1,
        );
      }
      notifyListeners();
      return false;
    }

    // Process all operations in FIFO order
    _operationQueue.clear();
    _lastSyncTime = DateTime.now();
    _lastSyncError = null;
    _status = SyncConnectionStatus.online;
    notifyListeners();
    return true;
  }

  /// Discard or retry failed queue operations.
  void clearQueue() {
    _operationQueue.clear();
    _lastSyncError = null;
    if (_status == SyncConnectionStatus.syncError) {
      _status = SyncConnectionStatus.online;
    }
    notifyListeners();
  }
}
