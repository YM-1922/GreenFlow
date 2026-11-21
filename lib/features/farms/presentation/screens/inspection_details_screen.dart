import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/datasources/farms_mock_data_source.dart';
import '../../domain/entities/farm_entities.dart';
import '../widgets/inspection_stepper.dart';

/// Detailed view of a Farm Inspection Request & Hardware Quotation breakdown.
class InspectionDetailsScreen extends StatefulWidget {
  final String requestId;
  final FarmsMockDataSource? dataSource;

  const InspectionDetailsScreen({
    super.key,
    required this.requestId,
    this.dataSource,
  });

  @override
  State<InspectionDetailsScreen> createState() =>
      _InspectionDetailsScreenState();
}

class _InspectionDetailsScreenState extends State<InspectionDetailsScreen> {
  late final FarmsMockDataSource _dataSource;
  FarmInspectionRequestEntity? _request;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? FarmsMockDataSource();
    _loadRequest();
  }

  void _loadRequest() {
    setState(() {
      _request = _dataSource.getInspectionRequestById(widget.requestId);
    });
  }

  void _onAcceptQuotation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.isArabic(context)
                    ? 'تم قبول المقايسة المبدئية بنجاح! سيتواصل معك ممثل التعاقدات لتحديد موعد التركيب.'
                    : 'Quotation accepted! Our operations team will contact you to schedule installation.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_request == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.inspectionDetailsTitle(context))),
        body: Center(
          child: Text(isArabic ? 'الطلب غير موجود' : 'Request not found'),
        ),
      );
    }

    final req = _request!;
    final dateStr =
        '${req.submissionDate.day}/${req.submissionDate.month}/${req.submissionDate.year}';
    final visitDateStr = req.scheduledVisitDate != null
        ? '${req.scheduledVisitDate!.day}/${req.scheduledVisitDate!.month}/${req.scheduledVisitDate!.year}'
        : null;

    final areaUnitLabel =
        isArabic ? req.areaUnit.labelAr() : req.areaUnit.labelEn();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '${req.id} • ${req.farmName}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Overview Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.flowBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            req.id,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.flowBlue,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: isArabic
                              ? req.status.labelAr()
                              : req.status.labelEn(),
                          color: req.status.color(),
                          icon: req.status.icon(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      req.farmName,
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
                        Icon(Icons.location_on_rounded,
                            size: 14,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            req.location,
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

                    const SizedBox(height: 14),

                    // Metrics row
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryBox(
                            title: AppStrings.customerName(context),
                            value: req.customerName,
                            icon: Icons.person_rounded,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryBox(
                            title: AppStrings.phoneNumber(context),
                            value: req.phoneNumber,
                            icon: Icons.phone_rounded,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _SummaryBox(
                            title: AppStrings.farmArea(context),
                            value:
                                '${req.area.toStringAsFixed(0)} $areaUnitLabel',
                            icon: Icons.square_foot_rounded,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryBox(
                            title: AppStrings.treesCount(context),
                            value: '${req.treesCount}',
                            icon: Icons.park_rounded,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Submission & Scheduled Date Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${isArabic ? 'تاريخ التقديم:' : 'Submitted:'} $dateStr',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                        if (visitDateStr != null)
                          Text(
                            '${isArabic ? 'الزيارة المجدولة:' : 'Scheduled:'} $visitDateStr',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Visual Workflow Progression Stepper
              InspectionWorkflowStepper(currentStatus: req.status),

              // 3. Field Engineer Notes Card (if present)
              if (req.engineerNotes != null &&
                  req.engineerNotes!.isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDark
                        : AppColors.primaryGreenSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.engineering_rounded,
                              color: AppColors.primaryGreen, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.fieldEngineerNotes(context),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        req.engineerNotes!,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 4. Quotation Breakdown Section (Prepared for Future Quotation Workflow)
              if (req.quotation != null) ...[
                const SizedBox(height: 20),
                _QuotationBreakdownCard(
                  quotation: req.quotation!,
                  onAccept: _onAcceptQuotation,
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isDark;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card presenting the itemized hardware bill of materials and monthly subscription plan.
class _QuotationBreakdownCard extends StatelessWidget {
  final InspectionQuotationEntity quotation;
  final VoidCallback onAccept;

  const _QuotationBreakdownCard({
    required this.quotation,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.flowBlue.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.flowBlue.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Quotation Number & Tier Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.flowBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.flowBlue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppStrings.customizedQuotation(context),
                        style: TextStyle(
                          fontSize: 15,
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
              Text(
                quotation.quotationNumber,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.flowBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            AppStrings.hardwareItems(context),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),

          const SizedBox(height: 8),

          // Hardware items list
          ...quotation.hardwareItems.map((item) {
            final itemName = isArabic ? item.nameAr : item.nameEn;
            final itemCat = isArabic ? item.categoryAr : item.categoryEn;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          itemCat,
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.quantity}x • ${item.totalPrice.toStringAsFixed(0)} EGP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 14),

          // Total One-Time Fee Card (Hardware + Installation)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.flowBlueSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.flowBlue.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.oneTimeHardwareCost(context),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isArabic
                            ? 'شامل التوريد، التركيب، والضمان لمدة عامين'
                            : 'Includes delivery, setup & 2-year warranty',
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${quotation.totalOneTimeFee.toStringAsFixed(0)} EGP',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.flowBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Recurring Monthly IoT Subscription Plan Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.primaryGreenSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.monthlySubscriptionCost(context),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isArabic
                            ? quotation.subscriptionTierAr
                            : quotation.subscriptionTierEn,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreenDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      quotation.monthlySubscriptionFee.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isArabic ? 'ج.م/شهر' : 'EGP/mo',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Configurable pricing notice
          Text(
            AppStrings.quotationPricingNotice(context),
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Action Button
          CustomButton(
            label: AppStrings.acceptQuotation(context),
            icon: Icons.thumb_up_rounded,
            onPressed: onAccept,
          ),
        ],
      ),
    );
  }
}
