import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/datasources/devices_mock_data_source.dart';
import '../../domain/entities/device_entities.dart';

/// Screen displaying comprehensive telemetry, diagnostics, and controls for an ESP32 device.
class DeviceDetailsScreen extends StatefulWidget {
  final String deviceId;

  const DeviceDetailsScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  late final DevicesMockDataSource _dataSource;
  Esp32DeviceEntity? _device;

  @override
  void initState() {
    super.initState();
    _dataSource = DevicesMockDataSource();
    _dataSource.addListener(_onDataChanged);
    _loadDevice();
  }

  @override
  void dispose() {
    _dataSource.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {
        _loadDevice();
      });
    }
  }

  void _loadDevice() {
    _device = _dataSource.getDeviceById(widget.deviceId);
  }

  void _pingDevice() {
    if (_device == null) return;
    _dataSource.sendHardwarePing(_device!.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.flowBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(AppStrings.pingDevice(context)),
      ),
    );
  }

  Future<void> _updateFirmware() async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(AppStrings.updateFirmware(dialogCtx)),
        content: Text(AppStrings.firmwareDemoNote(dialogCtx)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(AppStrings.ok(dialogCtx)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeDevice() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(AppStrings.removeDevice(dialogCtx)),
        content: Text(AppStrings.removeDeviceConfirm(dialogCtx)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(AppStrings.cancel(dialogCtx)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(AppStrings.confirm(dialogCtx)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      if (_device != null) {
        _dataSource.deleteDevice(_device!.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(AppStrings.deviceRemoved(context)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = AppStrings.isArabic(context);

    if (_device == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'تفاصيل الجهاز' : 'Device Details'),
        ),
        body: Center(
          child: Text(
            isArabic ? 'الجهاز غير موجود' : 'Device not found',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final device = _device!;
    final statusLabel =
        isArabic ? device.status.labelAr() : device.status.labelEn();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 14),
            child: Center(
              child: StatusBadge(
                label: statusLabel,
                color: device.status.color(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Device Hero Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        device.category.icon(),
                        size: 36,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic
                                ? device.category.labelAr()
                                : device.category.labelEn(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${isArabic ? 'الإشارة:' : 'RSSI:'} ${device.rssiSignalDbm} dBm',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            '${isArabic ? 'البطارية:' : 'Battery:'} ${device.batteryPercent}% (${device.batteryVoltage.toStringAsFixed(1)}V)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            '${isArabic ? 'الإصدار:' : 'Firmware:'} ${device.firmwareVersion}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Live Telemetry Section
              Text(
                AppStrings.liveTelemetry(context),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: _buildTelemetryList(context, device, isDark),
                ),
              ),

              const SizedBox(height: 18),

              // Network and Hardware Specifications
              Text(
                AppStrings.connectionInfo(context),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    _infoRow(
                      label: isArabic ? 'عنوان IP / القناة' : 'IP / Channel',
                      value: device.ipAddress,
                      isDark: isDark,
                    ),
                    _infoRow(
                      label: isArabic ? 'عنوان MAC' : 'MAC Address',
                      value: device.macAddress,
                      isDark: isDark,
                    ),
                    _infoRow(
                      label: AppStrings.lastSeen(context),
                      value: device.lastSeen.toString().split('.')[0],
                      isDark: isDark,
                    ),
                    _infoRow(
                      label: AppStrings.farm(context),
                      value: device.farmName,
                      isDark: isDark,
                    ),
                    _infoRow(
                      label: isArabic ? 'القطاع' : 'Zone',
                      value: device.zoneName,
                      isDark: isDark,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Control & Diagnostics Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: AppStrings.ping(context),
                      icon: Icons.wifi_tethering_rounded,
                      onPressed: _pingDevice,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      label: AppStrings.updateFirmware(context),
                      icon: Icons.system_update_alt_rounded,
                      isOutlined: true,
                      onPressed: _updateFirmware,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomButton(
                label: AppStrings.remove(context),
                icon: Icons.delete_outline_rounded,
                backgroundColor: Colors.redAccent,
                onPressed: _removeDevice,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTelemetryList(
    BuildContext context,
    Esp32DeviceEntity device,
    bool isDark,
  ) {
    final list = <Widget>[];

    if (device.soilMoistureTop25cm != null) {
      list.add(_infoRow(
        label: AppStrings.soilMoistureTop(context),
        value: '${device.soilMoistureTop25cm!.toStringAsFixed(1)}%',
        isDark: isDark,
      ));
    }
    if (device.soilMoistureDeep50cm != null) {
      list.add(_infoRow(
        label: AppStrings.soilMoistureDeep(context),
        value: '${device.soilMoistureDeep50cm!.toStringAsFixed(1)}%',
        isDark: isDark,
      ));
    }
    if (device.soilTemperatureCelsius != null) {
      list.add(_infoRow(
        label: AppStrings.soilTemp(context),
        value: '${device.soilTemperatureCelsius!.toStringAsFixed(1)} °C',
        isDark: isDark,
      ));
    }
    if (device.ambientTemperatureCelsius != null) {
      list.add(_infoRow(
        label: AppStrings.ambientTemp(context),
        value: '${device.ambientTemperatureCelsius!.toStringAsFixed(1)} °C',
        isDark: isDark,
      ));
    }
    if (device.ambientHumidityPercent != null) {
      list.add(_infoRow(
        label: AppStrings.humidity(context),
        value: '${device.ambientHumidityPercent!.toStringAsFixed(1)}%',
        isDark: isDark,
      ));
    }
    if (device.waterLevelMeters != null) {
      list.add(_infoRow(
        label: AppStrings.waterLevel(context),
        value: '${device.waterLevelMeters!.toStringAsFixed(2)} m',
        isDark: isDark,
      ));
    }
    if (device.soilSalinityEc != null) {
      list.add(_infoRow(
        label: AppStrings.salinity(context),
        value: '${device.soilSalinityEc!.toStringAsFixed(2)} dS/m',
        isDark: isDark,
      ));
    }

    if (list.isEmpty) {
      list.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          AppStrings.isArabic(context)
              ? 'لا توجد قراءات استشعار مباشرة مسجلة لهذه العقدة حالياً.'
              : 'No live telemetry readings recorded for this node currently.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ));
    }

    return list;
  }

  Widget _infoRow({
    required String label,
    required String value,
    required bool isDark,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
