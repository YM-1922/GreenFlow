import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/voice_assistant_service.dart';
import '../../../../core/widgets/voice_assistant_speaker_button.dart';
import '../../data/datasources/irrigation_mock_data_source.dart';
import '../widgets/emergency_stop_modal.dart';
import '../widgets/irrigation_history_list.dart';
import '../widgets/irrigation_schedules_list.dart';
import '../widgets/irrigation_timer_widget.dart';
import '../widgets/pump_control_card.dart';
import '../widgets/zone_valves_grid.dart';

/// Complete Smart Irrigation Management Screen for Green Flow.
/// Integrates pump actuation, individual valve relays, countdown timers, automated schedules, and emergency stops.
class IrrigationScreen extends StatefulWidget {
  final IrrigationMockDataSource? dataSource;

  const IrrigationScreen({
    super.key,
    this.dataSource,
  });

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  late final IrrigationMockDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? IrrigationMockDataSource();
    _dataSource.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _dataSource.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _triggerEmergencyStop() {
    EmergencyStopModal.show(
      context,
      onConfirm: (reason) {
        _dataSource.triggerEmergencyStop(reason: reason);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.sensorAlert,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Row(
              children: [
                const Icon(Icons.dangerous_rounded,
                    color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.isArabic(context)
                        ? 'تم تفعيل إيقاف الطوارئ! تم فصل المضخات وإغلاق المحابس.'
                        : 'Emergency Stop Activated! Pumps cut off & valves shut.',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          isArabic ? 'التحكم الذكي بالري' : 'Smart Irrigation Control',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          // Voice Assistant Speaker
          VoiceAssistantSpeakerButton(
            arabicMessage: isArabic
                ? 'دي شاشة التحكم في الري، تقدر تشغل وتوقف المضخة وتتابع المحابس والجدول الزمني.'
                : 'This is the irrigation control screen.',
            englishMessage: 'This is the irrigation control screen.',
          ),
          const SizedBox(width: 4),

          // Emergency E-Stop Button in AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sensorAlert,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.emergency_rounded, size: 16),
              label: Text(
                isArabic ? 'طوارئ E-STOP' : 'E-STOP',
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
              ),
              onPressed: _triggerEmergencyStop,
            ),
          ),
        ],
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
                // 1. Central Pump Actuator Card
                PumpControlCard(
                  pump: _dataSource.pump,
                  onStartPump: () {
                    _dataSource.startPump();
                    VoiceAssistantService().speak(
                      context,
                      arabicText: 'الري يعمل الآن.',
                      englishText: 'Irrigation is running now.',
                    );
                  },
                  onStopPump: () {
                    _dataSource.stopPump();
                    VoiceAssistantService().speak(
                      context,
                      arabicText: 'تم إيقاف تشغيل الري.',
                      englishText: 'Irrigation has been stopped.',
                    );
                  },
                  onToggleAutoMode: (val) => _dataSource.setAutomaticMode(val),
                  onResetEmergencyStop: () =>
                      _dataSource.resetEmergencyStop(),
                ),

                const SizedBox(height: 20),

                // 2. Zone Solenoid Valves Matrix
                ZoneValvesGrid(
                  valves: _dataSource.valves,
                  onToggleValve: (id, open) =>
                      _dataSource.toggleValve(id, open),
                ),

                const SizedBox(height: 20),

                // 3. Countdown Irrigation Timer Widget
                IrrigationTimerWidget(
                  activeDuration: _dataSource.activeTimerDuration,
                  timerStartedAt: _dataSource.timerStartedAt,
                  onStartTimer: (dur) => _dataSource.startTimer(dur),
                  onCancelTimer: () => _dataSource.cancelTimer(),
                ),

                const SizedBox(height: 20),

                // 4. Automated Schedules List
                IrrigationSchedulesList(
                  schedules: _dataSource.schedules,
                  onSaveSchedule: (s) => _dataSource.addSchedule(s),
                  onDeleteSchedule: (id) => _dataSource.deleteSchedule(id),
                  onToggleEnabled: (id, val) =>
                      _dataSource.toggleScheduleEnabled(id, val),
                ),

                const SizedBox(height: 20),

                // 5. Operation History & Water Logs
                IrrigationHistoryList(history: _dataSource.history),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
