import 'package:flutter/material.dart';
import '../../domain/entities/irrigation_entities.dart';

/// In-memory reactive data source for Smart Irrigation Control.
/// Manages live pump states, individual solenoid valves, timers, schedules, and emergency stops.
class IrrigationMockDataSource extends ChangeNotifier {
  static final IrrigationMockDataSource _instance =
      IrrigationMockDataSource._internal();

  factory IrrigationMockDataSource() => _instance;

  IrrigationMockDataSource._internal() {
    _initInitialData();
  }

  late PumpEntity _pump;
  late List<ZoneValveEntity> _valves;
  late List<IrrigationScheduleEntity> _schedules;
  late List<IrrigationHistoryRecordEntity> _history;
  late List<EmergencyStopRecordEntity> _emergencyStops;

  Duration? _activeTimerDuration;
  DateTime? _timerStartedAt;

  void _initInitialData() {
    // 1. Central Pump
    _pump = const PumpEntity(
      id: 'pump-01',
      name: 'طلمبة الأعماق الغاطسة 15 حصان (Solar Hybrid)',
      farmId: 'farm-001',
      farmName: 'مزرعة الأمل للزيتون والنخيل',
      state: PumpOperatingState.stopped,
      currentFlowRateLitersPerMinute: 0.0,
      linePressureBar: 3.8,
      runningDuration: Duration.zero,
      isAutomaticMode: true,
      isConnectedToHardware: false, // Simulated local demo
      powerConsumptionWatts: 0.0,
    );

    // 2. Zone Valves
    _valves = [
      const ZoneValveEntity(
        id: 'valve-01',
        zoneId: 'zone-001-a',
        zoneName: 'المنطقة أ - قطاع الزيتون الشرقي',
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل',
        isOpen: false,
        flowRateLpm: 60.0,
        requiredMoistureTarget: 45.0,
        currentMoisture: 42.5,
        valveNumber: 1,
      ),
      const ZoneValveEntity(
        id: 'valve-02',
        zoneId: 'zone-001-b',
        zoneName: 'المنطقة ب - نخيل البرحي المروي',
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل',
        isOpen: false,
        flowRateLpm: 80.0,
        requiredMoistureTarget: 40.0,
        currentMoisture: 38.0,
        valveNumber: 2,
      ),
      const ZoneValveEntity(
        id: 'valve-03',
        zoneId: 'zone-001-c',
        zoneName: 'المنطقة ج - حزام الموالح والليمون',
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل',
        isOpen: false,
        flowRateLpm: 45.0,
        requiredMoistureTarget: 45.0,
        currentMoisture: 44.0,
        valveNumber: 3,
      ),
      const ZoneValveEntity(
        id: 'valve-04',
        zoneId: 'zone-002-a',
        zoneName: 'قطاع المجدول النموذجي',
        farmId: 'farm-002',
        farmName: 'واحة النخيل العضوي',
        isOpen: false,
        flowRateLpm: 90.0,
        requiredMoistureTarget: 42.0,
        currentMoisture: 36.0,
        valveNumber: 4,
      ),
    ];

    // 3. Automated Schedules
    _schedules = [
      IrrigationScheduleEntity(
        id: 'sched-01',
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل',
        zoneId: 'zone-001-a',
        zoneName: 'المنطقة أ - زيتون شرقي',
        startTime: const TimeOfDay(hour: 5, minute: 30),
        durationMinutes: 45,
        daysOfWeek: const [1, 3, 5], // Sat, Mon, Wed
        isEnabled: true,
        nextRunTime: DateTime.now().add(const Duration(hours: 8)),
      ),
      IrrigationScheduleEntity(
        id: 'sched-02',
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل',
        zoneId: 'zone-001-b',
        zoneName: 'المنطقة ب - نخيل البرحي',
        startTime: const TimeOfDay(hour: 17, minute: 0),
        durationMinutes: 60,
        daysOfWeek: const [0, 2, 4], // Sun, Tue, Thu
        isEnabled: true,
        nextRunTime: DateTime.now().add(const Duration(hours: 19)),
      ),
      IrrigationScheduleEntity(
        id: 'sched-03',
        farmId: 'farm-002',
        farmName: 'واحة النخيل العضوي',
        zoneId: 'zone-002-a',
        zoneName: 'قطاع المجدول النموذجي',
        startTime: const TimeOfDay(hour: 6, minute: 0),
        durationMinutes: 90,
        daysOfWeek: const [1, 2, 4, 5],
        isEnabled: false,
      ),
    ];

    // 4. Past Operation History
    _history = [
      IrrigationHistoryRecordEntity(
        id: 'hist-01',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        zoneName: 'المنطقة أ - قطاع الزيتون الشرقي',
        startedAt: DateTime.now().subtract(const Duration(hours: 6)),
        endedAt: DateTime.now().subtract(const Duration(hours: 5, minutes: 15)),
        duration: const Duration(minutes: 45),
        waterConsumedLiters: 2700,
        isScheduled: true,
        isSuccess: true,
      ),
      IrrigationHistoryRecordEntity(
        id: 'hist-02',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        zoneName: 'المنطقة ب - نخيل البرحي المروي',
        startedAt: DateTime.now().subtract(const Duration(hours: 28)),
        endedAt: DateTime.now().subtract(const Duration(hours: 27)),
        duration: const Duration(minutes: 60),
        waterConsumedLiters: 4800,
        isScheduled: true,
        isSuccess: true,
      ),
      IrrigationHistoryRecordEntity(
        id: 'hist-03',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        zoneName: 'المنطقة ج - حزام الموالح والليمون',
        startedAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
        endedAt:
            DateTime.now().subtract(const Duration(days: 2, hours: 3, minutes: 30)),
        duration: const Duration(minutes: 30),
        waterConsumedLiters: 1350,
        isScheduled: false,
        isSuccess: true,
      ),
    ];

    _emergencyStops = [];
  }

  // --- Getters ---
  PumpEntity get pump => _pump;
  List<ZoneValveEntity> get valves => List.unmodifiable(_valves);
  List<IrrigationScheduleEntity> get schedules =>
      List.unmodifiable(_schedules);
  List<IrrigationHistoryRecordEntity> get history =>
      List.unmodifiable(_history);
  List<EmergencyStopRecordEntity> get emergencyStops =>
      List.unmodifiable(_emergencyStops);
  Duration? get activeTimerDuration => _activeTimerDuration;
  DateTime? get timerStartedAt => _timerStartedAt;

  // --- Pump Actions ---

  void setAutomaticMode(bool isAuto) {
    _pump = _pump.copyWith(isAutomaticMode: isAuto);
    notifyListeners();
  }

  void startPump() {
    if (_pump.state == PumpOperatingState.emergencyStopped) return;

    // Safety Interlock: Ensure at least one valve is open before pump start
    final anyValveOpen = _valves.any((v) => v.isOpen);
    if (!anyValveOpen && _valves.isNotEmpty) {
      _valves[0] = _valves[0].copyWith(isOpen: true);
    }

    _pump = _pump.copyWith(
      state: PumpOperatingState.running,
      currentFlowRateLitersPerMinute: 75.0,
      powerConsumptionWatts: 4200.0,
      lastStartedAt: DateTime.now(),
      runningDuration: Duration.zero,
    );
    notifyListeners();
  }

  void stopPump({String? reason}) {
    if (_pump.isRunning) {
      final now = DateTime.now();
      final duration = _pump.lastStartedAt != null
          ? now.difference(_pump.lastStartedAt!)
          : const Duration(minutes: 15);

      // Record in history
      _history.insert(
        0,
        IrrigationHistoryRecordEntity(
          id: 'hist-${now.millisecondsSinceEpoch}',
          farmName: _pump.farmName,
          zoneName: _valves.firstWhere((v) => v.isOpen, orElse: () => _valves[0]).zoneName,
          startedAt: _pump.lastStartedAt ?? now.subtract(duration),
          endedAt: now,
          duration: duration,
          waterConsumedLiters: (_pump.currentFlowRateLitersPerMinute * duration.inMinutes).clamp(100.0, 15000.0),
          isScheduled: false,
          isSuccess: true,
          terminationReason: reason,
        ),
      );
    }

    // Close open valves
    for (int i = 0; i < _valves.length; i++) {
      if (_valves[i].isOpen) {
        _valves[i] = _valves[i].copyWith(isOpen: false);
      }
    }

    _pump = _pump.copyWith(
      state: PumpOperatingState.stopped,
      currentFlowRateLitersPerMinute: 0.0,
      powerConsumptionWatts: 0.0,
      lastStoppedAt: DateTime.now(),
    );
    _activeTimerDuration = null;
    _timerStartedAt = null;

    notifyListeners();
  }

  // --- Valve Actions ---

  void toggleValve(String valveId, bool open) {
    final index = _valves.indexWhere((v) => v.id == valveId);
    if (index != -1) {
      _valves[index] = _valves[index].copyWith(isOpen: open);

      // If pump is running and all valves are closed, stop the pump for dead-head protection
      final anyOpen = _valves.any((v) => v.isOpen);
      if (_pump.isRunning && !anyOpen) {
        stopPump(reason: 'Deadhead protection: All valves closed');
      }

      notifyListeners();
    }
  }

  // --- Timer Actions ---

  void startTimer(Duration duration) {
    _activeTimerDuration = duration;
    _timerStartedAt = DateTime.now();
    startPump();
  }

  void cancelTimer() {
    stopPump(reason: 'Timer cancelled by operator');
  }

  // --- Emergency Stop ---

  void triggerEmergencyStop({String reason = 'Manual Safety E-Stop by Farmer'}) {
    final now = DateTime.now();
    final openValvesNames =
        _valves.where((v) => v.isOpen).map((v) => v.zoneName).toList();

    // Force close all valves immediately
    for (int i = 0; i < _valves.length; i++) {
      _valves[i] = _valves[i].copyWith(isOpen: false);
    }

    _pump = _pump.copyWith(
      state: PumpOperatingState.emergencyStopped,
      currentFlowRateLitersPerMinute: 0.0,
      powerConsumptionWatts: 0.0,
      lastStoppedAt: now,
    );

    _activeTimerDuration = null;
    _timerStartedAt = null;

    _emergencyStops.insert(
      0,
      EmergencyStopRecordEntity(
        id: 'estop-${now.millisecondsSinceEpoch}',
        timestamp: now,
        operatorName: 'م. أحمد المنشاوي',
        reason: reason,
        haltedValves: openValvesNames,
      ),
    );

    notifyListeners();
  }

  void resetEmergencyStop() {
    if (_pump.state == PumpOperatingState.emergencyStopped) {
      _pump = _pump.copyWith(state: PumpOperatingState.stopped);
      notifyListeners();
    }
  }

  // --- Schedule Actions ---

  void addSchedule(IrrigationScheduleEntity schedule) {
    _schedules.insert(0, schedule);
    notifyListeners();
  }

  void updateSchedule(IrrigationScheduleEntity schedule) {
    final idx = _schedules.indexWhere((s) => s.id == schedule.id);
    if (idx != -1) {
      _schedules[idx] = schedule;
      notifyListeners();
    }
  }

  void deleteSchedule(String id) {
    _schedules.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void toggleScheduleEnabled(String id, bool enabled) {
    final idx = _schedules.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _schedules[idx] = _schedules[idx].copyWith(isEnabled: enabled);
      notifyListeners();
    }
  }
}
