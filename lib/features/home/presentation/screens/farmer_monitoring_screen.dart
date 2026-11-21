import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../farms/data/datasources/farms_mock_data_source.dart';
import '../../../farms/domain/entities/farm_entities.dart';
import '../../data/datasources/dashboard_mock_data_source.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Dedicated Farmer Monitoring Screen (Tab 3 in FarmerShell).
/// Provides in-depth telemetry for Soil Moisture, Root Depths, Plant Health,
/// Environmental Probes, and Connected IoT Nodes with real-time normal ranges and charts.
class FarmerMonitoringScreen extends StatefulWidget {
  const FarmerMonitoringScreen({super.key});

  @override
  State<FarmerMonitoringScreen> createState() => _FarmerMonitoringScreenState();
}

class _FarmerMonitoringScreenState extends State<FarmerMonitoringScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FarmsMockDataSource _farmsDataSource = FarmsMockDataSource();
  final DashboardMockDataSource _dashboardDataSource = const DashboardMockDataSource();

  late List<FarmEntity> _farms;
  late FarmEntity _selectedFarm;
  late EnvironmentalMetricEntity _metrics;
  late PlantHealthEntity _plantHealth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _farms = _farmsDataSource.getFarms();
    _selectedFarm = _farms.isNotEmpty ? _farms.first : _farmsDataSource.getFarms().first;
    _metrics = _dashboardDataSource.getEnvironmentalMetrics();
    _plantHealth = _dashboardDataSource.getPlantHealth();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.isArabic(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'مراقبة التربة والمناخ الزراعي' : 'Agri-Telemetry & Soil Monitoring',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          labelColor: AppColors.primaryGreen,
          tabs: [
            Tab(text: isAr ? 'رطوبة التربة' : 'Soil Moisture'),
            Tab(text: isAr ? 'صحة النبات' : 'Crop Health'),
            Tab(text: isAr ? 'عقد الاستشعار' : 'IoT Nodes'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Farm Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isDark ? AppColors.surfaceDark : Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.landscape_rounded, color: AppColors.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isAr ? 'المزرعة المعروضة:' : 'Active Farm:',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFarm.id,
                        isExpanded: true,
                        items: _farms.map((f) {
                          return DropdownMenuItem(
                            value: f.id,
                            child: Text(
                              f.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedFarm = _farms.firstWhere((f) => f.id == val);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Tab View Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Soil Moisture & Root Zones
                  _buildSoilTab(isDark, isAr),

                  // Tab 2: Crop Health & Canopy
                  _buildCropHealthTab(isDark, isAr),

                  // Tab 3: Hardware Nodes Telemetry
                  _buildNodesTelemetryTab(isDark, isAr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilTab(bool isDark, bool isAr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overall Soil Status Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'متوسط رطوبة منطقة الجذور (VWC)' : 'Root-Zone Volumetric Water Content',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAr ? 'نطاق مثالي (Optimal)' : 'Optimal Range',
                      style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${_metrics.soilMoisture.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAr ? 'المجال الطبيعي: 35% - 50%' : 'Target: 35% - 50%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (_metrics.soilMoisture / 100).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          isAr ? 'قراءات أعماق التربة المتعددة' : 'Multi-Depth Soil Root Layers',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),

        _buildDepthCard(
          depthEn: 'Surface Zone (15 - 25 cm)',
          depthAr: 'الطبقة السطحية للجذور (15 - 25 سم)',
          moisture: 42.5,
          temp: 26.4,
          salinityEc: 1.2,
          isDark: isDark,
          isAr: isAr,
        ),
        const SizedBox(height: 10),
        _buildDepthCard(
          depthEn: 'Deep Root Layer (50 - 75 cm)',
          depthAr: 'طبقة الجذور العميقة (50 - 75 سم)',
          moisture: 48.0,
          temp: 22.8,
          salinityEc: 1.5,
          isDark: isDark,
          isAr: isAr,
        ),
      ],
    );
  }

  Widget _buildDepthCard({
    required String depthEn,
    required String depthAr,
    required double moisture,
    required double temp,
    required double salinityEc,
    required bool isDark,
    required bool isAr,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isAr ? depthAr : depthEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricColumn(isAr ? 'الرطوبة' : 'Moisture', '$moisture%', Icons.water_drop_rounded, AppColors.flowBlue),
              _metricColumn(isAr ? 'الحرارة' : 'Temperature', '$temp °C', Icons.thermostat_rounded, Colors.orange),
              _metricColumn(isAr ? 'الملوحة (EC)' : 'Salinity EC', '$salinityEc dS/m', Icons.grain_rounded, Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCropHealthTab(bool isDark, bool isAr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'مؤشر صحة الغطاء النباتي (NDVI Index)' : 'Canopy & Vegetation Health Index',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                isAr
                  ? 'معدل الحيوية النباتية ومستوى الكلوروفيل عبر مجسات الأشعة تحت الحمراء.'
                  : 'Computed plant vigor and chlorophyll absorption via spectral sensing nodes.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _cropMetric(isAr ? 'كفاءة النمو' : 'Vigor Ratio', '${_plantHealth.overallHealthPercent.toStringAsFixed(1)}%', AppColors.primaryGreen),
                  _cropMetric(isAr ? 'نباتات سليمة' : 'Healthy Crops', '${_plantHealth.healthyCount}/${_plantHealth.totalCount}', Colors.orange),
                  _cropMetric(isAr ? 'تنبيهات إجهاد' : 'Attention Needed', '${_plantHealth.attentionCount}', AppColors.flowBlue),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cropMetric(String title, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
      ],
    );
  }

  Widget _buildNodesTelemetryTab(bool isDark, bool isAr) {
    final zones = _selectedFarm.zones;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          isAr ? 'عقد الاستشعار المتصلة بالمزرعة' : 'Connected Field IoT Nodes',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        ...zones.map((z) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: isDark ? AppColors.cardDark : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                child: const Icon(Icons.sensors_rounded, color: AppColors.primaryGreen, size: 20),
              ),
              title: Text(z.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(
                '${z.sensorNodesCount} Nodes • ${z.cropType} • ${isAr ? "رطوبة:" : "Moisture:"} ${z.soilMoisturePercentage}%',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Online', style: TextStyle(color: AppColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }),
      ],
    );
  }
}
