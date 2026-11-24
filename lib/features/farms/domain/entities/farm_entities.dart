import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Area measurement units for agriculture farms.
enum AreaUnit {
  feddan,
  hectare,
  acre,
  dunam;

  String labelEn() {
    switch (this) {
      case AreaUnit.feddan:
        return 'Feddan';
      case AreaUnit.hectare:
        return 'Hectare';
      case AreaUnit.acre:
        return 'Acre';
      case AreaUnit.dunam:
        return 'Dunam';
    }
  }

  String labelAr() {
    switch (this) {
      case AreaUnit.feddan:
        return 'فدان';
      case AreaUnit.hectare:
        return 'هكتار';
      case AreaUnit.acre:
        return 'فدان غربي (Acre)';
      case AreaUnit.dunam:
        return 'دونم';
    }
  }
}

/// Farm irrigation technology types.
enum IrrigationType {
  drip,
  sprinkler,
  surface,
  pivot;

  String labelEn() {
    switch (this) {
      case IrrigationType.drip:
        return 'Drip Irrigation';
      case IrrigationType.sprinkler:
        return 'Sprinkler System';
      case IrrigationType.surface:
        return 'Surface / Flood Irrigation';
      case IrrigationType.pivot:
        return 'Center Pivot';
    }
  }

  String labelAr() {
    switch (this) {
      case IrrigationType.drip:
        return 'ري بالتنقيط الذكي';
      case IrrigationType.sprinkler:
        return 'ري بالرش الحديث';
      case IrrigationType.surface:
        return 'ري سطحي تقليدي';
      case IrrigationType.pivot:
        return 'ري محوري (Pivot)';
    }
  }

  IconData icon() {
    switch (this) {
      case IrrigationType.drip:
        return Icons.water_drop_rounded;
      case IrrigationType.sprinkler:
        return Icons.shower_rounded;
      case IrrigationType.surface:
        return Icons.waves_rounded;
      case IrrigationType.pivot:
        return Icons.rotate_right_rounded;
    }
  }
}

/// Farm water supply source.
enum FarmWaterSource {
  deepWell,
  waterTank,
  canalRiver,
  municipalNetwork;

  String labelEn() {
    switch (this) {
      case FarmWaterSource.deepWell:
        return 'Deep Underground Well';
      case FarmWaterSource.waterTank:
        return 'Water Storage Tank / Lake';
      case FarmWaterSource.canalRiver:
        return 'Canal / River Intake';
      case FarmWaterSource.municipalNetwork:
        return 'Agricultural Water Network';
    }
  }

  String labelAr() {
    switch (this) {
      case FarmWaterSource.deepWell:
        return 'بئر جوفي عميق';
      case FarmWaterSource.waterTank:
        return 'خزان مياه / بركة تجميع';
      case FarmWaterSource.canalRiver:
        return 'ترعة / مأخذ مائي نهري';
      case FarmWaterSource.municipalNetwork:
        return 'شبكة ري مجمعة';
    }
  }

  IconData icon() {
    switch (this) {
      case FarmWaterSource.deepWell:
        return Icons.terrain_rounded;
      case FarmWaterSource.waterTank:
        return Icons.storage_rounded;
      case FarmWaterSource.canalRiver:
        return Icons.alt_route_rounded;
      case FarmWaterSource.municipalNetwork:
        return Icons.hub_rounded;
    }
  }
}

/// Overall farm health status.
enum FarmHealthStatus {
  excellent,
  good,
  needsAttention,
  critical;

  String labelEn() {
    switch (this) {
      case FarmHealthStatus.excellent:
        return 'Excellent Health';
      case FarmHealthStatus.good:
        return 'Good Condition';
      case FarmHealthStatus.needsAttention:
        return 'Needs Attention';
      case FarmHealthStatus.critical:
        return 'Critical State';
    }
  }

  String labelAr() {
    switch (this) {
      case FarmHealthStatus.excellent:
        return 'حالة ممتازة';
      case FarmHealthStatus.good:
        return 'حالة جيدة';
      case FarmHealthStatus.needsAttention:
        return 'تحتاج متابعة';
      case FarmHealthStatus.critical:
        return 'حالة حرجة';
    }
  }

  Color color() {
    switch (this) {
      case FarmHealthStatus.excellent:
        return AppColors.sensorOnline;
      case FarmHealthStatus.good:
        return AppColors.primaryGreen;
      case FarmHealthStatus.needsAttention:
        return AppColors.sensorWarning;
      case FarmHealthStatus.critical:
        return AppColors.sensorAlert;
    }
  }

  IconData icon() {
    switch (this) {
      case FarmHealthStatus.excellent:
        return Icons.verified_rounded;
      case FarmHealthStatus.good:
        return Icons.check_circle_outline_rounded;
      case FarmHealthStatus.needsAttention:
        return Icons.warning_amber_rounded;
      case FarmHealthStatus.critical:
        return Icons.error_outline_rounded;
    }
  }
}

/// Farm technical inspection and equipment installation status.
enum InstallationStatus {
  notInspected,
  inspectionPending,
  inspectionCompleted,
  quotationReady,
  hardwareInstalled,
  activeMonitoring;

  String labelEn() {
    switch (this) {
      case InstallationStatus.notInspected:
        return 'Not Inspected';
      case InstallationStatus.inspectionPending:
        return 'Inspection Pending';
      case InstallationStatus.inspectionCompleted:
        return 'Inspection Completed';
      case InstallationStatus.quotationReady:
        return 'Quotation Ready';
      case InstallationStatus.hardwareInstalled:
        return 'Hardware Installed';
      case InstallationStatus.activeMonitoring:
        return 'Active IoT Monitoring';
    }
  }

  String labelAr() {
    switch (this) {
      case InstallationStatus.notInspected:
        return 'لم تتم المعاينة';
      case InstallationStatus.inspectionPending:
        return 'بانتظار المعاينة';
      case InstallationStatus.inspectionCompleted:
        return 'تمت المعاينة الفنية';
      case InstallationStatus.quotationReady:
        return 'المقايسة جاهزة';
      case InstallationStatus.hardwareInstalled:
        return 'العتاد مثبت';
      case InstallationStatus.activeMonitoring:
        return 'مراقبة ذكية نشطة';
    }
  }

  Color color() {
    switch (this) {
      case InstallationStatus.notInspected:
        return AppColors.textMutedDark;
      case InstallationStatus.inspectionPending:
        return AppColors.flowBlue;
      case InstallationStatus.inspectionCompleted:
        return const Color(0xFF6366F1); // Indigo
      case InstallationStatus.quotationReady:
        return AppColors.sensorWarning;
      case InstallationStatus.hardwareInstalled:
        return const Color(0xFF06B6D4); // Cyan
      case InstallationStatus.activeMonitoring:
        return AppColors.sensorOnline;
    }
  }
}

/// Farm customer inspection lifecycle status.
enum InspectionStatus {
  pending,
  underReview,
  scheduled,
  inspectionCompleted,
  quotationPending,
  approved,
  rejected;

  String labelEn() {
    switch (this) {
      case InspectionStatus.pending:
        return 'Pending';
      case InspectionStatus.underReview:
        return 'Under Review';
      case InspectionStatus.scheduled:
        return 'Visit Scheduled';
      case InspectionStatus.inspectionCompleted:
        return 'Inspection Done';
      case InspectionStatus.quotationPending:
        return 'Quotation Pending';
      case InspectionStatus.approved:
        return 'Approved & Ready';
      case InspectionStatus.rejected:
        return 'Declined';
    }
  }

  String labelAr() {
    switch (this) {
      case InspectionStatus.pending:
        return 'قيد الانتظار';
      case InspectionStatus.underReview:
        return 'قيد المراجعة الفنية';
      case InspectionStatus.scheduled:
        return 'زيارة مجدولة';
      case InspectionStatus.inspectionCompleted:
        return 'تمت المعاينة الحقلية';
      case InspectionStatus.quotationPending:
        return 'إعداد المقايسة';
      case InspectionStatus.approved:
        return 'معتمدة وجاهزة للتعاقد';
      case InspectionStatus.rejected:
        return 'مرفوضة';
    }
  }

  Color color() {
    switch (this) {
      case InspectionStatus.pending:
        return const Color(0xFF94A3B8);
      case InspectionStatus.underReview:
        return AppColors.flowBlue;
      case InspectionStatus.scheduled:
        return const Color(0xFF8B5CF6); // Purple
      case InspectionStatus.inspectionCompleted:
        return const Color(0xFF06B6D4); // Cyan
      case InspectionStatus.quotationPending:
        return AppColors.sensorWarning;
      case InspectionStatus.approved:
        return AppColors.sensorOnline;
      case InspectionStatus.rejected:
        return AppColors.sensorAlert;
    }
  }

  IconData icon() {
    switch (this) {
      case InspectionStatus.pending:
        return Icons.schedule_rounded;
      case InspectionStatus.underReview:
        return Icons.manage_search_rounded;
      case InspectionStatus.scheduled:
        return Icons.calendar_month_rounded;
      case InspectionStatus.inspectionCompleted:
        return Icons.assignment_turned_in_rounded;
      case InspectionStatus.quotationPending:
        return Icons.calculate_rounded;
      case InspectionStatus.approved:
        return Icons.check_circle_rounded;
      case InspectionStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}

/// Farm Entity representing a commercial agriculture property.
class FarmEntity {
  final String id;
  final String name;
  final String location;
  final double area;
  final AreaUnit areaUnit;
  final int treesCount;
  final List<String> crops;
  final IrrigationType irrigationType;
  final FarmWaterSource waterSource;
  final FarmHealthStatus healthStatus;
  final InstallationStatus installationStatus;
  final String notes;
  final List<IrrigationZoneEntity> zones;
  final DateTime createdAt;
  final bool hasSolarPower;
  final String? imageUrl;
  final String ownerUserId;

  /// Total connected IoT sensor and actuator nodes for this farm
  int get devices => zones.isEmpty ? 4 : zones.fold(0, (sum, z) => sum + z.sensorNodesCount + z.valveCount);
  int get devicesCount => devices;

  const FarmEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.area,
    this.areaUnit = AreaUnit.feddan,
    required this.treesCount,
    required this.crops,
    required this.irrigationType,
    required this.waterSource,
    this.healthStatus = FarmHealthStatus.good,
    this.installationStatus = InstallationStatus.notInspected,
    this.notes = '',
    this.zones = const [],
    required this.createdAt,
    this.hasSolarPower = true,
    this.imageUrl,
    this.ownerUserId = 'usr-farmer-01',
  });

  FarmEntity copyWith({
    String? id,
    String? name,
    String? location,
    double? area,
    AreaUnit? areaUnit,
    int? treesCount,
    List<String>? crops,
    IrrigationType? irrigationType,
    FarmWaterSource? waterSource,
    FarmHealthStatus? healthStatus,
    InstallationStatus? installationStatus,
    String? notes,
    List<IrrigationZoneEntity>? zones,
    DateTime? createdAt,
    bool? hasSolarPower,
    String? imageUrl,
    String? ownerUserId,
  }) {
    return FarmEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      area: area ?? this.area,
      areaUnit: areaUnit ?? this.areaUnit,
      treesCount: treesCount ?? this.treesCount,
      crops: crops ?? this.crops,
      irrigationType: irrigationType ?? this.irrigationType,
      waterSource: waterSource ?? this.waterSource,
      healthStatus: healthStatus ?? this.healthStatus,
      installationStatus: installationStatus ?? this.installationStatus,
      notes: notes ?? this.notes,
      zones: zones ?? this.zones,
      createdAt: createdAt ?? this.createdAt,
      hasSolarPower: hasSolarPower ?? this.hasSolarPower,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerUserId: ownerUserId ?? this.ownerUserId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'area': area,
    'areaUnit': areaUnit.name,
    'treesCount': treesCount,
    'crops': crops,
    'irrigationType': irrigationType.name,
    'waterSource': waterSource.name,
    'healthStatus': healthStatus.name,
    'installationStatus': installationStatus.name,
    'notes': notes,
    'zones': zones.map((z) => z.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'hasSolarPower': hasSolarPower,
    'imageUrl': imageUrl,
    'ownerUserId': ownerUserId,
  };

  factory FarmEntity.fromJson(Map<String, dynamic> json) => FarmEntity(
    id: json['id'] as String,
    name: json['name'] as String,
    location: json['location'] as String,
    area: (json['area'] as num).toDouble(),
    areaUnit: AreaUnit.values.firstWhere(
      (e) => e.name == json['areaUnit'],
      orElse: () => AreaUnit.feddan,
    ),
    treesCount: json['treesCount'] as int? ?? 0,
    crops: (json['crops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    irrigationType: IrrigationType.values.firstWhere(
      (e) => e.name == json['irrigationType'],
      orElse: () => IrrigationType.drip,
    ),
    waterSource: FarmWaterSource.values.firstWhere(
      (e) => e.name == json['waterSource'],
      orElse: () => FarmWaterSource.deepWell,
    ),
    healthStatus: FarmHealthStatus.values.firstWhere(
      (e) => e.name == json['healthStatus'],
      orElse: () => FarmHealthStatus.good,
    ),
    installationStatus: InstallationStatus.values.firstWhere(
      (e) => e.name == json['installationStatus'],
      orElse: () => InstallationStatus.notInspected,
    ),
    notes: json['notes'] as String? ?? '',
    zones: (json['zones'] as List<dynamic>?)
            ?.map((e) => IrrigationZoneEntity.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    hasSolarPower: json['hasSolarPower'] as bool? ?? true,
    imageUrl: json['imageUrl'] as String?,
    ownerUserId: json['ownerUserId'] as String? ?? 'usr-farmer-01',
  );
}

/// Individual irrigation zone within a farm.
class IrrigationZoneEntity {
  final String id;
  final String farmId;
  final String name;
  final double area;
  final String cropType;
  final int treesCount;
  final double waterRequirementLitersPerDay;
  final double soilMoisturePercentage;
  final String soilType;
  final int valveCount;
  final int sensorNodesCount;
  final bool isActive;

  const IrrigationZoneEntity({
    required this.id,
    required this.farmId,
    required this.name,
    required this.area,
    required this.cropType,
    required this.treesCount,
    required this.waterRequirementLitersPerDay,
    this.soilMoisturePercentage = 42.0,
    this.soilType = 'Sandy Loam / طميية رملية',
    this.valveCount = 2,
    this.sensorNodesCount = 3,
    this.isActive = true,
  });

  IrrigationZoneEntity copyWith({
    String? id,
    String? farmId,
    String? name,
    double? area,
    String? cropType,
    int? treesCount,
    double? waterRequirementLitersPerDay,
    double? soilMoisturePercentage,
    String? soilType,
    int? valveCount,
    int? sensorNodesCount,
    bool? isActive,
  }) {
    return IrrigationZoneEntity(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      area: area ?? this.area,
      cropType: cropType ?? this.cropType,
      treesCount: treesCount ?? this.treesCount,
      waterRequirementLitersPerDay:
          waterRequirementLitersPerDay ?? this.waterRequirementLitersPerDay,
      soilMoisturePercentage:
          soilMoisturePercentage ?? this.soilMoisturePercentage,
      soilType: soilType ?? this.soilType,
      valveCount: valveCount ?? this.valveCount,
      sensorNodesCount: sensorNodesCount ?? this.sensorNodesCount,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'farmId': farmId,
    'name': name,
    'area': area,
    'cropType': cropType,
    'treesCount': treesCount,
    'waterRequirementLitersPerDay': waterRequirementLitersPerDay,
    'soilMoisturePercentage': soilMoisturePercentage,
    'soilType': soilType,
    'valveCount': valveCount,
    'sensorNodesCount': sensorNodesCount,
    'isActive': isActive,
  };

  factory IrrigationZoneEntity.fromJson(Map<String, dynamic> json) => IrrigationZoneEntity(
    id: json['id'] as String,
    farmId: json['farmId'] as String,
    name: json['name'] as String,
    area: (json['area'] as num).toDouble(),
    cropType: json['cropType'] as String,
    treesCount: json['treesCount'] as int? ?? 0,
    waterRequirementLitersPerDay: (json['waterRequirementLitersPerDay'] as num).toDouble(),
    soilMoisturePercentage: (json['soilMoisturePercentage'] as num?)?.toDouble() ?? 42.0,
    soilType: json['soilType'] as String? ?? 'Sandy Loam',
    valveCount: json['valveCount'] as int? ?? 2,
    sensorNodesCount: json['sensorNodesCount'] as int? ?? 3,
    isActive: json['isActive'] as bool? ?? true,
  );
}

/// Farm technical inspection request entity.
class FarmInspectionRequestEntity {
  final String id;
  final String? farmId;
  final String farmName;
  final String customerName;
  final String phoneNumber;
  final String location;
  final double area;
  final AreaUnit areaUnit;
  final int treesCount;
  final List<String> cropTypes;
  final FarmWaterSource waterSource;
  final IrrigationType existingIrrigationSystem;
  final DateTime preferredInspectionDate;
  final DateTime submissionDate;
  final DateTime? scheduledVisitDate;
  final InspectionStatus status;
  final String? engineerNotes;
  final String? additionalNotes;
  final InspectionQuotationEntity? quotation;
  final String? customerUserId;
  final String? assignedTechnicianId;

  const FarmInspectionRequestEntity({
    required this.id,
    this.farmId,
    required this.farmName,
    required this.customerName,
    required this.phoneNumber,
    required this.location,
    required this.area,
    this.areaUnit = AreaUnit.feddan,
    required this.treesCount,
    required this.cropTypes,
    required this.waterSource,
    required this.existingIrrigationSystem,
    required this.preferredInspectionDate,
    required this.submissionDate,
    this.scheduledVisitDate,
    this.status = InspectionStatus.pending,
    this.engineerNotes,
    this.additionalNotes,
    this.quotation,
    this.customerUserId,
    this.assignedTechnicianId,
  });

  FarmInspectionRequestEntity copyWith({
    String? id,
    String? farmId,
    String? farmName,
    String? customerName,
    String? phoneNumber,
    String? location,
    double? area,
    AreaUnit? areaUnit,
    int? treesCount,
    List<String>? cropTypes,
    FarmWaterSource? waterSource,
    IrrigationType? existingIrrigationSystem,
    DateTime? preferredInspectionDate,
    DateTime? submissionDate,
    DateTime? scheduledVisitDate,
    InspectionStatus? status,
    String? engineerNotes,
    String? additionalNotes,
    InspectionQuotationEntity? quotation,
    String? customerUserId,
    String? assignedTechnicianId,
  }) {
    return FarmInspectionRequestEntity(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      area: area ?? this.area,
      areaUnit: areaUnit ?? this.areaUnit,
      treesCount: treesCount ?? this.treesCount,
      cropTypes: cropTypes ?? this.cropTypes,
      waterSource: waterSource ?? this.waterSource,
      existingIrrigationSystem:
          existingIrrigationSystem ?? this.existingIrrigationSystem,
      preferredInspectionDate:
          preferredInspectionDate ?? this.preferredInspectionDate,
      submissionDate: submissionDate ?? this.submissionDate,
      scheduledVisitDate: scheduledVisitDate ?? this.scheduledVisitDate,
      status: status ?? this.status,
      engineerNotes: engineerNotes ?? this.engineerNotes,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      quotation: quotation ?? this.quotation,
      customerUserId: customerUserId ?? this.customerUserId,
      assignedTechnicianId: assignedTechnicianId ?? this.assignedTechnicianId,
    );
  }
}

/// Prepared Quotation Workflow Entity separating hardware capital costs from recurring subscription fees.
class InspectionQuotationEntity {
  final String id;
  final String quotationNumber;
  final DateTime createdAt;
  final List<HardwareItemEntity> hardwareItems;
  final double installationCost;
  final double monthlySubscriptionFee;
  final String subscriptionTierEn;
  final String subscriptionTierAr;
  final bool isApprovedByCustomer;

  const InspectionQuotationEntity({
    required this.id,
    required this.quotationNumber,
    required this.createdAt,
    required this.hardwareItems,
    required this.installationCost,
    required this.monthlySubscriptionFee,
    this.subscriptionTierEn = 'Professional Smart Solar IoT Plan',
    this.subscriptionTierAr = 'باقة الرعاية والتحكم الشمسي الاحترافية',
    this.isApprovedByCustomer = false,
  });

  double get hardwareTotalCost =>
      hardwareItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalOneTimeFee => hardwareTotalCost + installationCost;
}

/// Itemized hardware component in quotation.
class HardwareItemEntity {
  final String nameEn;
  final String nameAr;
  final String categoryEn;
  final String categoryAr;
  final int quantity;
  final double unitPrice;

  const HardwareItemEntity({
    required this.nameEn,
    required this.nameAr,
    required this.categoryEn,
    required this.categoryAr,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;
}
