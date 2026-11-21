import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/datasources/farms_mock_data_source.dart';
import '../../domain/entities/farm_entities.dart';

/// Screen for creating a new Farm or editing an existing Farm.
class FarmAddEditScreen extends StatefulWidget {
  final FarmEntity? initialFarm;
  final FarmsMockDataSource? dataSource;

  const FarmAddEditScreen({
    super.key,
    this.initialFarm,
    this.dataSource,
  });

  @override
  State<FarmAddEditScreen> createState() => _FarmAddEditScreenState();
}

class _FarmAddEditScreenState extends State<FarmAddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final FarmsMockDataSource _dataSource;
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _areaController;
  late final TextEditingController _treesController;
  late final TextEditingController _notesController;
  late final TextEditingController _customCropController;

  late AreaUnit _selectedAreaUnit;
  late IrrigationType _selectedIrrigationType;
  late FarmWaterSource _selectedWaterSource;
  late bool _hasSolarPower;
  late List<String> _selectedCrops;

  bool _isSaving = false;

  final List<String> _popularCropsEn = [
    'Olives',
    'Date Palm',
    'Citrus',
    'Mango',
    'Grapes',
    'Wheat',
    'Vegetables',
    'Alfalfa',
  ];

  final List<String> _popularCropsAr = [
    'زيتون',
    'نخيل',
    'موالح',
    'مانجو',
    'عنب',
    'قمح',
    'خضروات',
    'برسيم حجازي',
  ];

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? FarmsMockDataSource();
    final f = widget.initialFarm;

    _nameController = TextEditingController(text: f?.name ?? '');
    _locationController = TextEditingController(text: f?.location ?? '');
    _areaController =
        TextEditingController(text: f != null ? '${f.area}' : '');
    _treesController =
        TextEditingController(text: f != null ? '${f.treesCount}' : '');
    _notesController = TextEditingController(text: f?.notes ?? '');
    _customCropController = TextEditingController();

    _selectedAreaUnit = f?.areaUnit ?? AreaUnit.feddan;
    _selectedIrrigationType = f?.irrigationType ?? IrrigationType.drip;
    _selectedWaterSource = f?.waterSource ?? FarmWaterSource.deepWell;
    _hasSolarPower = f?.hasSolarPower ?? true;
    _selectedCrops = f != null ? List<String>.from(f.crops) : ['زيتون', 'نخيل'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _treesController.dispose();
    _notesController.dispose();
    _customCropController.dispose();
    super.dispose();
  }

  void _toggleCrop(String crop) {
    setState(() {
      if (_selectedCrops.contains(crop)) {
        _selectedCrops.remove(crop);
      } else {
        _selectedCrops.add(crop);
      }
    });
  }

  void _addCustomCrop() {
    final text = _customCropController.text.trim();
    if (text.isNotEmpty && !_selectedCrops.contains(text)) {
      setState(() {
        _selectedCrops.add(text);
        _customCropController.clear();
      });
    }
  }

  void _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.sensorAlert,
          content: Text(AppStrings.selectAtLeastOneCrop(context)),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    final isNew = widget.initialFarm == null;
    final farm = FarmEntity(
      id: widget.initialFarm?.id ??
          'farm-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      area: double.tryParse(_areaController.text.trim()) ?? 10.0,
      areaUnit: _selectedAreaUnit,
      treesCount: int.tryParse(_treesController.text.trim()) ?? 0,
      crops: _selectedCrops,
      irrigationType: _selectedIrrigationType,
      waterSource: _selectedWaterSource,
      hasSolarPower: _hasSolarPower,
      notes: _notesController.text.trim(),
      healthStatus:
          widget.initialFarm?.healthStatus ?? FarmHealthStatus.good,
      installationStatus: widget.initialFarm?.installationStatus ??
          InstallationStatus.notInspected,
      zones: widget.initialFarm?.zones ?? [],
      createdAt: widget.initialFarm?.createdAt ?? DateTime.now(),
    );

    if (isNew) {
      _dataSource.addFarm(farm);
    } else {
      _dataSource.updateFarm(farm);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          isNew
              ? (AppStrings.isArabic(context)
                  ? 'تم إنشاء المزرعة بنجاح'
                  : 'Farm registered successfully')
              : (AppStrings.isArabic(context)
                  ? 'تم حفظ التعديلات بنجاح'
                  : 'Farm updated successfully'),
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.initialFarm != null;

    final cropSuggestions = isArabic ? _popularCropsAr : _popularCropsEn;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isEditing
              ? AppStrings.editFarm(context)
              : AppStrings.addFarm(context),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Farm Name
                CustomTextField(
                  label: AppStrings.farmName(context),
                  hint: AppStrings.farmNameHint(context),
                  controller: _nameController,
                  prefixIcon: Icons.landscape_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppStrings.fieldRequired(context);
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 2. Location
                CustomTextField(
                  label: AppStrings.farmLocation(context),
                  hint: AppStrings.locationHint(context),
                  controller: _locationController,
                  prefixIcon: Icons.location_on_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppStrings.fieldRequired(context);
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 3. Area & Unit Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        label: AppStrings.farmArea(context),
                        hint: '45',
                        controller: _areaController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefixIcon: Icons.square_foot_rounded,
                        validator: (val) {
                          if (val == null ||
                              double.tryParse(val.trim()) == null) {
                            return AppStrings.enterValidNumber(context);
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.areaUnit(context),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<AreaUnit>(
                                value: _selectedAreaUnit,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                items: AreaUnit.values.map((u) {
                                  return DropdownMenuItem(
                                    value: u,
                                    child: Text(
                                      isArabic ? u.labelAr() : u.labelEn(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (u) {
                                  if (u != null) {
                                    setState(() => _selectedAreaUnit = u);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 4. Number of Trees
                CustomTextField(
                  label: AppStrings.treesCount(context),
                  hint: '2400',
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

                const SizedBox(height: 18),

                // 5. Crops Selector Chips
                Text(
                  AppStrings.cropsTypes(context),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cropSuggestions.map((crop) {
                    final isSelected = _selectedCrops.contains(crop);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(crop),
                      selectedColor:
                          AppColors.primaryGreen.withValues(alpha: 0.25),
                      checkmarkColor: AppColors.primaryGreenDark,
                      backgroundColor: isDark
                          ? AppColors.cardDark
                          : AppColors.backgroundLight,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primaryGreenDark
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                      onSelected: (_) => _toggleCrop(crop),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 8),

                // Add Custom Crop Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customCropController,
                        decoration: InputDecoration(
                          hintText: isArabic
                              ? 'إضافة محصول آخر...'
                              : 'Add custom crop...',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor:
                              isDark ? AppColors.cardDark : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.flowBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _addCustomCrop,
                      child: Text(isArabic ? 'إضافة' : 'Add'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 6. Irrigation Type Dropdown
                Text(
                  AppStrings.irrigationSystem(context),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<IrrigationType>(
                      value: _selectedIrrigationType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: IrrigationType.values.map((it) {
                        return DropdownMenuItem(
                          value: it,
                          child: Row(
                            children: [
                              Icon(it.icon(),
                                  size: 16, color: AppColors.primaryGreen),
                              const SizedBox(width: 8),
                              Text(
                                isArabic ? it.labelAr() : it.labelEn(),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (it) {
                        if (it != null) {
                          setState(() => _selectedIrrigationType = it);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 7. Water Source Dropdown
                Text(
                  AppStrings.waterSource(context),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<FarmWaterSource>(
                      value: _selectedWaterSource,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: FarmWaterSource.values.map((ws) {
                        return DropdownMenuItem(
                          value: ws,
                          child: Row(
                            children: [
                              Icon(ws.icon(),
                                  size: 16, color: AppColors.flowBlue),
                              const SizedBox(width: 8),
                              Text(
                                isArabic ? ws.labelAr() : ws.labelEn(),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (ws) {
                        if (ws != null) {
                          setState(() => _selectedWaterSource = ws);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 8. Solar Energy Checkbox Card
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      activeColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      secondary: const Icon(Icons.wb_sunny_rounded,
                          color: Color(0xFFF59E0B)),
                      title: Text(
                        AppStrings.solarPowerOption(context),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        isArabic
                            ? 'تحديد ما إذا كانت طلمبات الري تعمل بالطاقة الشمسية'
                            : 'Indicates if irrigation pumps run on solar arrays',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                      value: _hasSolarPower,
                      onChanged: (val) {
                        setState(() {
                          _hasSolarPower = val ?? true;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 9. Additional Notes
                CustomTextField(
                  label: AppStrings.additionalNotes(context),
                  hint: AppStrings.additionalNotesHint(context),
                  controller: _notesController,
                  maxLines: 3,
                  prefixIcon: Icons.notes_rounded,
                ),

                const SizedBox(height: 28),

                // Save Action
                CustomButton(
                  label: isEditing
                      ? AppStrings.save(context)
                      : AppStrings.create(context),
                  isLoading: _isSaving,
                  icon: Icons.check_circle_rounded,
                  onPressed: _onSave,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
