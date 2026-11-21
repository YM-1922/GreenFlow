import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/connectivity_banner.dart';
import '../../../../features/notifications/data/datasources/notifications_mock_data_source.dart';
import '../../data/datasources/dashboard_mock_data_source.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/environmental_monitoring_section.dart';
import '../widgets/farm_summary_section.dart';
import '../widgets/irrigation_control_card.dart';
import '../widgets/plant_health_section.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/recent_activities_timeline.dart';
import '../widgets/water_consumption_chart.dart';

/// Farmer Home Content (hosted on Tab 0 inside the persistent FarmerShell).
class FarmerHomeContent extends StatefulWidget {
  final DashboardMockDataSource dataSource;

  const FarmerHomeContent({
    super.key,
    this.dataSource = const DashboardMockDataSource(),
  });

  @override
  State<FarmerHomeContent> createState() => _FarmerHomeContentState();
}

class _FarmerHomeContentState extends State<FarmerHomeContent> {
  final NotificationsMockDataSource _notificationsSource = NotificationsMockDataSource();

  late FarmSummaryEntity _farmSummary;
  late EnvironmentalMetricEntity _environmentalMetrics;
  late IrrigationStatusEntity _irrigationStatus;
  late PlantHealthEntity _plantHealth;
  late WaterAnalyticsEntity _waterAnalytics;
  late List<FarmActivityEntity> _recentActivities;

  @override
  void initState() {
    super.initState();
    _notificationsSource.addListener(_onNotificationsChanged);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _notificationsSource.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  void _loadDashboardData() {
    _farmSummary = widget.dataSource.getFarmSummary();
    _environmentalMetrics = widget.dataSource.getEnvironmentalMetrics();
    _irrigationStatus = widget.dataSource.getIrrigationStatus();
    _plantHealth = widget.dataSource.getPlantHealth();
    _waterAnalytics = widget.dataSource.getWaterAnalytics();
    _recentActivities = widget.dataSource.getRecentActivities();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _loadDashboardData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          AppStrings.isArabic(context)
              ? 'تم تحديث بيانات الاستشعار وقراءات المزرعة'
              : 'Farm telemetry and sensor data refreshed',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Dashboard Header
                DashboardHeader(unreadNotificationsCount: _notificationsSource.unreadCount),

                // Offline / Online Connectivity Banner
                const ConnectivityBanner(),
                const SizedBox(height: 12),

                // 2. Farm Summary Section (Total Farms, Trees, IoT Nodes, Overall Health)
                FarmSummarySection(summary: _farmSummary),
                const SizedBox(height: 24),

                // 3. Environmental Monitoring (Soil Moisture, Temperature, Humidity, Water)
                EnvironmentalMonitoringSection(metrics: _environmentalMetrics),
                const SizedBox(height: 24),

                // 4. Interactive Smart Irrigation Actuator Control Card
                IrrigationControlCard(
                  initialStatus: _irrigationStatus,
                  onStatusChanged: (updated) {
                    setState(() {
                      _irrigationStatus = updated;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // 5. Plant & Crop Health Breakdown
                PlantHealthSection(health: _plantHealth),
                const SizedBox(height: 24),

                // 6. Water Consumption Analytics Weekly Chart
                WaterConsumptionChart(analytics: _waterAnalytics),
                const SizedBox(height: 24),

                // 7. Recent Farm Activities Timeline
                RecentActivitiesTimeline(activities: _recentActivities),
                const SizedBox(height: 24),

                // 8. Quick Access Modules Grid
                const QuickAccessGrid(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
