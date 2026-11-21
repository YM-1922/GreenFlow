import 'package:flutter/material.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/auth/permission_service.dart';
import '../../../../core/auth/user_account.dart';
import '../../domain/entities/device_entities.dart';

/// In-memory reactive data source for ESP32 Gateways, wireless LoRa probes, and relay actuators.
class DevicesMockDataSource extends ChangeNotifier {
  static final DevicesMockDataSource _instance =
      DevicesMockDataSource._internal();

  factory DevicesMockDataSource() => _instance;

  DevicesMockDataSource._internal() {
    _initInitialData();
  }

  late List<Esp32DeviceEntity> _devices;

  void _initInitialData() {
    _devices = [
      Esp32DeviceEntity(
        id: 'dev-001',
        serialNumber: 'GF-ESP32-GW-2026-081',
        name: 'بوابة المزرعة الرئيسية ESP32 Industrial Gateway',
        category: DeviceCategory.centralGateway,
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        zoneId: 'all',
        zoneName: 'كافة القطاعات (Master Unit)',
        status: DeviceConnectionStatus.online,
        lastSeen: DateTime.now().subtract(const Duration(seconds: 45)),
        firmwareVersion: 'v2.4.1-GF-Solar',
        rssiSignalDbm: -62,
        batteryVoltage: 24.6,
        batteryPercent: 98,
        ipAddress: '192.168.1.150',
        macAddress: 'B4:E6:2D:18:A2:40',
        ambientTemperatureCelsius: 28.5,
        ambientHumidityPercent: 46.0,
      ),
      Esp32DeviceEntity(
        id: 'dev-006',
        serialNumber: 'GF-ESP32-GW-2026-094',
        name: 'بوابة واحة النخيل ESP32 Field Gateway',
        category: DeviceCategory.centralGateway,
        farmId: 'farm-002',
        farmName: 'واحة النخيل العضوي',
        zoneId: 'all',
        zoneName: 'كافة القطاعات',
        status: DeviceConnectionStatus.online,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
        firmwareVersion: 'v2.4.1-GF-Solar',
        rssiSignalDbm: -65,
        batteryVoltage: 24.2,
        batteryPercent: 95,
        ipAddress: '192.168.2.100',
        macAddress: 'C8:2B:96:10:E1:55',
        ambientTemperatureCelsius: 31.0,
        ambientHumidityPercent: 38.0,
      ),
      Esp32DeviceEntity(
        id: 'dev-002',
        serialNumber: 'GF-LORA-SOIL-01A',
        name: 'مجس LoRa اللاسلكي - قطاع الزيتون الشرقي',
        category: DeviceCategory.soilProbeNode,
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        zoneId: 'zone-001-a',
        zoneName: 'المنطقة أ - زيتون شرقي',
        status: DeviceConnectionStatus.online,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
        firmwareVersion: 'v1.8.0-Node',
        rssiSignalDbm: -74,
        batteryVoltage: 3.65,
        batteryPercent: 91,
        ipAddress: 'LoRa Ch:915MHz',
        macAddress: 'LoRa-Node-01A',
        soilMoistureTop25cm: 44.5,
        soilMoistureDeep50cm: 48.0,
        soilTemperatureCelsius: 22.4,
        soilSalinityEc: 1.15,
      ),
      Esp32DeviceEntity(
        id: 'dev-003',
        serialNumber: 'GF-LORA-SOIL-02B',
        name: 'مجس LoRa اللاسلكي - نخيل البرحي',
        category: DeviceCategory.soilProbeNode,
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        zoneId: 'zone-001-b',
        zoneName: 'المنطقة ب - نخيل البرحي',
        status: DeviceConnectionStatus.online,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 4)),
        firmwareVersion: 'v1.8.0-Node',
        rssiSignalDbm: -81,
        batteryVoltage: 3.58,
        batteryPercent: 86,
        ipAddress: 'LoRa Ch:915MHz',
        macAddress: 'LoRa-Node-02B',
        soilMoistureTop25cm: 39.0,
        soilMoistureDeep50cm: 41.5,
        soilTemperatureCelsius: 23.1,
        soilSalinityEc: 0.95,
      ),
      Esp32DeviceEntity(
        id: 'dev-004',
        serialNumber: 'GF-RELAY-MOD-8CH',
        name: 'وحدة التحكم بريليهات المحابس 8-Channel RS485',
        category: DeviceCategory.solenoidRelayModule,
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        zoneId: 'valves-bank',
        zoneName: 'مجمع المحابس الرئيسي',
        status: DeviceConnectionStatus.online,
        lastSeen: DateTime.now().subtract(const Duration(seconds: 20)),
        firmwareVersion: 'v1.2.4-Actuator',
        rssiSignalDbm: -58,
        batteryVoltage: 24.0,
        batteryPercent: 100,
        ipAddress: 'Modbus RTU Addr:1',
        macAddress: 'RS485-Bank-01',
      ),
      Esp32DeviceEntity(
        id: 'dev-005',
        serialNumber: 'GF-WATER-LVL-420MA',
        name: 'مستشعر منسوب مياه البئر الهيدروستاتيكي',
        category: DeviceCategory.waterLevelSensor,
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        zoneId: 'well-01',
        zoneName: 'بئر الأعماق #1',
        status: DeviceConnectionStatus.online,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
        firmwareVersion: 'v1.0.2',
        rssiSignalDbm: -65,
        batteryVoltage: 12.0,
        batteryPercent: 95,
        ipAddress: 'Analog 4-20mA',
        macAddress: 'Pressure-Transducer-01',
        waterLevelMeters: 42.5,
      ),
    ];
  }

  List<Esp32DeviceEntity> getDevices({UserAccount? user}) {
    final currentUser = user ?? AuthService().currentUser;
    if (currentUser == null || currentUser.role == UserRole.superAdmin) {
      return List.unmodifiable(_devices);
    }
    return List.unmodifiable(
      _devices.where((d) => PermissionService.canAccessDevice(currentUser, d.farmId)),
    );
  }

  Esp32DeviceEntity? getDeviceById(String id, {UserAccount? user}) {
    try {
      final dev = _devices.firstWhere((d) => d.id == id);
      final currentUser = user ?? AuthService().currentUser;
      if (currentUser != null && !PermissionService.canAccessDevice(currentUser, dev.farmId)) {
        return null; // Deny access
      }
      return dev;
    } catch (_) {
      return null;
    }
  }

  void registerDevice(Esp32DeviceEntity device) {
    _devices.insert(0, device);
    notifyListeners();
  }

  bool deleteDevice(String id) {
    final before = _devices.length;
    _devices.removeWhere((d) => d.id == id);
    if (_devices.length < before) {
      notifyListeners();
      return true;
    }
    return false;
  }

  void sendHardwarePing(String id) {
    final idx = _devices.indexWhere((d) => d.id == id);
    if (idx != -1) {
      _devices[idx] = _devices[idx].copyWith(
        lastSeen: DateTime.now(),
        status: DeviceConnectionStatus.online,
      );
      notifyListeners();
    }
  }
}
