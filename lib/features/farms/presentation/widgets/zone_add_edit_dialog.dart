import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/farm_entities.dart';

/// Modal dialog / bottom sheet for adding or updating an Irrigation Zone.
class ZoneAddEditDialog extends StatefulWidget {
  final String farmId;
  final IrrigationZoneEntity? initialZone;
  final ValueChanged<IrrigationZoneEntity> onSave;

  const ZoneAddEditDialog({
    super.key,
    required this.farmId,
    this.initialZone,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required String farmId,
    IrrigationZoneEntity? initialZone,
    required ValueChanged<IrrigationZoneEntity> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ZoneAddEditDialog(
        farmId: farmId,
        initialZone: initialZone,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ZoneAddEditDialog> createState() => _ZoneAddEditDialogState();
}

class _ZoneAddEditDialogState extends State<ZoneAddEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  late final TextEditingController _cropController;
  late final TextEditingController _treesController;
  late final TextEditingController _waterController;
  late final TextEditingController _valvesController;
  late final TextEditingController _sensorsController;

  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final z = widget.initialZone;
    _nameController = TextEditingController(text: z?.name ?? '');
    _areaController =
        TextEditingController(text: z != null ? '${z.area}' : '');
    _cropController = TextEditingController(text: z?.cropType ?? '');
    _treesController =
        TextEditingController(text: z != null ? '${z.treesCount}' : '');
    _waterController = TextEditingController(
        text: z != null ? '${z.waterRequirementLitersPerDay.toInt()}' : '3500');
    _valvesController =
        TextEditingController(text: z != null ? '${z.valveCount}' : '2');
    _sensorsController =
        TextEditingController(text: z != null ? '${z.sensorNodesCount}' : '3');
    _isActive = z?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _cropController.dispose();
    _treesController.dispose();
    _waterController.dispose();
    _valvesController.dispose();
    _sensorsController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final zone = IrrigationZoneEntity(
      id: widget.initialZone?.id ??
          'zone-${DateTime.now().millisecondsSinceEpoch}',
      farmId: widget.farmId,
      name: _nameController.text.trim(),
      area: double.tryParse(_areaController.text.trim()) ?? 10.0,
      cropType: _cropController.text.trim(),
      treesCount: int.tryParse(_treesController.text.trim()) ?? 500,
      waterRequirementLitersPerDay:
          double.tryParse(_waterController.text.trim()) ?? 3500.0,
      valveCount: int.tryParse(_valvesController.text.trim()) ?? 2,
      sensorNodesCount: int.tryParse(_sensorsController.text.trim()) ?? 3,
      soilMoisturePercentage:
          widget.initialZone?.soilMoisturePercentage ?? 42.0,
      soilType: widget.initialZone?.soilType ?? 'Sandy Loam / طميية رملية',
      isActive: _isActive,
    );

    widget.onSave(zone);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = AppStrings.isArabic(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                widget.initialZone != null
                    ? AppStrings.editZone(context)
                    : AppStrings.addZone(context),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 16),

              // Zone Name
              CustomTextField(
                label: AppStrings.zoneName(context),
                hint: AppStrings.zoneNameHint(context),
                controller: _nameController,
                prefixIcon: Icons.water_drop_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.fieldRequired(context);
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // Area & Crop Type Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: AppStrings.zoneArea(context),
                      hint: '15',
                      controller: _areaController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      prefixIcon: Icons.square_foot_rounded,
                      validator: (val) {
                        if (val == null || double.tryParse(val.trim()) == null) {
                          return AppStrings.enterValidNumber(context);
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      label: AppStrings.zoneCrop(context),
                      hint: isArabic ? 'نخيل برحي' : 'Olives',
                      controller: _cropController,
                      prefixIcon: Icons.energy_savings_leaf_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return AppStrings.fieldRequired(context);
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Trees count & Daily water requirements
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: AppStrings.treesCount(context),
                      hint: '800',
                      controller: _treesController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.park_rounded,
                      validator: (val) {
                        if (val == null || int.tryParse(val.trim()) == null) {
                          return AppStrings.enterValidNumber(context);
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      label: isArabic ? 'الري (لتر/يوم)' : 'Water (L/day)',
                      hint: '4500',
                      controller: _waterController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.opacity_rounded,
                      validator: (val) {
                        if (val == null || double.tryParse(val.trim()) == null) {
                          return AppStrings.enterValidNumber(context);
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Valves & Sensors counts
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: AppStrings.valveCount(context),
                      hint: '2',
                      controller: _valvesController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.tune_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      label: AppStrings.sensorCount(context),
                      hint: '3',
                      controller: _sensorsController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.sensors_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Active Switch Tile
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primaryGreen,
                activeTrackColor:
                    AppColors.primaryGreen.withValues(alpha: 0.3),
                title: Text(
                  isArabic ? 'المنطقة مفعلة في برنامج الري' : 'Zone Active for Irrigation',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                value: _isActive,
                onChanged: (val) {
                  setState(() {
                    _isActive = val;
                  });
                },
              ),

              const SizedBox(height: 18),

              // Save Action Button
              CustomButton(
                label: widget.initialZone != null
                    ? AppStrings.save(context)
                    : (isArabic ? 'إضافة القطاع' : 'Add Zone'),
                icon: Icons.check_circle_rounded,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
