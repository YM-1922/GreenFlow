import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/irrigation_entities.dart';

/// Interactive pump control card with safety confirmation, flow rate, and pressure telemetry.
class PumpControlCard extends StatelessWidget {
  final PumpEntity pump;
  final VoidCallback onStartPump;
  final VoidCallback onStopPump;
  final ValueChanged<bool> onToggleAutoMode;
  final VoidCallback onResetEmergencyStop;

  const PumpControlCard({
    super.key,
    required this.pump,
    required this.onStartPump,
    required this.onStopPump,
    required this.onToggleAutoMode,
    required this.onResetEmergencyStop,
  });

  void _showStartConfirmation(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isArabic ? 'تأكيد تشغيل المضخة' : 'Confirm Pump Start'),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من رغبتك في تشغيل مضخة الري الرئيسية الآن؟ سيتم فتح الصمام الهيدروليكي للقطاع الأول تلقائياً لمنع الضغط الزائد.'
              : 'Are you sure you want to activate the central irrigation pump now? Zone valves will be checked to prevent deadhead overpressure.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel(context)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onStartPump();
            },
            child: Text(isArabic ? 'تشغيل الآن' : 'Start Pump'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isEmergency = pump.state == PumpOperatingState.emergencyStopped;
    final stateLabel = isArabic ? pump.state.labelAr() : pump.state.labelEn();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isEmergency
              ? AppColors.sensorAlert
              : (pump.isRunning
                  ? AppColors.primaryGreen.withValues(alpha: 0.8)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight)),
          width: pump.isRunning || isEmergency ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (pump.isRunning ? AppColors.primaryGreen : Colors.black)
                .withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Name & Telemetry Node Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isEmergency
                                ? AppColors.sensorAlert
                                : (pump.isRunning
                                    ? AppColors.primaryGreen
                                    : AppColors.flowBlue))
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        pump.isRunning
                            ? Icons.water_drop_rounded
                            : Icons.power_settings_new_rounded,
                        color: isEmergency
                            ? AppColors.sensorAlert
                            : (pump.isRunning
                                ? AppColors.primaryGreen
                                : AppColors.flowBlue),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pump.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            pump.farmName,
                            style: TextStyle(
                              fontSize: 10,
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
                  ],
                ),
              ),
              const SizedBox(width: 6),
              StatusBadge(
                label: stateLabel,
                color: pump.state.color(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Telemetry Gauges (Flow rate, Line Pressure, Power)
          Row(
            children: [
              Expanded(
                child: _GaugeBox(
                  title: isArabic ? 'معدل التدفق' : 'Flow Rate',
                  value: '${pump.currentFlowRateLitersPerMinute.toInt()}',
                  unit: 'L/min',
                  icon: Icons.speed_rounded,
                  color: AppColors.flowBlue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GaugeBox(
                  title: isArabic ? 'ضغط الشبكة' : 'Pressure',
                  value: pump.linePressureBar.toStringAsFixed(1),
                  unit: 'bar',
                  icon: Icons.compress_rounded,
                  color: AppColors.primaryGreen,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GaugeBox(
                  title: isArabic ? 'استهلاك الطاقة' : 'Power',
                  value: (pump.powerConsumptionWatts / 1000).toStringAsFixed(1),
                  unit: 'kW',
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mode Selector (Auto vs Manual)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onToggleAutoMode(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: pump.isAutomaticMode
                            ? AppColors.primaryGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          isArabic ? 'النمط الآلي الذكي' : 'Smart Auto Mode',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: pump.isAutomaticMode
                                ? Colors.white
                                : (isDark ? Colors.grey : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onToggleAutoMode(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !pump.isAutomaticMode
                            ? AppColors.flowBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          isArabic ? 'التحكم اليدوي' : 'Manual Control',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: !pump.isAutomaticMode
                                ? Colors.white
                                : (isDark ? Colors.grey : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Main Action Button (Start / Stop / Reset E-Stop)
          if (isEmergency) ...[
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sensorWarning,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(
                isArabic
                    ? 'إلغاء قفل الطوارئ وإعادة التهيئة'
                    : 'Reset Emergency Stop Lockout',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              onPressed: onResetEmergencyStop,
            ),
          ] else ...[
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: pump.isRunning
                    ? AppColors.sensorAlert
                    : AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(
                pump.isRunning
                    ? Icons.pause_circle_rounded
                    : Icons.play_circle_filled_rounded,
              ),
              label: Text(
                pump.isRunning
                    ? (isArabic ? 'إيقاف المضخة' : 'Stop Irrigation Pump')
                    : (isArabic ? 'تشغيل المضخة الآن' : 'Start Irrigation Pump'),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800),
              ),
              onPressed: () {
                if (pump.isRunning) {
                  onStopPump();
                } else {
                  _showStartConfirmation(context);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _GaugeBox extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _GaugeBox({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
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
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
