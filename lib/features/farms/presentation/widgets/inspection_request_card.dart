import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/farm_entities.dart';

/// Card widget displaying customer farm inspection requests and current workflow status.
class InspectionRequestCard extends StatelessWidget {
  final FarmInspectionRequestEntity request;
  final VoidCallback onTap;

  const InspectionRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusLabel =
        isArabic ? request.status.labelAr() : request.status.labelEn();

    final dateStr =
        '${request.submissionDate.day}/${request.submissionDate.month}/${request.submissionDate.year}';
    final visitDateStr = request.scheduledVisitDate != null
        ? '${request.scheduledVisitDate!.day}/${request.scheduledVisitDate!.month}/${request.scheduledVisitDate!.year}'
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row: Ref ID + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.flowBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          request.id,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.flowBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
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
                  label: statusLabel,
                  color: request.status.color(),
                  icon: request.status.icon(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Farm Name & Location
            Text(
              request.farmName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color:
                      isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.location,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Area, Trees & Water source info
            Row(
              children: [
                _InfoPill(
                  icon: Icons.square_foot_rounded,
                  label:
                      '${request.area.toStringAsFixed(0)} ${isArabic ? request.areaUnit.labelAr() : request.areaUnit.labelEn()}',
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _InfoPill(
                  icon: Icons.park_rounded,
                  label: '${request.treesCount} ${isArabic ? 'شجرة' : 'trees'}',
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoPill(
                    icon: request.waterSource.icon(),
                    label: isArabic
                        ? request.waterSource.labelAr()
                        : request.waterSource.labelEn(),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            if (visitDateStr != null || request.quotation != null) ...[
              const SizedBox(height: 12),
              Divider(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                height: 1,
              ),
              const SizedBox(height: 10),
            ],

            // Visit Date or Quotation Callout
            if (visitDateStr != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.event_available_rounded,
                    size: 14,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${isArabic ? 'موعد الزيارة المعتمد:' : 'Scheduled Visit:'} $visitDateStr',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],

            if (request.quotation != null) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 14,
                        color: AppColors.flowBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isArabic ? 'المقايسة جاهزة:' : 'Hardware Quote Ready:',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.flowBlue,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${request.quotation!.totalOneTimeFee.toStringAsFixed(0)} EGP',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.flowBlue,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 11,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
