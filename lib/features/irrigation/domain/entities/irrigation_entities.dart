import 'package:flutter/material.dart';

/// Current operating state of the central irrigation pump.
enum PumpOperatingState {
  stopped,
  running,
  emergencyStopped,
  dryRunProtection,
  lowWaterCutoff;

  String labelEn() {
    switch (this) {
      case PumpOperatingState.stopped:
        return 'Pump Idle / Ready';
      case PumpOperatingState.running:
        return 'Pump Active';
      case PumpOperatingState.emergencyStopped:
        return 'Emergency Stop Engaged';
      case PumpOperatingState.dryRunProtection:
        return 'Dry-Run Protection Active';
      case PumpOperatingState.lowWaterCutoff:
        return 'Low Well Level Lockout';
    }
  }

  String labelAr() {
    switch (this) {
      case PumpOperatingState.stopped:
        return 'المضخة متوقفة / جاهزة';
      case PumpOperatingState.running:
        return 'المضخة تعمل الآن';
      case PumpOperatingState.emergencyStopped:
        return 'إيقاف طوارئ مفعل';
      case PumpOperatingState.dryRunProtection:
        return 'حماية التشغيل الجاف مفعلة';
      case PumpOperatingState.lowWaterCutoff:
        return 'إغلاق لانخفاض منسوب المياه';
    }
  }

  Color color() {
    switch (this) {
      case PumpOperatingState.stopped:
        return const Color(0xFF64748B); // Slate
      case PumpOperatingState.running:
        return const Color(0xFF10B981); // Emerald
      case PumpOperatingState.emergencyStopped:
      case PumpOperatingState.dryRunProtection:
      case PumpOperatingState.lowWaterCutoff:
        return const Color(0xFFEF4444); // Red Alert
    }
  }
}

/// Central irrigation pump entity.
class PumpEntity {
  final String id;
  final String name;
  final String farmId;
  final String farmName;
  final PumpOperatingState state;
  final double currentFlowRateLitersPerMinute;
  final double linePressureBar;
  final Duration runningDuration;
  final DateTime? lastStartedAt;
  final DateTime? lastStoppedAt;
  final bool isAutomaticMode;
  final bool isConnectedToHardware;
  final double powerConsumptionWatts;

  const PumpEntity({
    required this.id,
    required this.name,
    required this.farmId,
    required this.farmName,
    this.state = PumpOperatingState.stopped,
    this.currentFlowRateLitersPerMinute = 0.0,
    this.linePressureBar = 0.0,
    this.runningDuration = Duration.zero,
    this.lastStartedAt,
    this.lastStoppedAt,
    this.isAutomaticMode = true,
    this.isConnectedToHardware = false,
    this.powerConsumptionWatts = 0.0,
  });

  bool get isRunning => state == PumpOperatingState.running;

  PumpEntity copyWith({
    String? id,
    String? name,
    String? farmId,
    String? farmName,
    PumpOperatingState? state,
    double? currentFlowRateLitersPerMinute,
    double? linePressureBar,
    Duration? runningDuration,
    DateTime? lastStartedAt,
    DateTime? lastStoppedAt,
    bool? isAutomaticMode,
    bool? isConnectedToHardware,
    double? powerConsumptionWatts,
  }) {
    return PumpEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      state: state ?? this.state,
      currentFlowRateLitersPerMinute:
          currentFlowRateLitersPerMinute ?? this.currentFlowRateLitersPerMinute,
      linePressureBar: linePressureBar ?? this.linePressureBar,
      runningDuration: runningDuration ?? this.runningDuration,
      lastStartedAt: lastStartedAt ?? this.lastStartedAt,
      lastStoppedAt: lastStoppedAt ?? this.lastStoppedAt,
      isAutomaticMode: isAutomaticMode ?? this.isAutomaticMode,
      isConnectedToHardware:
          isConnectedToHardware ?? this.isConnectedToHardware,
      powerConsumptionWatts:
          powerConsumptionWatts ?? this.powerConsumptionWatts,
    );
  }
}

/// Individual zone solenoid valve entity.
class ZoneValveEntity {
  final String id;
  final String zoneId;
  final String zoneName;
  final String farmId;
  final String farmName;
  final bool isOpen;
  final double flowRateLpm;
  final double requiredMoistureTarget;
  final double currentMoisture;
  final int valveNumber;

  const ZoneValveEntity({
    required this.id,
    required this.zoneId,
    required this.zoneName,
    required this.farmId,
    required this.farmName,
    this.isOpen = false,
    this.flowRateLpm = 45.0,
    this.requiredMoistureTarget = 45.0,
    this.currentMoisture = 38.5,
    required this.valveNumber,
  });

  ZoneValveEntity copyWith({
    String? id,
    String? zoneId,
    String? zoneName,
    String? farmId,
    String? farmName,
    bool? isOpen,
    double? flowRateLpm,
    double? requiredMoistureTarget,
    double? currentMoisture,
    int? valveNumber,
  }) {
    return ZoneValveEntity(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      isOpen: isOpen ?? this.isOpen,
      flowRateLpm: flowRateLpm ?? this.flowRateLpm,
      requiredMoistureTarget:
          requiredMoistureTarget ?? this.requiredMoistureTarget,
      currentMoisture: currentMoisture ?? this.currentMoisture,
      valveNumber: valveNumber ?? this.valveNumber,
    );
  }
}

/// Automated irrigation schedule entity.
class IrrigationScheduleEntity {
  final String id;
  final String farmId;
  final String farmName;
  final String zoneId;
  final String zoneName;
  final TimeOfDay startTime;
  final int durationMinutes;
  final List<int> daysOfWeek; // 1 = Mon, 7 = Sun (or Sat-Fri representation)
  final bool isEnabled;
  final DateTime? nextRunTime;

  const IrrigationScheduleEntity({
    required this.id,
    required this.farmId,
    required this.farmName,
    required this.zoneId,
    required this.zoneName,
    required this.startTime,
    required this.durationMinutes,
    required this.daysOfWeek,
    this.isEnabled = true,
    this.nextRunTime,
  });

  IrrigationScheduleEntity copyWith({
    String? id,
    String? farmId,
    String? farmName,
    String? zoneId,
    String? zoneName,
    TimeOfDay? startTime,
    int? durationMinutes,
    List<int>? daysOfWeek,
    bool? isEnabled,
    DateTime? nextRunTime,
  }) {
    return IrrigationScheduleEntity(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isEnabled: isEnabled ?? this.isEnabled,
      nextRunTime: nextRunTime ?? this.nextRunTime,
    );
  }
}

/// Historical record of completed or stopped irrigation operations.
class IrrigationHistoryRecordEntity {
  final String id;
  final String farmName;
  final String zoneName;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;
  final double waterConsumedLiters;
  final bool isScheduled;
  final bool isSuccess;
  final String? terminationReason;

  const IrrigationHistoryRecordEntity({
    required this.id,
    required this.farmName,
    required this.zoneName,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    required this.waterConsumedLiters,
    required this.isScheduled,
    required this.isSuccess,
    this.terminationReason,
  });
}

/// Emergency Stop event record.
class EmergencyStopRecordEntity {
  final String id;
  final DateTime timestamp;
  final String operatorName;
  final String reason;
  final List<String> haltedValves;

  const EmergencyStopRecordEntity({
    required this.id,
    required this.timestamp,
    required this.operatorName,
    required this.reason,
    required this.haltedValves,
  });
}
