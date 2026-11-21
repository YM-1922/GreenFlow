import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/datasources/farms_mock_data_source.dart';
import '../../domain/entities/farm_entities.dart';
import '../widgets/farm_card.dart';
import '../widgets/farm_stats_overview.dart';

/// Main Farms Management Screen.
/// Provides commercial oversight of registered farms, summary metrics, filtering, and inspection links.
class FarmsListScreen extends StatefulWidget {
  final FarmsMockDataSource? dataSource;

  const FarmsListScreen({
    super.key,
    this.dataSource,
  });

  @override
  State<FarmsListScreen> createState() => _FarmsListScreenState();
}

class _FarmsListScreenState extends State<FarmsListScreen> {
  late final FarmsMockDataSource _dataSource;
  late List<FarmEntity> _farms;

  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? FarmsMockDataSource();
    _loadFarms();
  }

  void _loadFarms() {
    setState(() {
      _farms = _dataSource.getFarms();
    });
  }

  List<FarmEntity> get _filteredFarms {
    return _farms.where((farm) {
      final matchesSearch = _searchQuery.isEmpty ||
          farm.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farm.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farm.crops.any((c) =>
              c.toLowerCase().contains(_searchQuery.toLowerCase()));

      if (!matchesSearch) return false;

      if (_selectedFilter == 'active') {
        return farm.installationStatus == InstallationStatus.activeMonitoring;
      } else if (_selectedFilter == 'inspection') {
        return farm.installationStatus ==
                InstallationStatus.inspectionPending ||
            farm.installationStatus == InstallationStatus.inspectionCompleted;
      } else if (_selectedFilter == 'quotation') {
        return farm.installationStatus == InstallationStatus.quotationReady;
      }

      return true;
    }).toList();
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
          AppStrings.farmsTitle(context),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.trackInspectionRequests(context),
            icon: const Icon(Icons.assignment_outlined,
                color: AppColors.flowBlue),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.inspectionsList);
            },
          ),
          IconButton(
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadFarms,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          AppStrings.addFarm(context),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.farmAddEdit,
          );
          if (result == true) {
            _loadFarms();
          }
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async {
            _loadFarms();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Summary Stats Cards
                FarmStatsOverview(farms: _farms),

                const SizedBox(height: 18),

                // Inspection Callout Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.flowBlueDark,
                        AppColors.primaryGreenDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.flowBlueDark.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.solar_power_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic
                                      ? 'خدمة المعاينة والمقايسة الذكية'
                                      : 'Smart Farm Inspection & Quote',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isArabic
                                      ? 'اطلب زيارة مهندسينا لحساب الطاقة الشمسية ومحابس الري'
                                      : 'Field engineers calculate solar arrays & valve sizing',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.flowBlueDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.inspectionRequest);
                              },
                              child: Text(
                                AppStrings.requestTechnicalInspection(context),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.inspectionsList);
                            },
                            child: Text(
                              isArabic ? 'طلباتي' : 'Track',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Search Bar
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.searchFarmsHint(context),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.cardDark : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterPill(
                        label: isArabic ? 'جميع المزارع' : 'All Farms',
                        isSelected: _selectedFilter == 'all',
                        onTap: () => setState(() => _selectedFilter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: isArabic ? 'المراقبة النشطة' : 'Active IoT',
                        isSelected: _selectedFilter == 'active',
                        onTap: () => setState(() => _selectedFilter = 'active'),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: isArabic ? 'بانتظار المعاينة' : 'Inspection Pending',
                        isSelected: _selectedFilter == 'inspection',
                        onTap: () =>
                            setState(() => _selectedFilter = 'inspection'),
                      ),
                      const SizedBox(width: 8),
                      _FilterPill(
                        label: isArabic ? 'المقايسة جاهزة' : 'Quotation Ready',
                        isSelected: _selectedFilter == 'quotation',
                        onTap: () =>
                            setState(() => _selectedFilter = 'quotation'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Farm Cards List
                if (_filteredFarms.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.landscape_outlined,
                            size: 54,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? AppStrings.noFarmsFound(context)
                                : AppStrings.noFarmsYet(context),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ..._filteredFarms.map((farm) {
                    return FarmCard(
                      farm: farm,
                      onTap: () async {
                        final updated = await Navigator.pushNamed(
                          context,
                          AppRoutes.farmDetails,
                          arguments: farm.id,
                        );
                        if (updated == true) {
                          _loadFarms();
                        }
                      },
                    );
                  }),
                ],

                const SizedBox(height: 60), // Spacing for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
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
              ? AppColors.primaryGreen
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
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
      ),
    );
  }
}
