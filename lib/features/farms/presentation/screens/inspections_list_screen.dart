import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/datasources/farms_mock_data_source.dart';
import '../../domain/entities/farm_entities.dart';
import '../widgets/inspection_request_card.dart';

/// Screen listing customer farm inspection requests with status filtering.
class InspectionsListScreen extends StatefulWidget {
  final FarmsMockDataSource? dataSource;

  const InspectionsListScreen({
    super.key,
    this.dataSource,
  });

  @override
  State<InspectionsListScreen> createState() => _InspectionsListScreenState();
}

class _InspectionsListScreenState extends State<InspectionsListScreen> {
  late final FarmsMockDataSource _dataSource;
  late List<FarmInspectionRequestEntity> _requests;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? FarmsMockDataSource();
    _loadRequests();
  }

  void _loadRequests() {
    setState(() {
      _requests = _dataSource.getInspectionRequests();
    });
  }

  List<FarmInspectionRequestEntity> get _filteredRequests {
    if (_selectedFilter == 'pending') {
      return _requests
          .where((r) =>
              r.status == InspectionStatus.pending ||
              r.status == InspectionStatus.underReview)
          .toList();
    } else if (_selectedFilter == 'scheduled') {
      return _requests
          .where((r) => r.status == InspectionStatus.scheduled)
          .toList();
    } else if (_selectedFilter == 'quotation') {
      return _requests
          .where((r) =>
              r.status == InspectionStatus.quotationPending ||
              r.status == InspectionStatus.approved)
          .toList();
    }
    return _requests;
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
          AppStrings.inspectionListTitle(context),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadRequests,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.flowBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          isArabic ? 'طلب معاينة جديد' : 'New Inspection',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.inspectionRequest);
          _loadRequests();
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.flowBlue,
          onRefresh: () async {
            _loadRequests();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter Tabs Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterTab(
                        label: AppStrings.allRequests(context),
                        isSelected: _selectedFilter == 'all',
                        count: _requests.length,
                        onTap: () => setState(() => _selectedFilter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: AppStrings.pendingRequests(context),
                        isSelected: _selectedFilter == 'pending',
                        count: _requests
                            .where((r) =>
                                r.status == InspectionStatus.pending ||
                                r.status == InspectionStatus.underReview)
                            .length,
                        onTap: () => setState(() => _selectedFilter = 'pending'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: AppStrings.scheduledRequests(context),
                        isSelected: _selectedFilter == 'scheduled',
                        count: _requests
                            .where((r) =>
                                r.status == InspectionStatus.scheduled)
                            .length,
                        onTap: () =>
                            setState(() => _selectedFilter = 'scheduled'),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: AppStrings.quotationReadyRequests(context),
                        isSelected: _selectedFilter == 'quotation',
                        count: _requests
                            .where((r) =>
                                r.status == InspectionStatus.quotationPending ||
                                r.status == InspectionStatus.approved)
                            .length,
                        onTap: () =>
                            setState(() => _selectedFilter = 'quotation'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Requests List
                if (_filteredRequests.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 52,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isArabic
                                ? 'لا توجد طلبات معاينة في هذا التصنيف'
                                : 'No inspection requests found in this category',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ..._filteredRequests.map((request) {
                    return InspectionRequestCard(
                      request: request,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.inspectionDetails,
                          arguments: request.id,
                        );
                      },
                    );
                  }),
                ],

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.flowBlue
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.flowBlue
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : (isDark ? AppColors.surfaceDark : AppColors.backgroundLight),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.flowBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
