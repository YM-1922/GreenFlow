import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/farm_entities.dart';

/// Stepper widget displaying the 6-stage engineering and quotation workflow progression.
class InspectionWorkflowStepper extends StatelessWidget {
  final InspectionStatus currentStatus;

  const InspectionWorkflowStepper({
    super.key,
    required this.currentStatus,
  });

  int _getStatusStepIndex(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.pending:
        return 0;
      case InspectionStatus.underReview:
        return 1;
      case InspectionStatus.scheduled:
        return 2;
      case InspectionStatus.inspectionCompleted:
        return 3;
      case InspectionStatus.quotationPending:
        return 4;
      case InspectionStatus.approved:
        return 5;
      case InspectionStatus.rejected:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStep = _getStatusStepIndex(currentStatus);

    final steps = [
      _StepInfo(
        titleEn: 'Request Submitted',
        titleAr: 'تم تقديم الطلب',
        descEn: 'Farm telemetry & parcel data logged',
        descAr: 'تم تسجيل بيانات الحقل والمساحة',
      ),
      _StepInfo(
        titleEn: 'Engineering Review',
        titleAr: 'مراجعة الفريق الفني',
        descEn: 'Water pressure & terrain assessment',
        descAr: 'تقييم مصادر المياه وطبوغرافيا المزرعة',
      ),
      _StepInfo(
        titleEn: 'Visit Scheduled',
        titleAr: 'تحديد موعد الزيارة',
        descEn: 'Field engineer assigned for on-site visit',
        descAr: 'تنسيق وصول المهندس الميداني للحقل',
      ),
      _StepInfo(
        titleEn: 'Field Inspection',
        titleAr: 'المعاينة الحقلية',
        descEn: 'Soil probes test & solar exposure check',
        descAr: 'فحص ملوحة التربة ومناسيب البئر وسطوع الشمس',
      ),
      _StepInfo(
        titleEn: 'Quotation Prepared',
        titleAr: 'إعداد المقايسة',
        descEn: 'Hardware bill of quantities & solar sizing',
        descAr: 'تحديد مستشعرات ESP32 وقدرة الألواح',
      ),
      _StepInfo(
        titleEn: 'Contract & Installation',
        titleAr: 'التعاقد والتنفيذ',
        descEn: 'One-time setup & monthly IoT plan active',
        descAr: 'بدء تركيب العتاد وتفعيل المراقبة الذكية',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.flowBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: AppColors.flowBlue,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.engineeringProgress(context),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Vertical Step Progression
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              final isDone = index < currentStep;
              final isCurrent = index == currentStep;
              final isLast = index == steps.length - 1;

              Color nodeColor;
              if (isDone) {
                nodeColor = AppColors.sensorOnline;
              } else if (isCurrent) {
                nodeColor = currentStatus == InspectionStatus.rejected
                    ? AppColors.sensorAlert
                    : AppColors.flowBlue;
              } else {
                nodeColor =
                    isDark ? AppColors.borderDark : AppColors.borderLight;
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Node Circle & Line
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone || isCurrent
                                ? nodeColor
                                : Colors.transparent,
                            border: Border.all(
                              color: nodeColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
                                : (isCurrent
                                    ? Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: isDone
                                  ? AppColors.sensorOnline
                                  : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // Step Text Description
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? step.titleAr : step.titleEn,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isCurrent || isDone
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isCurrent
                                    ? nodeColor
                                    : (isDone
                                        ? (isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight)
                                        : (isDark
                                            ? AppColors.textMutedDark
                                            : AppColors.textMutedLight)),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isArabic ? step.descAr : step.descEn,
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
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StepInfo {
  final String titleEn;
  final String titleAr;
  final String descEn;
  final String descAr;

  const _StepInfo({
    required this.titleEn,
    required this.titleAr,
    required this.descEn,
    required this.descAr,
  });
}
