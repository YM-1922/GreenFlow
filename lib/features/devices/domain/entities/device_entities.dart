import 'package:flutter/material.dart';

/// Connection and heartbeat status of an ESP32 or IoT node.
enum DeviceConnectionStatus {
  online,
  offline,
  syncing,
  warning;

  String labelEn() {
    switch (this) {
      case DeviceConnectionStatus.online:
        return 'Online / Active';
      case DeviceConnectionStatus.offline:
        return 'Offline';
      case DeviceConnectionStatus.syncing:
        return 'Syncing Telemetry';
      case DeviceConnectionStatus.warning:
        return 'Hardware Alert';
    }
  }

  String labelAr() {
    switch (this) {
      case DeviceConnectionStatus.online:
        return 'متصل ونشط';
      case DeviceConnectionStatus.offline:
        return 'غير متصل';
      case DeviceConnectionStatus.syncing:
        return 'جاري المزامنة';
      case DeviceConnectionStatus.warning:
        return 'تنبيه عتاد';
    }
  }

  Color color() {
    switch (this) {
      case DeviceConnectionStatus.online:
        return const Color(0xFF10B981); // Emerald
      case DeviceConnectionStatus.offline:
        return const Color(0xFF94A3B8); // Slate
      case DeviceConnectionStatus.syncing:
        return const Color(0xFF0284C7); // Blue
      case DeviceConnectionStatus.warning:
        return const Color(0xFFF59E0B); // Amber
    }
  }
}

/// Category of IoT Device.
enum DeviceCategory {
  centralGateway,
  soilProbeNode,
  solenoidRelayModule,
  weatherStation,
  waterLevelSensor;

  String labelEn() {
    switch (this) {
      case DeviceCategory.centralGateway:
        return 'Central ESP32 Gateway';
      case DeviceCategory.soilProbeNode:
        return 'LoRa Soil Moisture Probe';
      case DeviceCategory.solenoidRelayModule:
        return 'Relay Actuator Module';
      case DeviceCategory.weatherStation:
        return 'Agro Weather Station';
      case DeviceCategory.waterLevelSensor:
        return 'Well Level Sensor';
    }
  }

  String labelAr() {
    switch (this) {
      case DeviceCategory.centralGateway:
        return 'بوابة ESP32 المركزية';
      case DeviceCategory.soilProbeNode:
        return 'مجس LoRa لرطوبة وملوحة التربة';
      case DeviceCategory.solenoidRelayModule:
        return 'وحدة ريليه تشغيل المحابس';
      case DeviceCategory.weatherStation:
        return 'محطة رصد جوي زراعية';
      case DeviceCategory.waterLevelSensor:
        return 'مستشعر منسوب مياه البئر';
    }
  }

  IconData icon() {
    switch (this) {
      case DeviceCategory.centralGateway:
        return Icons.hub_rounded;
      case DeviceCategory.soilProbeNode:
        return Icons.grass_rounded;
      case DeviceCategory.solenoidRelayModule:
        return Icons.tune_rounded;
      case DeviceCategory.weatherStation:
        return Icons.cloud_queue_rounded;
      case DeviceCategory.waterLevelSensor:
        return Icons.waves_rounded;
    }
  }
}

/// ESP32 / IoT Device Entity.
class Esp32DeviceEntity {
  final String id;
  final String serialNumber;
  final String name;
  final DeviceCategory category;
  final String farmId;
  final String farmName;
  final String zoneId;
  final String zoneName;
  final DeviceConnectionStatus status;
  final DateTime lastSeen;
  final String firmwareVersion;
  final int rssiSignalDbm; // e.g. -65 dBm
  final double batteryVoltage; // e.g. 3.7V / 12.6V
  final int batteryPercent; // e.g. 92%
  final String ipAddress;
  final String macAddress;

  // Live telemetry readings
  final double? soilMoistureTop25cm;
  final double? soilMoistureDeep50cm;
  final double? soilTemperatureCelsius;
  final double? ambientTemperatureCelsius;
  final double? ambientHumidityPercent;
  final double? waterLevelMeters;
  final double? soilSalinityEc;

  const Esp32DeviceEntity({
    required this.id,
    required this.serialNumber,
    required this.name,
    required this.category,
    required this.farmId,
    required this.farmName,
    required this.zoneId,
    required this.zoneName,
    this.status = DeviceConnectionStatus.online,
    required this.lastSeen,
    this.firmwareVersion = 'v2.4.1-GF-Solar',
    this.rssiSignalDbm = -68,
    this.batteryVoltage = 12.8,
    this.batteryPercent = 94,
    this.ipAddress = '192.168.1.140',
    this.macAddress = '24:6F:28:B4:7C:90',
    this.soilMoistureTop25cm,
    this.soilMoistureDeep50cm,
    this.soilTemperatureCelsius,
    this.ambientTemperatureCelsius,
    this.ambientHumidityPercent,
    this.waterLevelMeters,
    this.soilSalinityEc,
  });

  Esp32DeviceEntity copyWith({
    String? id,
    String? serialNumber,
    String? name,
    DeviceCategory? category,
    String? farmId,
    String? farmName,
    String? zoneId,
    String? zoneName,
    DeviceConnectionStatus? status,
    DateTime? lastSeen,
    String? firmwareVersion,
    int? rssiSignalDbm,
    double? batteryVoltage,
    int? batteryPercent,
    String? ipAddress,
    String? macAddress,
    double? soilMoistureTop25cm,
    double? soilMoistureDeep50cm,
    double? soilTemperatureCelsius,
    double? ambientTemperatureCelsius,
    double? ambientHumidityPercent,
    double? waterLevelMeters,
    double? soilSalinityEc,
  }) {
    return Esp32DeviceEntity(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      name: name ?? this.name,
      category: category ?? this.category,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      rssiSignalDbm: rssiSignalDbm ?? this.rssiSignalDbm,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      soilMoistureTop25cm: soilMoistureTop25cm ?? this.soilMoistureTop25cm,
      soilMoistureDeep50cm: soilMoistureDeep50cm ?? this.soilMoistureDeep50cm,
      soilTemperatureCelsius:
          soilTemperatureCelsius ?? this.soilTemperatureCelsius,
      ambientTemperatureCelsius:
          ambientTemperatureCelsius ?? this.ambientTemperatureCelsius,
      ambientHumidityPercent:
          ambientHumidityPercent ?? this.ambientHumidityPercent,
      waterLevelMeters: waterLevelMeters ?? this.waterLevelMeters,
      soilSalinityEc: soilSalinityEc ?? this.soilSalinityEc,
    );
  }
}
