import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/datasources/devices_mock_data_source.dart';
import '../../domain/entities/device_entities.dart';
import '../widgets/device_card.dart';
import '../widgets/hardware_safety_card.dart';

/// Screen displaying the registered ESP32 controllers, LoRa soil probes, and actuators.
class DevicesListScreen extends StatefulWidget {
  final DevicesMockDataSource? dataSource;

  const DevicesListScreen({
    super.key,
    this.dataSource,
  });

  @override
  State<DevicesListScreen> createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  late final DevicesMockDataSource _dataSource;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? DevicesMockDataSource();
    _dataSource.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataSource.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  List<Esp32DeviceEntity> get _filteredDevices {
    final all = _dataSource.getDevices();
    if (_selectedCategory == 'gateway') {
      return all
          .where((d) => d.category == DeviceCategory.centralGateway)
          .toList();
    } else if (_selectedCategory == 'probe') {
      return all
          .where((d) => d.category == DeviceCategory.soilProbeNode)
          .toList();
    } else if (_selectedCategory == 'actuator') {
      return all
          .where((d) => d.category == DeviceCategory.solenoidRelayModule)
          .toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final all = _dataSource.getDevices();

    final onlineCount =
        all.where((d) => d.status == DeviceConnectionStatus.online).length;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isArabic ? 'أجهزة إنترنت الأشياء والمجسات' : 'IoT Nodes & Devices',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.flowBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: Text(
          isArabic ? 'ربط جهاز جديد' : 'Pair Device',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.deviceSetup);
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.flowBlue,
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Status Overview Bar
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: isArabic ? 'الأجهزة المتصلة' : 'Online Nodes',
                        value: '$onlineCount/${all.length}',
                        color: AppColors.sensorOnline,
                        icon: Icons.wifi_tethering_rounded,
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                      _StatColumn(
                        label: isArabic ? 'بروتوكول الاتصال' : 'Protocol',
                        value: 'MQTT / LoRa',
                        color: AppColors.flowBlue,
                        icon: Icons.hub_rounded,
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                      _StatColumn(
                        label: isArabic ? 'أمان العتاد' : 'Hardware Safety',
                        value: isArabic ? 'محمي نشط' : 'Arm Guard',
                        color: AppColors.primaryGreen,
                        icon: Icons.shield_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Category Filter Pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryPill(
                        label: isArabic ? 'جميع الأجهزة' : 'All Devices',
                        isSelected: _selectedCategory == 'all',
                        count: all.length,
                        onTap: () => setState(() => _selectedCategory = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _CategoryPill(
                        label: isArabic ? 'بوابات ESP32' : 'Gateways',
                        isSelected: _selectedCategory == 'gateway',
                        count: all
                            .where((d) =>
                                d.category == DeviceCategory.centralGateway)
                            .length,
                        onTap: () =>
                            setState(() => _selectedCategory = 'gateway'),
                      ),
                      const SizedBox(width: 8),
                      _CategoryPill(
                        label: isArabic ? 'مجسات LoRa للتربة' : 'Soil Probes',
                        isSelected: _selectedCategory == 'probe',
                        count: all
                            .where((d) =>
                                d.category == DeviceCategory.soilProbeNode)
                            .length,
                        onTap: () =>
                            setState(() => _selectedCategory = 'probe'),
                      ),
                      const SizedBox(width: 8),
                      _CategoryPill(
                        label: isArabic ? 'محابس وريليهات' : 'Actuators',
                        isSelected: _selectedCategory == 'actuator',
                        count: all
                            .where((d) =>
                                d.category ==
                                DeviceCategory.solenoidRelayModule)
                            .length,
                        onTap: () =>
                            setState(() => _selectedCategory = 'actuator'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Devices List
                ..._filteredDevices.map((device) {
                  return DeviceCard(
                    device: device,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.deviceDetails,
                        arguments: device.id,
                      );
                    },
                  );
                }),

                const SizedBox(height: 16),

                // Hardware Safeguards Documentation Card
                const HardwareSafetyCard(),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  const _CategoryPill({
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
                    : (isDark
                        ? AppColors.surfaceDark
                        : AppColors.backgroundLight),
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
