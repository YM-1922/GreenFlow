import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/datasources/analytics_mock_data_source.dart';
import '../../domain/entities/analytics_entities.dart';

/// Comprehensive Commercial Telemetry & Irrigation Analytics Screen – Phase 9.
/// Visualizes water consumption, pump runtime, soil probe telemetry, and solar ROI.
class AnalyticsScreen extends StatefulWidget {
  final String? initialFarmId;
  final AnalyticsMockDataSource dataSource;

  const AnalyticsScreen({
    super.key,
    this.initialFarmId,
    this.dataSource = const AnalyticsMockDataSource(),
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late String _selectedFarmId;
  AnalyticsTimeframe _selectedTimeframe = AnalyticsTimeframe.weekly;
  late FarmAnalyticsEntity _analytics;
  late List<Map<String, String>> _availableFarms;

  @override
  void initState() {
    super.initState();
    _availableFarms = widget.dataSource.getAvailableFarms();
    _selectedFarmId = widget.initialFarmId ?? _availableFarms.first['id']!;
    _loadAnalytics();
  }

  void _loadAnalytics() {
    setState(() {
      _analytics = widget.dataSource.getAnalytics(
        farmId: _selectedFarmId,
        timeframe: _selectedTimeframe,
      );
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.pureWhite,
        elevation: 0,
        title: Text(
          isAr ? 'التحليلات والتقارير الذكية' : 'Agronomic Analytics',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: textPrimary),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.insights_rounded,
              color: AppColors.primaryGreen,
              size: 26,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // 1. Monitored Farm Site Selector
            _buildFarmSelector(context, isAr, isDark, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 12),

            // 2. Timeframe Segment Filter (Daily, Weekly, Monthly)
            _buildTimeframeFilter(context, isAr, isDark, cardColor, textPrimary),
            const SizedBox(height: 12),

            // 3. Clear Demo Data Notice
            _buildDemoNotice(isAr, isDark),
            const SizedBox(height: 14),

            // 4. Primary KPI Summary Cards
            _buildSummaryKpiGrid(context, isAr, isDark, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 14),

            // 5. Water Consumption Bar Chart
            _buildWaterConsumptionCard(context, isAr, isDark, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 14),

            // 6. Irrigation Duration and Frequency Card
            _buildIrrigationMetricsCard(context, isAr, isDark, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 14),

            // 7. Soil Moisture Multi-Depth Trends (25cm vs 50cm)
            _buildSoilMoistureTrendCard(context, isAr, isDark, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 14),

            // 8. Environmental Temperature and Humidity Trends
            _buildWeatherTrendCard(context, isAr, isDark, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 14),

            // 9. Solar Energy Production vs Consumption
            _buildSolarEnergyCard(context, isAr, isDark, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmSelector(
    BuildContext context,
    bool isAr,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.terrain_rounded, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'المزرعة المختارة للتحليل' : 'Selected Farm Site',
                  style: TextStyle(
                    fontSize: 10,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFarmId,
                    isExpanded: true,
                    isDense: true,
                    dropdownColor: cardColor,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                    items: _availableFarms.map((f) {
                      return DropdownMenuItem<String>(
                        value: f['id'],
                        child: Text(
                          isAr ? f['nameAr']! : f['nameEn']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedFarmId = val;
                          _loadAnalytics();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeFilter(
    BuildContext context,
    bool isAr,
    bool isDark,
    Color cardColor,
    Color textPrimary,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: AnalyticsTimeframe.values.map((tf) {
          final isSelected = _selectedTimeframe == tf;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeframe = tf;
                  _loadAnalytics();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isAr ? tf.labelAr() : tf.labelEn(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDemoNotice(bool isAr, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Colors.blueGrey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAr
                  ? '📊 تحليلات ومؤشرات بيئية مستمدة من محاكاة حساسات التربة وتدفق المياه'
                  : '📊 Visualized telemetry derived from IoT soil sensors and flow simulations',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white70 : Colors.blueGrey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryKpiGrid(
    BuildContext context,
    bool isAr,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final kpis = [
      _KpiItem(
        icon: Icons.water_drop_rounded,
        iconColor: AppColors.flowBlue,
        title: isAr ? 'إجمالي المياه' : 'Total Water',
        value: '${_analytics.totalWaterLiters.toStringAsFixed(0)} L',
        subtext: '${_analytics.waterSavedPercentage}% ${isAr ? 'توفير مياه' : 'Water saved'}',
        subtextColor: AppColors.primaryGreen,
      ),
      _KpiItem(
        icon: Icons.schedule_rounded,
        iconColor: const Color(0xFF06B6D4),
        title: isAr ? 'زمن التشغيل' : 'Pump Runtime',
        value: '${_analytics.totalIrrigationMinutes} min',
        subtext: '${_analytics.irrigationSessionsCount} ${isAr ? 'جلسات ري' : 'sessions'}',
        subtextColor: textSecondary,
      ),
      _KpiItem(
        icon: Icons.grass_rounded,
        iconColor: AppColors.primaryGreen,
        title: isAr ? 'متوسط الرطوبة' : 'Soil Moisture',
        value: '${_analytics.averageSoilMoisture.toStringAsFixed(1)}%',
        subtext: isAr ? 'نطاق مثالي' : 'Optimal Band',
        subtextColor: AppColors.primaryGreen,
      ),
      _KpiItem(
        icon: Icons.solar_power_rounded,
        iconColor: Colors.amber.shade700,
        title: isAr ? 'طاقة شمسية' : 'Solar Output',
        value: '${_analytics.solarGeneratedKwh.toStringAsFixed(1)} kWh',
        subtext: '+${_analytics.solarNetSurplusKwh.toStringAsFixed(1)} ${isAr ? 'فائض' : 'Surplus'}',
        subtextColor: _analytics.solarNetSurplusKwh >= 0 ? AppColors.primaryGreen : Colors.red,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: kpis.map((kpi) {
            return Container(
              width: cardWidth,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: kpi.iconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(kpi.icon, color: kpi.iconColor, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          kpi.title,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    kpi.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kpi.subtext,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kpi.subtextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildWaterConsumptionCard(
    BuildContext context,
    bool isAr,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    const double maxH = 85.0;
    final maxVal = _analytics.waterChartPoints.map((p) => p.value).fold<double>(1.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppColors.flowBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'منحنى استهلاك المياه الذكي (لتر)' : 'Water Consumption Distribution (L)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _analytics.waterChartPoints.map((point) {
                final barH = maxVal > 0 ? (point.value / maxVal) * maxH : 0.0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        point.value.toStringAsFixed(0),
                        style: TextStyle(fontSize: 9, color: textSecondary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 14,
                        height: barH.clamp(8.0, maxH),
                        decoration: BoxDecoration(
                          color: AppColors.flowBlue,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        point.label,
                        style: TextStyle(fontSize: 10, color: textSecondary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIrrigationMetricsCard(
    BuildContext context,
    bool isAr,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_rounded, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'كفاءة ومعدلات تدفق الري' : 'Irrigation Runtime & Flow Rates',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metricPill(
                isAr ? 'معدل التدفق' : 'Avg Flow Rate',
                '${_analytics.averageFlowRateLpm} L/min',
                textPrimary,
                textSecondary,
              ),
              const SizedBox(width: 10),
              _metricPill(
                isAr ? 'مدة الجلسة' : 'Avg Duration',
                '${(_analytics.totalIrrigationMinutes / (_analytics.irrigationSessionsCount > 0 ? _analytics.irrigationSessionsCount : 1)).toStringAsFixed(0)} min',
                textPrimary,
                textSecondary,
              ),
              const SizedBox(width: 10),
              _metricPill(
                isAr ? 'توفير الاستهلاك' : 'Water Saved',
                '${_analytics.waterSavedPercentage}%',
                AppColors.primaryGreen,
                textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricPill(String title, String value, Color valColor, Color labelColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: valColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: valColor),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 10, color: labelColor),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilMoistureTrendCard(
    BuildContext context,
    bool isAr,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.layers_rounded, color: const Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'سجل رطوبة التربة عبر الأعماق' : 'Soil Moisture by Depth (Top vs Deep)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _legendDot(const Color(0xFF8B5CF6), isAr ? 'عمق 25 سم (سطحي)' : '25 cm Depth'),
              const SizedBox(width: 14),
              _legendDot(AppColors.primaryGreen, isAr ? 'عمق 50 سم (جذري)' : '50 cm Depth'),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: _analytics.soilTrendPoints.map((p) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 38,
                      child: Text(
                        p.label,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (p.topMoisture / 100.0).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${p.topMoisture.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: textSecondary)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (p.deepMoisture / 100.0).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${p.deepMoisture.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: textSecondary)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherTrendCard(
    BuildContext context,
    bool isAr,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_queue_rounded, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'سجل الحرارة ورطوبة الجو الميدانية' : 'Field Temperature & Ambient Humidity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _analytics.weatherTrendPoints.map((p) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(p.label, style: TextStyle(fontSize: 10, color: textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        '${p.tempCelsius.toStringAsFixed(0)}°C',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.orange.shade700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.humidityPercent.toStringAsFixed(0)}% RH',
                        style: TextStyle(fontSize: 10, color: AppColors.flowBlue, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSolarEnergyCard(
    BuildContext context,
    bool isAr,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.solar_power_rounded, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'عائد وتوليد الطاقة الشمسية' : 'Solar Energy Production & Balance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isAr ? 'إجمالي التوليد' : 'Total Generation', style: TextStyle(fontSize: 11, color: textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    '${_analytics.solarGeneratedKwh} kWh',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.amber.shade700),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(isAr ? 'استهلاك المضخات' : 'Pump Load', style: TextStyle(fontSize: 11, color: textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    '${_analytics.solarConsumedKwh} kWh',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.flowBlue),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(isAr ? 'صافي التوفير' : 'Net Surplus', style: TextStyle(fontSize: 11, color: textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    '${_analytics.solarNetSurplusKwh >= 0 ? '+' : ''}${_analytics.solarNetSurplusKwh} kWh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _analytics.solarNetSurplusKwh >= 0 ? AppColors.primaryGreen : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _KpiItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtext;
  final Color subtextColor;

  const _KpiItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtext,
    required this.subtextColor,
  });
}
