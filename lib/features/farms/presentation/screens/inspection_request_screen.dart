import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/datasources/farms_mock_data_source.dart';
import '../../domain/entities/farm_entities.dart';

/// Customer Technical Farm Inspection Request Screen.
/// Farmers submit requests for on-site engineering assessments, soil tests, and quotation sizing.
class InspectionRequestScreen extends StatefulWidget {
  final FarmEntity? initialFarm;
  final FarmsMockDataSource? dataSource;

  const InspectionRequestScreen({
    super.key,
    this.initialFarm,
    this.dataSource,
  });

  @override
  State<InspectionRequestScreen> createState() =>
      _InspectionRequestScreenState();
}

class _InspectionRequestScreenState extends State<InspectionRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  late final FarmsMockDataSource _dataSource;
  late final TextEditingController _customerNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _farmNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _areaController;
  late final TextEditingController _treesController;
  late final TextEditingController _cropsController;
  late final TextEditingController _notesController;

  late AreaUnit _areaUnit;
  late FarmWaterSource _waterSource;
  late IrrigationType _irrigationType;
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 4));

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? FarmsMockDataSource();
    final f = widget.initialFarm;

    _customerNameController =
        TextEditingController(text: 'م. أحمد المنشاوي');
    _phoneController = TextEditingController(text: '+20 100 123 4567');
    _farmNameController = TextEditingController(text: f?.name ?? 'مزرعة جديدة');
    _locationController = TextEditingController(text: f?.location ?? 'وادي النطرون');
    _areaController =
        TextEditingController(text: f != null ? '${f.area}' : '25');
    _treesController =
        TextEditingController(text: f != null ? '${f.treesCount}' : '1200');
    _cropsController =
        TextEditingController(text: f != null ? f.crops.join(', ') : 'زيتون، نخيل');
    _notesController = TextEditingController();

    _areaUnit = f?.areaUnit ?? AreaUnit.feddan;
    _waterSource = f?.waterSource ?? FarmWaterSource.deepWell;
    _irrigationType = f?.irrigationType ?? IrrigationType.drip;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _treesController.dispose();
    _cropsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPreferredDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryGreen,
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _preferredDate = picked;
      });
    }
  }

  void _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final newRefId =
        'INS-2026-${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}';

    final cropsList = _cropsController.text
        .split(RegExp(r'[,،]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final request = FarmInspectionRequestEntity(
      id: newRefId,
      farmId: widget.initialFarm?.id,
      farmName: _farmNameController.text.trim(),
      customerName: _customerNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      area: double.tryParse(_areaController.text.trim()) ?? 20.0,
      areaUnit: _areaUnit,
      treesCount: int.tryParse(_treesController.text.trim()) ?? 1000,
      cropTypes: cropsList.isNotEmpty ? cropsList : ['محاصيل متعددة'],
      waterSource: _waterSource,
      existingIrrigationSystem: _irrigationType,
      preferredInspectionDate: _preferredDate,
      submissionDate: DateTime.now(),
      status: InspectionStatus.pending,
      additionalNotes: _notesController.text.trim(),
    );

    _dataSource.submitInspectionRequest(request);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    _showSuccessConfirmation(newRefId);
  }

  void _showSuccessConfirmation(String refId) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryGreen,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.inspectionSubmittedTitle(context),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.flowBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${AppStrings.requestRefNumber(context)}: $refId',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.flowBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.inspectionSubmittedDesc(context),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: AppStrings.trackInspectionRequests(context),
                icon: Icons.assignment_turned_in_rounded,
                onPressed: () {
                  Navigator.pop(ctx); // Close modal
                  Navigator.pop(context); // Close request form
                  Navigator.pushNamed(context, AppRoutes.inspectionsList);
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Text(isArabic ? 'العودة' : 'Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dateFormatted =
        '${_preferredDate.day}/${_preferredDate.month}/${_preferredDate.year}';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          AppStrings.inspectionRequestTitle(context),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
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
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDark
                        : AppColors.primaryGreenSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppStrings.inspectionSubtitle(context),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textPrimaryLight,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Customer Contact Section
                Text(
                  isArabic ? 'بيانات التواصل' : 'Contact Information',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  label: AppStrings.customerName(context),
                  hint: 'م. أحمد المنشاوي',
                  controller: _customerNameController,
                  prefixIcon: Icons.person_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppStrings.fieldRequired(context);
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                CustomTextField(
                  label: AppStrings.phoneNumber(context),
                  hint: '+20 100 123 4567',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppStrings.fieldRequired(context);
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Farm Details Section
                Text(
                  isArabic ? 'بيانات المزرعة والحقل' : 'Farm & Parcel Data',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  label: AppStrings.farmName(context),
                  hint: AppStrings.farmNameHint(context),
                  controller: _farmNameController,
                  prefixIcon: Icons.landscape_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppStrings.fieldRequired(context);
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

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

                const SizedBox(height: 14),

                // Area and Unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        label: AppStrings.farmArea(context),
                        hint: '30',
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
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
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
                                value: _areaUnit,
                                isExpanded: true,
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
                                    setState(() => _areaUnit = u);
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

                const SizedBox(height: 14),

                CustomTextField(
                  label: AppStrings.treesCount(context),
                  hint: '1500',
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

                const SizedBox(height: 14),

                CustomTextField(
                  label: AppStrings.cropsTypes(context),
                  hint: isArabic ? 'زيتون، نخيل، موالح' : 'Olives, Palms, Citrus',
                  controller: _cropsController,
                  prefixIcon: Icons.energy_savings_leaf_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppStrings.fieldRequired(context);
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Water Source Dropdown
                Text(
                  AppStrings.waterSource(context),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    child: DropdownButton<FarmWaterSource>(
                      value: _waterSource,
                      isExpanded: true,
                      items: FarmWaterSource.values.map((ws) {
                        return DropdownMenuItem(
                          value: ws,
                          child: Text(
                            isArabic ? ws.labelAr() : ws.labelEn(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (ws) {
                        if (ws != null) {
                          setState(() => _waterSource = ws);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Preferred Inspection Date Picker Card
                Text(
                  AppStrings.preferredInspectionDate(context),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickPreferredDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: AppColors.flowBlue, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              dateFormatted,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          isArabic ? 'تغيير' : 'Change',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.flowBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                CustomTextField(
                  label: AppStrings.additionalNotes(context),
                  hint: AppStrings.additionalNotesHint(context),
                  controller: _notesController,
                  maxLines: 3,
                  prefixIcon: Icons.notes_rounded,
                ),

                const SizedBox(height: 28),

                // Submit Button
                CustomButton(
                  label: AppStrings.submitInspectionRequest(context),
                  isLoading: _isSubmitting,
                  icon: Icons.send_rounded,
                  onPressed: _onSubmit,
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
