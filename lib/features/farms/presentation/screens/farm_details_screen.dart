import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/datasources/farms_mock_data_source.dart';
import '../../domain/entities/farm_entities.dart';
import '../widgets/irrigation_zone_card.dart';
import '../widgets/zone_add_edit_dialog.dart';

/// Detailed Farm View Screen displaying zones, crops, solar system, and inspection workflow link.
class FarmDetailsScreen extends StatefulWidget {
  final String farmId;
  final FarmsMockDataSource? dataSource;

  const FarmDetailsScreen({super.key, required this.farmId, this.dataSource});

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  late final FarmsMockDataSource _dataSource;
  FarmEntity? _farm;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? FarmsMockDataSource();
    _loadFarm();
  }

  void _loadFarm() {
    setState(() {
      _farm = _dataSource.getFarmById(widget.farmId);
    });
  }

  void _onEditFarm() async {
    if (_farm == null) return;
    final updated = await Navigator.pushNamed(
      context,
      AppRoutes.farmAddEdit,
      arguments: _farm,
    );
    if (updated == true) {
      _loadFarm();
    }
  }

  void _onDeleteFarm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.deleteFarm(context)),
        content: Text(AppStrings.confirmDeleteFarm(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel(context)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.sensorAlert,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _dataSource.deleteFarm(widget.farmId);
              Navigator.pop(context, true);
            },
            child: Text(AppStrings.delete(context)),
          ),
        ],
      ),
    );
  }

  void _onAddZone() {
    ZoneAddEditDialog.show(
      context,
      farmId: widget.farmId,
      onSave: (newZone) {
        _dataSource.addZone(widget.farmId, newZone);
        _loadFarm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryGreenDark,
            content: Text(
              AppStrings.isArabic(context)
                  ? 'تمت إضافة منطقة الري بنجاح'
                  : 'Irrigation zone added successfully',
            ),
          ),
        );
      },
    );
  }

  void _onEditZone(IrrigationZoneEntity zone) {
    ZoneAddEditDialog.show(
      context,
      farmId: widget.farmId,
      initialZone: zone,
      onSave: (updated) {
        _dataSource.updateZone(widget.farmId, updated);
        _loadFarm();
      },
    );
  }

  void _onDeleteZone(IrrigationZoneEntity zone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.deleteZone(context)),
        content: Text(AppStrings.confirmDeleteZone(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel(context)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.sensorAlert,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _dataSource.deleteZone(widget.farmId, zone.id);
              _loadFarm();
            },
            child: Text(AppStrings.delete(context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_farm == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.farmDetailsTitle(context))),
        body: Center(
          child: Text(isArabic ? 'المزرعة غير موجودة' : 'Farm not found'),
        ),
      );
    }

    final farm = _farm!;
    final areaUnitLabel = isArabic
        ? farm.areaUnit.labelAr()
        : farm.areaUnit.labelEn();

    // Check if there is an inspection request for this farm
    final linkedRequest = _dataSource.getInspectionRequestForFarm(farm.id);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          farm.name,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.editFarm(context),
            icon: const Icon(Icons.edit_outlined),
            onPressed: _onEditFarm,
          ),
          IconButton(
            tooltip: AppStrings.deleteFarm(context),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.sensorAlert,
            ),
            onPressed: _onDeleteFarm,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Overview Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.04,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                farm.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      farm.location,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: isArabic
                              ? farm.healthStatus.labelAr()
                              : farm.healthStatus.labelEn(),
                          color: farm.healthStatus.color(),
                          icon: farm.healthStatus.icon(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Quick Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _DetailStatBox(
                            label: AppStrings.farmArea(context),
                            value:
                                '${farm.area.toStringAsFixed(0)} $areaUnitLabel',
                            icon: Icons.square_foot_rounded,
                            color: AppColors.flowBlue,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DetailStatBox(
                            label: AppStrings.connectedDevices(context),
                            value: '${farm.devices}',
                            icon: Icons.memory_rounded,
                            color: AppColors.primaryGreen,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DetailStatBox(
                            label: AppStrings.totalZones(context),
                            value: '${farm.zones.length}',
                            icon: Icons.grid_view_rounded,
                            color: const Color(0xFF06B6D4),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Crops Chips
                    Text(
                      AppStrings.cropsAndTrees(context),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: farm.crops.map((c) {
                        return Chip(
                          label: Text(
                            c,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: isDark
                              ? AppColors.backgroundDark
                              : AppColors.primaryGreenSurface,
                          side: BorderSide(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.25,
                            ),
                          ),
                          avatar: const Icon(
                            Icons.eco_rounded,
                            size: 14,
                            color: AppColors.primaryGreen,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // Water Source & Solar Badges
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.backgroundDark
                                  : AppColors.flowBlueSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  farm.waterSource.icon(),
                                  color: AppColors.flowBlue,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.waterSource(context),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: isDark
                                              ? AppColors.textMutedDark
                                              : AppColors.textMutedLight,
                                        ),
                                      ),
                                      Text(
                                        isArabic
                                            ? farm.waterSource.labelAr()
                                            : farm.waterSource.labelEn(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.solar,
                                arguments: farm.id,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.backgroundDark
                                    : (farm.hasSolarPower
                                          ? const Color(
                                              0xFFFEF3C7,
                                            ) // Amber tint
                                          : AppColors.backgroundLight),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    farm.hasSolarPower
                                        ? Icons.solar_power_rounded
                                        : Icons.electrical_services_rounded,
                                    color: farm.hasSolarPower
                                        ? const Color(0xFFD97706)
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isArabic ? 'الطاقة' : 'Power System',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: isDark
                                                ? AppColors.textMutedDark
                                                : AppColors.textMutedLight,
                                          ),
                                        ),
                                        Text(
                                          farm.hasSolarPower
                                              ? (isArabic
                                                    ? 'طاقة شمسية'
                                                    : 'Solar Hybrid')
                                              : (isArabic
                                                    ? 'شبكة عادية'
                                                    : 'Grid Power'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: farm.hasSolarPower
                                                ? const Color(0xFFB45309)
                                                : Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (farm.notes.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        AppStrings.additionalNotes(context),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        farm.notes,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Inspection Workflow Action Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: farm.installationStatus.color().withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.assignment_turned_in_rounded,
                                size: 18,
                                color: farm.installationStatus.color(),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  AppStrings.inspectionStatusTitle(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: isArabic
                              ? farm.installationStatus.labelAr()
                              : farm.installationStatus.labelEn(),
                          color: farm.installationStatus.color(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (linkedRequest != null) ...[
                      Text(
                        isArabic
                            ? 'طلب المعاينة المسجل: ${linkedRequest.id}'
                            : 'Linked Request: ${linkedRequest.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.flowBlue,
                          side: const BorderSide(color: AppColors.flowBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: Text(AppStrings.viewInspectionDetails(context)),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.inspectionDetails,
                            arguments: linkedRequest.id,
                          );
                        },
                      ),
                    ] else ...[
                      Text(
                        isArabic
                            ? 'لم يتم طلب معاينة فنية لهذه المزرعة بعد. اطلب الآن لحساب احتياجات الألواح ومحابس الري.'
                            : 'No technical inspection requested yet. Order one to size solar arrays & smart valves.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        label: AppStrings.requestTechnicalInspection(context),
                        icon: Icons.calendar_month_rounded,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.inspectionRequest,
                            arguments: farm,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Irrigation Zones Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.flowBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.irrigationZonesSection(context),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${farm.zones.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      AppStrings.addZone(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _onAddZone,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Zones List
              if (farm.zones.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.water_drop_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isArabic
                              ? 'لا توجد قطاعات ري مسجلة بعد'
                              : 'No irrigation zones registered yet',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ...farm.zones.map((zone) {
                  return IrrigationZoneCard(
                    zone: zone,
                    onEdit: () => _onEditZone(zone),
                    onDelete: () => _onDeleteZone(zone),
                  );
                }),
              ],

              const SizedBox(height: 20),

              // 4. Sensors & Hardware Telemetry Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.flowBlueSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.flowBlue.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.sensors_rounded,
                      color: AppColors.flowBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  AppStrings.assignedDevices(context),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.flowBlue.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isArabic
                                      ? 'بيانات تجريبية'
                                      : 'Demo Telemetry',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.flowBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic
                                ? 'يتم ربط حساسات LoRa ومحابس ESP32 تلقائياً بعد اكتمال المعاينة وتثبيت العتاد.'
                                : 'LoRa probes and ESP32 actuators bind automatically upon hardware installation.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailStatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _DetailStatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
