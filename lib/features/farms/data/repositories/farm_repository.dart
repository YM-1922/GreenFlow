import '../../domain/entities/farm_entities.dart';
import '../datasources/farms_mock_data_source.dart';

/// Clean Architecture Repository interface and implementation for Farms & Inspections.
abstract class FarmRepository {
  Future<List<FarmEntity>> getFarms();
  Future<FarmEntity?> getFarmById(String id);
  Future<void> saveFarm(FarmEntity farm);
  Future<bool> deleteFarm(String farmId);
  Future<void> saveZone(String farmId, IrrigationZoneEntity zone);
  Future<void> deleteZone(String farmId, String zoneId);
  Future<List<FarmInspectionRequestEntity>> getInspectionRequests();
  Future<FarmInspectionRequestEntity?> getInspectionRequestById(String id);
  Future<void> submitInspectionRequest(FarmInspectionRequestEntity request);
}

class FarmRepositoryImpl implements FarmRepository {
  final FarmsMockDataSource _dataSource;

  FarmRepositoryImpl({FarmsMockDataSource? dataSource})
      : _dataSource = dataSource ?? FarmsMockDataSource();

  @override
  Future<List<FarmEntity>> getFarms() async {
    return _dataSource.getFarms();
  }

  @override
  Future<FarmEntity?> getFarmById(String id) async {
    return _dataSource.getFarmById(id);
  }

  @override
  Future<void> saveFarm(FarmEntity farm) async {
    final existing = _dataSource.getFarmById(farm.id);
    if (existing != null) {
      _dataSource.updateFarm(farm);
    } else {
      _dataSource.addFarm(farm);
    }
  }

  @override
  Future<bool> deleteFarm(String farmId) async {
    return _dataSource.deleteFarm(farmId);
  }

  @override
  Future<void> saveZone(String farmId, IrrigationZoneEntity zone) async {
    final farm = _dataSource.getFarmById(farmId);
    if (farm != null) {
      final exists = farm.zones.any((z) => z.id == zone.id);
      if (exists) {
        _dataSource.updateZone(farmId, zone);
      } else {
        _dataSource.addZone(farmId, zone);
      }
    }
  }

  @override
  Future<void> deleteZone(String farmId, String zoneId) async {
    _dataSource.deleteZone(farmId, zoneId);
  }

  @override
  Future<List<FarmInspectionRequestEntity>> getInspectionRequests() async {
    return _dataSource.getInspectionRequests();
  }

  @override
  Future<FarmInspectionRequestEntity?> getInspectionRequestById(String id) async {
    return _dataSource.getInspectionRequestById(id);
  }

  @override
  Future<void> submitInspectionRequest(FarmInspectionRequestEntity request) async {
    _dataSource.submitInspectionRequest(request);
  }
}
