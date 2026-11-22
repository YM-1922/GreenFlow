import '../../../../core/auth/auth_service.dart';
import '../../../../core/auth/permission_service.dart';
import '../../../../core/auth/user_account.dart';
import '../../domain/entities/farm_entities.dart';

/// In-memory mock data source for Farm Management and Inspection Requests.
/// Structured to be seamlessly swappable with a future REST / GraphQL API repository.
class FarmsMockDataSource {
  static final FarmsMockDataSource _instance = FarmsMockDataSource._internal();

  factory FarmsMockDataSource() => _instance;

  FarmsMockDataSource._internal() {
    _initInitialData();
  }

  late List<FarmEntity> _farms;
  late List<FarmInspectionRequestEntity> _inspectionRequests;

  void _initInitialData() {
    // 1. Initial Farms
    _farms = [
      FarmEntity(
        id: 'farm-001',
        ownerUserId: 'usr-farmer-01',
        name: 'مزرعة الأمل للزيتون والنخيل',
        location: 'وادي النطرون، البحيرة (Wadi El Natrun)',
        area: 45.0,
        areaUnit: AreaUnit.feddan,
        treesCount: 2400,
        crops: ['زيتون كالماتا', 'نخيل برحي', 'موالح'],
        irrigationType: IrrigationType.drip,
        waterSource: FarmWaterSource.deepWell,
        healthStatus: FarmHealthStatus.excellent,
        installationStatus: InstallationStatus.activeMonitoring,
        hasSolarPower: true,
        notes:
            'تربة رملية طميية عالية النفاذية، مجهزة بطاقة شمسية ومستشعرات رطوبة عند أعماق 25 و50 سم.',
        createdAt: DateTime(2026, 1, 15),
        zones: [
          const IrrigationZoneEntity(
            id: 'zone-001-a',
            farmId: 'farm-001',
            name: 'المنطقة أ - قطاع الزيتون الشرقي',
            area: 18.0,
            cropType: 'زيتون كالماتا',
            treesCount: 1100,
            waterRequirementLitersPerDay: 4800,
            soilMoisturePercentage: 44.5,
            valveCount: 2,
            sensorNodesCount: 4,
            isActive: true,
          ),
          const IrrigationZoneEntity(
            id: 'zone-001-b',
            farmId: 'farm-001',
            name: 'المنطقة ب - نخيل البرحي المروي',
            area: 15.0,
            cropType: 'نخيل برحي',
            treesCount: 750,
            waterRequirementLitersPerDay: 6200,
            soilMoisturePercentage: 39.0,
            valveCount: 3,
            sensorNodesCount: 3,
            isActive: true,
          ),
          const IrrigationZoneEntity(
            id: 'zone-001-c',
            farmId: 'farm-001',
            name: 'المنطقة ج - حزام الموالح والليمون',
            area: 12.0,
            cropType: 'موالح متنوعة',
            treesCount: 550,
            waterRequirementLitersPerDay: 3100,
            soilMoisturePercentage: 42.0,
            valveCount: 2,
            sensorNodesCount: 2,
            isActive: true,
          ),
        ],
      ),
      FarmEntity(
        id: 'farm-002',
        ownerUserId: 'usr-farmer-03',
        name: 'واحة النخيل العضوي',
        location: 'توشكى - شرق العوينات (Toshka)',
        area: 80.0,
        areaUnit: AreaUnit.feddan,
        treesCount: 3800,
        crops: ['نخيل مجدول', 'برسيم حجازي'],
        irrigationType: IrrigationType.drip,
        waterSource: FarmWaterSource.deepWell,
        healthStatus: FarmHealthStatus.good,
        installationStatus: InstallationStatus.quotationReady,
        hasSolarPower: true,
        notes:
            'مشروع زراعي واعد لإنتاج تمور المجدول للتصدير، تم فحص التربة وإعداد مقايسة المحابس الذكية.',
        createdAt: DateTime(2026, 3, 10),
        zones: [
          const IrrigationZoneEntity(
            id: 'zone-002-a',
            farmId: 'farm-002',
            name: 'قطاع المجدول النموذجي',
            area: 50.0,
            cropType: 'نخيل مجدول',
            treesCount: 2600,
            waterRequirementLitersPerDay: 14500,
            soilMoisturePercentage: 36.2,
            valveCount: 5,
            sensorNodesCount: 6,
            isActive: true,
          ),
          const IrrigationZoneEntity(
            id: 'zone-002-b',
            farmId: 'farm-002',
            name: 'حقل البرسيم الحجازي المروي',
            area: 30.0,
            cropType: 'برسيم حجازي',
            treesCount: 1200,
            waterRequirementLitersPerDay: 9200,
            soilMoisturePercentage: 48.0,
            valveCount: 4,
            sensorNodesCount: 4,
            isActive: false,
          ),
        ],
      ),
      FarmEntity(
        id: 'farm-003',
        ownerUserId: 'usr-farmer-01',
        name: 'مزرعة الوادي الأخضر للموالح',
        location: 'النوبارية - طريق الإسكندرية الصحراوي',
        area: 25.0,
        areaUnit: AreaUnit.feddan,
        treesCount: 1600,
        crops: ['برتقال صيفي', 'يوسفي'],
        irrigationType: IrrigationType.sprinkler,
        waterSource: FarmWaterSource.waterTank,
        healthStatus: FarmHealthStatus.needsAttention,
        installationStatus: InstallationStatus.inspectionPending,
        hasSolarPower: false,
        notes:
            'بحاجة لتحديث شبكة الري وتحويلها من الرش اليدوي إلى التنقيط الذكي الموفر للمياه.',
        createdAt: DateTime(2026, 4, 2),
        zones: [
          const IrrigationZoneEntity(
            id: 'zone-003-a',
            farmId: 'farm-003',
            name: 'حوض البرتقال الرئيسي',
            area: 15.0,
            cropType: 'برتقال صيفي',
            treesCount: 950,
            waterRequirementLitersPerDay: 5800,
            soilMoisturePercentage: 29.5,
            valveCount: 2,
            sensorNodesCount: 2,
            isActive: false,
          ),
          const IrrigationZoneEntity(
            id: 'zone-003-b',
            farmId: 'farm-003',
            name: 'حوض اليوسفي الصغير',
            area: 10.0,
            cropType: 'يوسفي',
            treesCount: 650,
            waterRequirementLitersPerDay: 3400,
            soilMoisturePercentage: 31.0,
            valveCount: 1,
            sensorNodesCount: 2,
            isActive: false,
          ),
        ],
      ),
    ];

    // 2. Initial Inspection Requests
    _inspectionRequests = [
      FarmInspectionRequestEntity(
        id: 'INS-2026-081',
        customerUserId: 'usr-farmer-01',
        assignedTechnicianId: 'usr-tech-01',
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        customerName: 'م. أحمد المنشاوي',
        phoneNumber: '+20 100 123 4567',
        location: 'وادي النطرون، البحيرة (Wadi El Natrun)',
        area: 45.0,
        areaUnit: AreaUnit.feddan,
        treesCount: 2400,
        cropTypes: ['زيتون كالماتا', 'نخيل برحي', 'موالح'],
        waterSource: FarmWaterSource.deepWell,
        existingIrrigationSystem: IrrigationType.drip,
        preferredInspectionDate: DateTime(2026, 1, 18),
        submissionDate: DateTime(2026, 1, 15),
        scheduledVisitDate: DateTime(2026, 1, 20),
        status: InspectionStatus.approved,
        engineerNotes:
            'تمت المعاينة بنجاح بواسطة م. كريم عبد الله. ملوحة التربة مناسبة وضغط المياه عبر البئر 3.8 بار. تم تركيب منظومة الطاقة الشمسية والمجسات.',
        additionalNotes:
            'يرجى التركيز على حماية محابس الري التلقائي من درجات الحرارة المرتفعة.',
        quotation: InspectionQuotationEntity(
          id: 'QUOT-2026-081',
          quotationNumber: 'GF-Q-2026-081',
          createdAt: DateTime(2026, 1, 22),
          hardwareItems: const [
            HardwareItemEntity(
              nameEn: 'GreenFlow Central Gateway ESP32 (Industrial Solar)',
              nameAr: 'وحدة التحكم المركزية ESP32 الصناعية المدارة بالطاقة الشمسية',
              categoryEn: 'Controller',
              categoryAr: 'وحدات التحكم',
              quantity: 1,
              unitPrice: 12500,
            ),
            HardwareItemEntity(
              nameEn: 'Precision Wireless LoRa Soil Moisture & Salinity Probes',
              nameAr: 'مجسات رطوبة وملوحة التربة اللاسلكية بنظام LoRa',
              categoryEn: 'Sensor',
              categoryAr: 'المستشعرات',
              quantity: 9,
              unitPrice: 2200,
            ),
            HardwareItemEntity(
              nameEn: 'DC 24V Smart Solenoid Latching Valves (2-inch)',
              nameAr: 'محابس كهربائية ذكية موفرة للطاقة قياس 2 بوصة',
              categoryEn: 'Actuator',
              categoryAr: 'المحابس والصمامات',
              quantity: 7,
              unitPrice: 3100,
            ),
            HardwareItemEntity(
              nameEn: 'Solar Panel 450W + Deep-Cycle Gel Battery Pack',
              nameAr: 'لوح طاقة شمسية 450 واط وبطارية جل للتفريغ العميق',
              categoryEn: 'Solar Power',
              categoryAr: 'الطاقة الشمسية',
              quantity: 2,
              unitPrice: 8500,
            ),
          ],
          installationCost: 8500,
          monthlySubscriptionFee: 950,
          isApprovedByCustomer: true,
        ),
      ),
      FarmInspectionRequestEntity(
        id: 'INS-2026-094',
        customerUserId: 'usr-farmer-03',
        assignedTechnicianId: 'usr-tech-01',
        farmId: 'farm-002',
        farmName: 'واحة النخيل العضوي',
        customerName: 'محمود سالم',
        phoneNumber: '+20 112 345 6789',
        location: 'توشكى - شرق العوينات (Toshka)',
        area: 80.0,
        areaUnit: AreaUnit.feddan,
        treesCount: 3800,
        cropTypes: ['نخيل مجدول', 'برسيم حجازي'],
        waterSource: FarmWaterSource.deepWell,
        existingIrrigationSystem: IrrigationType.drip,
        preferredInspectionDate: DateTime(2026, 3, 14),
        submissionDate: DateTime(2026, 3, 10),
        scheduledVisitDate: DateTime(2026, 3, 16),
        status: InspectionStatus.quotationPending,
        engineerNotes:
            'تم فحص خطوط التوزيع الرئيسية وضغط طلمبة الأعماق. مساحة 80 فدان تحتاج إلى 2 وحدة ESP32 رئيسية ومكررات إشارة LoRa لضمان التغطية اللاسلكية الشاملة.',
        additionalNotes:
            'المزرعة تعتمد كلياً على الطاقة الشمسية في تشغيل طلمبة البئر.',
      ),
      FarmInspectionRequestEntity(
        id: 'INS-2026-102',
        customerUserId: 'usr-farmer-01',
        assignedTechnicianId: 'usr-tech-other',
        farmId: 'farm-003',
        farmName: 'مزرعة الوادي الأخضر للموالح',
        customerName: 'م. أحمد المنشاوي',
        phoneNumber: '+20 100 123 4567',
        location: 'النوبارية - طريق الإسكندرية الصحراوي',
        area: 25.0,
        areaUnit: AreaUnit.feddan,
        treesCount: 1600,
        cropTypes: ['برتقال صيفي', 'يوسفي'],
        waterSource: FarmWaterSource.waterTank,
        existingIrrigationSystem: IrrigationType.sprinkler,
        preferredInspectionDate: DateTime(2026, 4, 10),
        submissionDate: DateTime(2026, 4, 2),
        scheduledVisitDate: DateTime(2026, 4, 12),
        status: InspectionStatus.scheduled,
        engineerNotes:
            'تم تكليف الفريق الهندسي بقيادة م. رامي عادل لزيارة الموقع وقياس كفاءة التوزيع الهيدروليكي للخزان.',
        additionalNotes:
            'نأمل في تقليل استهلاك الكهرباء والمياه بنسبة 35% على الأقل.',
      ),
    ];
  }

  // --- Farms CRUD Operations ---

  List<FarmEntity> getFarms({UserAccount? user}) {
    final currentUser = user ?? AuthService().currentUser;
    if (currentUser == null) return List.unmodifiable(_farms);

    if (currentUser.role == UserRole.superAdmin) {
      return List.unmodifiable(_farms);
    }

    if (currentUser.role == UserRole.farmOwner) {
      return List.unmodifiable(
        _farms.where((f) => PermissionService.canAccessFarm(currentUser, f.id, ownerUserId: f.ownerUserId)),
      );
    }

    return const [];
  }

  List<FarmEntity> getAllFarms() => List.unmodifiable(_farms);

  FarmEntity? getFarmById(String id, {UserAccount? user}) {
    try {
      final farm = _farms.firstWhere((f) => f.id == id);
      final currentUser = user ?? AuthService().currentUser;
      if (currentUser != null && !PermissionService.canAccessFarm(currentUser, farm.id, ownerUserId: farm.ownerUserId)) {
        return null; // Deny access
      }
      return farm;
    } catch (_) {
      return null;
    }
  }

  void addFarm(FarmEntity farm) {
    _farms.insert(0, farm);
  }

  void updateFarm(FarmEntity updatedFarm) {
    final index = _farms.indexWhere((f) => f.id == updatedFarm.id);
    if (index != -1) {
      _farms[index] = updatedFarm;
    }
  }

  bool deleteFarm(String farmId, {UserAccount? user}) {
    final farm = _farms.where((f) => f.id == farmId).firstOrNull;
    if (farm == null) return false;
    final currentUser = user ?? AuthService().currentUser;
    if (currentUser != null && currentUser.role != UserRole.superAdmin && farm.ownerUserId != currentUser.id) {
      return false; // Unauthorized deletion
    }
    final initialLength = _farms.length;
    _farms.removeWhere((f) => f.id == farmId);
    return _farms.length < initialLength;
  }

  // --- Zones Operations ---

  void addZone(String farmId, IrrigationZoneEntity zone) {
    final farm = getFarmById(farmId);
    if (farm != null) {
      final updatedZones = List<IrrigationZoneEntity>.from(farm.zones)..add(zone);
      updateFarm(farm.copyWith(zones: updatedZones));
    }
  }

  void updateZone(String farmId, IrrigationZoneEntity updatedZone) {
    final farm = getFarmById(farmId);
    if (farm != null) {
      final updatedZones = farm.zones.map((z) {
        return z.id == updatedZone.id ? updatedZone : z;
      }).toList();
      updateFarm(farm.copyWith(zones: updatedZones));
    }
  }

  void deleteZone(String farmId, String zoneId) {
    final farm = getFarmById(farmId);
    if (farm != null) {
      final updatedZones = farm.zones.where((z) => z.id != zoneId).toList();
      updateFarm(farm.copyWith(zones: updatedZones));
    }
  }

  // --- Inspection Requests Operations ---

  List<FarmInspectionRequestEntity> getInspectionRequests({UserAccount? user}) {
    final currentUser = user ?? AuthService().currentUser;
    if (currentUser == null || currentUser.role == UserRole.superAdmin) {
      return List.unmodifiable(_inspectionRequests);
    }

    if (currentUser.role == UserRole.farmOwner) {
      return List.unmodifiable(
        _inspectionRequests.where((r) =>
            r.customerUserId == currentUser.id ||
            (r.farmId != null && PermissionService.canAccessFarm(currentUser, r.farmId!))),
      );
    }

    return const [];
  }

  FarmInspectionRequestEntity? getInspectionRequestById(String id, {UserAccount? user}) {
    try {
      final req = _inspectionRequests.firstWhere((r) => r.id == id);
      final currentUser = user ?? AuthService().currentUser;
      if (currentUser != null &&
          !PermissionService.canAccessInspection(
            currentUser,
            customerUserId: req.customerUserId,
            farmId: req.farmId,
            assignedTechnicianId: req.assignedTechnicianId,
          )) {
        return null; // Deny access
      }
      return req;
    } catch (_) {
      return null;
    }
  }

  FarmInspectionRequestEntity? getInspectionRequestForFarm(String farmId) {
    try {
      return _inspectionRequests.firstWhere((r) => r.farmId == farmId);
    } catch (_) {
      return null;
    }
  }

  void submitInspectionRequest(FarmInspectionRequestEntity request) {
    _inspectionRequests.insert(0, request);

    // If associated with a farm, update the farm's installationStatus
    if (request.farmId != null) {
      final farm = getFarmById(request.farmId!);
      if (farm != null &&
          farm.installationStatus == InstallationStatus.notInspected) {
        updateFarm(farm.copyWith(
          installationStatus: InstallationStatus.inspectionPending,
        ));
      }
    }
  }

  void updateInspectionRequest(FarmInspectionRequestEntity request) {
    final idx = _inspectionRequests.indexWhere((r) => r.id == request.id);
    if (idx != -1) {
      _inspectionRequests[idx] = request;
    }
  }
}
