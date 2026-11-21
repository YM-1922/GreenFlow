import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/datasources/solar_mock_data_source.dart';
import '../../domain/entities/solar_entities.dart';

/// Solar Energy Monitor Screen – Phase 8.
/// Shows live solar generation, battery status, pump load, system alerts,
/// and daily / hourly energy analytics with multi-farm support.
class SolarScreen extends StatefulWidget {
  final String? initialFarmId;
  final SolarMockDataSource dataSource;

  const SolarScreen({
    super.key,
    this.initialFarmId,
    this.dataSource = const SolarMockDataSource(),
  });

  @override
  State<SolarScreen> createState() => _SolarScreenState();
}

class _SolarScreenState extends State<SolarScreen> {
  late String _selectedFarmId;
  late SolarPanelEntity _data;
  late List<Map<String, String>> _availableFarms;

  @override
  void initState() {
    super.initState();
    _availableFarms = widget.dataSource.getAvailableFarms();
    _selectedFarmId = widget.initialFarmId ?? _availableFarms.first['id']!;
    _loadSolarData();
  }

  void _loadSolarData() {
    setState(() {
      _data = widget.dataSource.getSolarData(_selectedFarmId);
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _loadSolarData();
  }

  void _onFarmSelected(String farmId) {
    if (_selectedFarmId == farmId) return;
    setState(() {
      _selectedFarmId = farmId;
      _loadSolarData();
    });
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
          isAr ? 'مراقبة الطاقة الشمسية' : 'Solar Energy Monitor',
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
              Icons.solar_power_rounded,
              color: Colors.amber.shade600,
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
            // 1. Farm Selection Header
            _buildFarmSelector(context, isAr, isDark, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 14),

            // 2. Hardware Simulation Notice
            _buildDemoBanner(isAr, isDark),
            const SizedBox(height: 14),

            // 3. Low Battery Warning (if applicable)
            if (_data.batteryPercent < 20) ...[
              _buildLowBatteryBanner(isAr),
              const SizedBox(height: 14),
            ],

            // 4. Hero Generation Card
            _buildHeroCard(context, isAr, isDark, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 14),

            // 5. 4 Stat Telemetry Cards
            _buildStatCards(context, isAr, isDark, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 14),

            // 6. Battery Level & Inverter Diagnostics
            _buildBatteryBar(context, isAr, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 14),

            // 7. Active Solar Alerts
            if (_data.activeAlerts.isNotEmpty) ...[
              _buildAlertsSection(context, isAr, isDark, cardColor, textPrimary, textSecondary),
              const SizedBox(height: 14),
            ],

            // 8. Hourly Generation vs Consumption Chart
            _buildHourlyChart(context, isAr, cardColor, textPrimary, textSecondary),
            const SizedBox(height: 14),

            // 9. 7-Day Historical Energy Trends
            _buildDailyHistorySection(context, isAr, cardColor, textPrimary, textSecondary),
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
              color: Colors.amber.shade600.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.location_on_rounded, color: Colors.amber.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'المزرعة المحددة للطاقة' : 'Monitored Solar Site',
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
                    items: _availableFarms.map((farm) {
                      return DropdownMenuItem<String>(
                        value: farm['id'],
                        child: Text(
                          isAr ? farm['nameAr']! : farm['nameEn']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) _onFarmSelected(val);
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

  Widget _buildDemoBanner(bool isAr, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF59E0B),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAr
                  ? 'بيانات الطاقة الشمسية محاكاة تجريبية – جاري ربط بوابات Modbus/RS485 للعاكس الشمسي'
                  : 'Simulated Solar Inverter Data – Ready for Modbus/RS485 Gateway Telemetry',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowBatteryBanner(bool isAr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade400),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAr ? '⚠ تحذير: البطارية أقل من 20% – تم تعليق الري التلقائي' : '⚠ Warning: Battery under 20% – Auto-irrigation paused',
              style: TextStyle(
                color: Colors.red.shade900,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    bool isAr,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD97706),
            const Color(0xFFEA580C),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade800.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isAr ? 'القدرة المولدة الحالية' : 'Current Solar Output',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _data.systemStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${_data.generationWatts.toStringAsFixed(0)} W',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _data.isCharging
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _data.isCharging
                                ? Icons.battery_charging_full_rounded
                                : Icons.battery_alert_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _data.isCharging
                                ? (isAr ? 'شحن البطارية نشط' : 'Charging Battery')
                                : (isAr ? 'تفريغ من الاحتياطي' : 'Discharging Reserve'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${isAr ? 'ذروة اليوم' : 'Peak'}: ${_data.peakWatts.toStringAsFixed(0)} W',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${isAr ? 'آخر تحديث للعاكس' : 'Last inverter update'}: ${_data.lastUpdated}',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(
            Icons.wb_sunny_rounded,
            size: 72,
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(
    BuildContext context,
    bool isAr,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final stats = [
      _StatItem(
        icon: Icons.battery_charging_full_rounded,
        iconColor: _data.batteryPercent > 50
            ? AppColors.primaryGreen
            : (_data.batteryPercent > 20 ? Colors.amber : Colors.red),
        label: isAr ? 'شحن البطارية' : 'Battery SoC',
        value: '${_data.batteryPercent.toStringAsFixed(0)}%',
      ),
      _StatItem(
        icon: Icons.electric_bolt_rounded,
        iconColor: Colors.amber.shade600,
        label: isAr ? 'إنتاج اليوم' : 'Daily Output',
        value: '${_data.dailyKwh} kWh',
      ),
      _StatItem(
        icon: Icons.water_drop_rounded,
        iconColor: AppColors.flowBlue,
        label: isAr ? 'حمل المضخة' : 'Pump Load',
        value: '${_data.pumpConsumptionWatts.toStringAsFixed(0)} W',
      ),
      _StatItem(
        icon: Icons.balance_rounded,
        iconColor: _data.netBalanceWatts >= 0 ? AppColors.primaryGreen : Colors.red,
        label: isAr ? 'صافي التوازن' : 'Net Surplus',
        value: '${_data.netBalanceWatts >= 0 ? '+' : ''}${_data.netBalanceWatts.toStringAsFixed(0)} W',
      ),
    ];

    return Row(
      children: stats.map((stat) {
        final isLast = stats.indexOf(stat) == stats.length - 1;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                Icon(stat.icon, color: stat.iconColor, size: 22),
                const SizedBox(height: 6),
                Text(
                  stat.value,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  stat.label,
                  style: TextStyle(color: textSecondary, fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBatteryBar(
    BuildContext context,
    bool isAr,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final pct = _data.batteryPercent / 100.0;
    final barColor = _data.batteryPercent > 50
        ? AppColors.primaryGreen
        : (_data.batteryPercent > 20 ? Colors.amber : Colors.red);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_std_rounded, color: barColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'حالة بنك البطاريات والمحول' : 'Battery Bank & Inverter',
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_data.batteryPercent.toStringAsFixed(1)}%  •  ${_data.batteryVoltage} V',
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${isAr ? 'حرارة المحول' : 'Inverter Temp'}: ${_data.inverterTempCelsius}°C',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _data.isCharging
                    ? (isAr ? 'معدل الشحن: مستقر' : 'State: Floating Charge')
                    : (isAr ? 'معدل التفريغ: نشط' : 'State: Active Discharge'),
                style: TextStyle(
                  color: _data.isCharging ? AppColors.primaryGreen : Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(
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
              Icon(Icons.notifications_active_rounded, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                isAr ? 'تنبيهات المنظومة الشمسية' : 'Solar System Alerts',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._data.activeAlerts.map((alert) {
            final isWarning = alert.severity == 'warning';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isWarning
                    ? const Color(0xFFFEF2F2)
                    : (isDark ? AppColors.surfaceDark : const Color(0xFFF0FDF4)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isWarning ? Colors.red.shade200 : AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isWarning ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                    color: isWarning ? Colors.red.shade700 : AppColors.primaryGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? alert.titleAr : alert.titleEn,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isWarning ? Colors.red.shade900 : textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAr ? alert.descriptionAr : alert.descriptionEn,
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHourlyChart(
    BuildContext context,
    bool isAr,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    const double chartHeight = 110;
    final allValues = _data.hourlyHistory.expand((p) => [p.generationW, p.consumptionW]).toList();
    final maxVal = allValues.isNotEmpty ? allValues.reduce((a, b) => a > b ? a : b) : 1000.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Colors.amber.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'الإنتاج والاستهلاك اللحظي بالساعة' : 'Hourly Generation vs Consumption',
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _legendDot(Colors.amber.shade600, isAr ? 'توليد شمسي (واط)' : 'Generation (W)'),
              const SizedBox(width: 16),
              _legendDot(AppColors.flowBlue, isAr ? 'استهلاك المضخة (واط)' : 'Pump Load (W)'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: chartHeight + 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _data.hourlyHistory.map((point) {
                final genH = maxVal > 0 ? (point.generationW / maxVal) * chartHeight : 0.0;
                final conH = maxVal > 0 ? (point.consumptionW / maxVal) * chartHeight : 0.0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 6,
                            height: genH,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade600,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Container(
                            width: 6,
                            height: conH,
                            decoration: BoxDecoration(
                              color: AppColors.flowBlue,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        point.hour.substring(0, 2),
                        style: TextStyle(fontSize: 8, color: textSecondary),
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

  Widget _buildDailyHistorySection(
    BuildContext context,
    bool isAr,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    if (_data.dailyHistory.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range_rounded, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'سجل الطاقة الأسبوعي (كيلوواط.ساعة)' : '7-Day Energy History (kWh)',
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: _data.dailyHistory.map((day) {
              final net = day.generatedKwh - day.consumedKwh;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        isAr ? day.dayNameAr : day.dayNameEn,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: (day.generatedKwh * 10).toInt(),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.amber.shade600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            flex: (day.consumedKwh * 10).toInt(),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.flowBlue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${day.generatedKwh}/${day.consumedKwh}',
                      style: TextStyle(fontSize: 10, color: textSecondary),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${net >= 0 ? '+' : ''}${net.toStringAsFixed(1)}',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: net >= 0 ? AppColors.primaryGreen : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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

class _StatItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}
