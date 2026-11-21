import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/datasources/farms_mock_data_source.dart';
import '../../domain/entities/farm_entities.dart';

/// Farmer Installation Progress & Field Commissioning Tracker.
/// Displays an interactive step-by-step progress timeline of the on-site IoT setup.
class FarmerInstallationScreen extends StatefulWidget {
  final String? farmId;

  const FarmerInstallationScreen({super.key, this.farmId});

  @override
  State<FarmerInstallationScreen> createState() => _FarmerInstallationScreenState();
}

class _FarmerInstallationScreenState extends State<FarmerInstallationScreen> {
  final FarmsMockDataSource _farmsDataSource = FarmsMockDataSource();
  late FarmEntity _farm;

  @override
  void initState() {
    super.initState();
    final farms = _farmsDataSource.getFarms();
    _farm = widget.farmId != null
        ? (_farmsDataSource.getFarmById(widget.farmId!) ?? farms.first)
        : farms.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.isArabic(context);

    final steps = [
      _InstallationStep(
        titleEn: '1. Technical Site Survey & Soil Test',
        titleAr: '١. المعاينة الميدانية وفحص أعماق التربة',
        descEn: 'Completed by Field Engineer Kareem. Root depth parameters configured.',
        descAr: 'تمت المعاينة بنجاح بواسطة م. كريم. تم تحديد أعماق الجذور ونقاط المحابس.',
        isCompleted: true,
      ),
      _InstallationStep(
        titleEn: '2. Commercial Quotation & Billing',
        titleAr: '٢. المقايسة الفنية وسداد الفاتورة',
        descEn: 'Quotation accepted and installation invoice settled via InstaPay.',
        descAr: 'تم قبول المقايسة وسداد فاتورة التركيب بنجاح.',
        isCompleted: true,
      ),
      _InstallationStep(
        titleEn: '3. Hardware Mounting & Valve Wiring',
        titleAr: '٣. تركيب المحابس والكابلات المعزولة',
        descEn: 'Industrial 2" solenoid valves mounted at eastern zone lines.',
        descAr: 'تم تركيب محابس النايلون 2 بوصة وتمديد الأسلاك المعزولة تحت الأرض.',
        isCompleted: true,
      ),
      _InstallationStep(
        titleEn: '4. ESP32 Gateway & Solar Inverter Pairing',
        titleAr: '٤. ربط بوابة ESP32 وإنفرتر الطاقة الشمسية',
        descEn: 'Gateway antenna calibrated. Real-time telemetry transmitting via LoRa.',
        descAr: 'تم تثبيت هوائي البوابة والمزامنة اللحظية مع منظومة الطاقة الشمسية.',
        isCompleted: true,
      ),
      _InstallationStep(
        titleEn: '5. Automated Monitoring & Farmer Handover',
        titleAr: '٥. التفعيل النهائي وتسليم النظام للمزارع',
        descEn: 'System online. Closed-loop smart irrigation algorithms active.',
        descAr: 'المنظومة متصلة بالكامل، وخوارزميات الري الآلي تعمل بكفاءة.',
        isCompleted: _farm.installationStatus == InstallationStatus.activeMonitoring,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'متابعة مسار التركيب والتشغيل' : 'IoT Installation Tracker',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFECFDF5), Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.handyman_rounded, color: AppColors.primaryGreen, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_farm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            '${isAr ? "الحالة التشغيلية:" : "Status:"} ${isAr ? _farm.installationStatus.labelAr() : _farm.installationStatus.labelEn()}',
                            style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                isAr ? 'مراحل التركيب الميداني المكتملة' : 'Field Commissioning Milestones',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 14),

              // Timeline Steps
              ...List.generate(steps.length, (index) {
                final s = steps[index];
                final isLast = index == steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.isCompleted ? AppColors.primaryGreen : Colors.grey.shade400,
                          ),
                          child: Icon(
                            s.isCompleted ? Icons.check_rounded : Icons.hourglass_top_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 52,
                            color: s.isCompleted ? AppColors.primaryGreen : Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? s.titleAr : s.titleEn,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: s.isCompleted ? null : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAr ? s.descAr : s.descEn,
                              style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstallationStep {
  final String titleEn;
  final String titleAr;
  final String descEn;
  final String descAr;
  final bool isCompleted;

  _InstallationStep({
    required this.titleEn,
    required this.titleAr,
    required this.descEn,
    required this.descAr,
    required this.isCompleted,
  });
}
