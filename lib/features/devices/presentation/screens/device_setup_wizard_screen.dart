import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/datasources/devices_mock_data_source.dart';
import '../../domain/entities/device_entities.dart';

/// Interactive 4-step wizard for pairing and commissioning ESP32 gateways,
/// LoRa soil probes, and relay actuator hardware modules.
class DeviceSetupWizardScreen extends StatefulWidget {
  const DeviceSetupWizardScreen({super.key});

  @override
  State<DeviceSetupWizardScreen> createState() =>
      _DeviceSetupWizardScreenState();
}

class _DeviceSetupWizardScreenState extends State<DeviceSetupWizardScreen> {
  int _currentStep = 0;
  DeviceCategory _selectedCategory = DeviceCategory.centralGateway;
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedFarm = 'مزرعة الأمل للزيتون والنخيل';
  String _selectedZone = 'المنطقة أ - زيتون شرقي';

  final List<String> _farmOptions = [
    'مزرعة الأمل للزيتون والنخيل',
    'واحة النخيل الذكية - الفرافرة',
    'مزرعة النور لإنتاج الخضروات العضوية',
  ];

  final List<String> _zoneOptions = [
    'المنطقة أ - زيتون شرقي',
    'المنطقة ب - نخيل البرحي',
    'المنطقة ج - صوب الطماطم والخيار',
    'محطة الرفع والتسميد الرئيسية',
  ];

  @override
  void dispose() {
    _serialController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep == 1) {
      if (_serialController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(AppStrings.serialRequired(context)),
          ),
        );
        return;
      }
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _activateDevice();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _activateDevice() {
    final isArabic = AppStrings.isArabic(context);
    final serial = _serialController.text.trim().isEmpty
        ? 'GF-ESP32-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
        : _serialController.text.trim();

    final name = _nameController.text.trim().isEmpty
        ? (isArabic
            ? '${_selectedCategory.labelAr()} - $_selectedZone'
            : '${_selectedCategory.labelEn()} - $_selectedZone')
        : _nameController.text.trim();

    final newDevice = Esp32DeviceEntity(
      id: 'dev-${DateTime.now().millisecondsSinceEpoch}',
      serialNumber: serial,
      name: name,
      category: _selectedCategory,
      farmId: 'farm-001',
      farmName: _selectedFarm,
      zoneId: 'zone-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
      zoneName: _selectedZone,
      status: DeviceConnectionStatus.online,
      lastSeen: DateTime.now(),
      firmwareVersion: 'v2.4.2-OTA',
      rssiSignalDbm: -64,
      batteryPercent: 100,
      batteryVoltage: 12.6,
      ipAddress: '192.168.1.${140 + (_currentStep * 5)}',
      macAddress: '24:6F:28:B4:7C:E$_currentStep',
      soilMoistureTop25cm: _selectedCategory == DeviceCategory.soilProbeNode
          ? 42.0
          : null,
      soilMoistureDeep50cm: _selectedCategory == DeviceCategory.soilProbeNode
          ? 46.5
          : null,
      soilTemperatureCelsius: _selectedCategory == DeviceCategory.soilProbeNode
          ? 22.8
          : null,
      waterLevelMeters: _selectedCategory == DeviceCategory.waterLevelSensor
          ? 38.5
          : null,
    );

    DevicesMockDataSource().registerDevice(newDevice);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(AppStrings.deviceAddedDemo(context)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          AppStrings.deviceSetupWizard(context),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              if (_currentStep > 0) ...[
                Expanded(
                  child: CustomButton(
                    key: const Key('wizard_back_btn'),
                    label: AppStrings.back(context),
                    isOutlined: true,
                    onPressed: _back,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: CustomButton(
                  key: const Key('wizard_continue_btn'),
                  label: _currentStep == 3
                      ? AppStrings.activate(context)
                      : AppStrings.next(context),
                  icon: _currentStep == 3
                      ? Icons.check_circle_outline_rounded
                      : Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _next,
          onStepCancel: _back,
          controlsBuilder: (context, details) => const SizedBox.shrink(),
          steps: [
            // Step 1: Select Category
            Step(
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              title: Text(
                AppStrings.chooseCategory(context),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              content: Column(
                children: DeviceCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen.withValues(alpha: 0.12)
                            : (isDark ? AppColors.cardDark : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            cat.icon(),
                            color: isSelected
                                ? AppColors.primaryGreen
                                : (isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isArabic ? cat.labelAr() : cat.labelEn(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Step 2: Serial Number & QR Scanner
            Step(
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              title: Text(
                AppStrings.enterSerial(context),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _serialController,
                    decoration: InputDecoration(
                      labelText: AppStrings.serialNumber(context),
                      hintText: 'GF-ESP32-GW-XXXX-XXX',
                      prefixIcon: const Icon(Icons.qr_code_rounded),
                      filled: true,
                      fillColor: isDark ? AppColors.cardDark : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'اسم الجهاز المخصص (اختياري)' : 'Custom Device Name',
                      hintText: isArabic ? 'مثال: مجس قطاع الزيتون رقم 3' : 'e.g. North Olive Sector Probe',
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                      filled: true,
                      fillColor: isDark ? AppColors.cardDark : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: AppStrings.simulateQrScan(context),
                    icon: Icons.camera_alt_rounded,
                    isOutlined: true,
                    onPressed: () {
                      setState(() {
                        _serialController.text =
                            'GF-ESP32-DEMO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                      });
                    },
                  ),
                ],
              ),
            ),

            // Step 3: Assign Farm & Zone
            Step(
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              title: Text(
                AppStrings.assignFarm(context),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              content: Column(
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedFarm,
                    decoration: InputDecoration(
                      labelText: AppStrings.selectFarm(context),
                      filled: true,
                      fillColor: isDark ? AppColors.cardDark : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _farmOptions
                        .map((f) => DropdownMenuItem(
                              value: f,
                              child: Text(
                                f,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedFarm = v);
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedZone,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'القطاع / الحوض' : 'Zone / Plot',
                      filled: true,
                      fillColor: isDark ? AppColors.cardDark : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _zoneOptions
                        .map((z) => DropdownMenuItem(
                              value: z,
                              child: Text(
                                z,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedZone = v);
                    },
                  ),
                ],
              ),
            ),

            // Step 4: Confirm & Activate
            Step(
              isActive: _currentStep >= 3,
              state: StepState.indexed,
              title: Text(
                AppStrings.confirmActivate(context),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _summaryRow(
                      label: AppStrings.category(context),
                      value: isArabic
                          ? _selectedCategory.labelAr()
                          : _selectedCategory.labelEn(),
                      isDark: isDark,
                    ),
                    _summaryRow(
                      label: AppStrings.serialNumber(context),
                      value: _serialController.text.trim().isEmpty
                          ? 'Auto-generated'
                          : _serialController.text.trim(),
                      isDark: isDark,
                    ),
                    _summaryRow(
                      label: AppStrings.farm(context),
                      value: _selectedFarm,
                      isDark: isDark,
                    ),
                    _summaryRow(
                      label: isArabic ? 'القطاع' : 'Zone',
                      value: _selectedZone,
                      isDark: isDark,
                      isLast: true,
                    ),
                    const Divider(height: 24),
                    Text(
                      AppStrings.reviewInfo(context),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    required bool isDark,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
