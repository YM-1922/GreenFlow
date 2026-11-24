import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/backend/firebase_realtime_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Dedicated Smart Irrigation Control Card.
/// Provides interactive simulation controls for Pump state and Auto/Manual modes.
class IrrigationControlCard extends StatefulWidget {
  final IrrigationStatusEntity initialStatus;
  final ValueChanged<IrrigationStatusEntity>? onStatusChanged;

  const IrrigationControlCard({
    super.key,
    required this.initialStatus,
    this.onStatusChanged,
  });

  @override
  State<IrrigationControlCard> createState() => _IrrigationControlCardState();
}

class _IrrigationControlCardState extends State<IrrigationControlCard>
    with SingleTickerProviderStateMixin {
  late bool _isPumpActive;
  late bool _isAutoMode;
  late final AnimationController _flowAnimationController;
  StreamSubscription<bool>? _pumpSubscription;

  @override
  void initState() {
    super.initState();
    _isPumpActive = widget.initialStatus.isPumpActive;
    _isAutoMode = widget.initialStatus.isAutomaticMode;

    _flowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    if (_isPumpActive) {
      _flowAnimationController.repeat();
    }

    // Subscribe to live Realtime Database pump status updates
    _pumpSubscription = FirebaseRealtimeService.instance.streamPumpStatus().listen((active) {
      if (mounted && _isPumpActive != active) {
        setState(() {
          _isPumpActive = active;
          if (_isPumpActive) {
            _flowAnimationController.repeat();
          } else {
            _flowAnimationController.stop();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant IrrigationControlCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStatus != widget.initialStatus) {
      _isPumpActive = widget.initialStatus.isPumpActive;
      _isAutoMode = widget.initialStatus.isAutomaticMode;
      if (_isPumpActive && !_flowAnimationController.isAnimating) {
        _flowAnimationController.repeat();
      } else if (!_isPumpActive && _flowAnimationController.isAnimating) {
        _flowAnimationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pumpSubscription?.cancel();
    _flowAnimationController.dispose();
    super.dispose();
  }

  void _togglePump() {
    final isAr = AppStrings.isArabic(context);

    // Safe override: if smart auto mode is active, switch to manual mode so manual control executes without conflict
    if (_isAutoMode) {
      _isAutoMode = false;
      FirebaseRealtimeService.instance.setAutoMode(false);
    }

    final targetPumpState = !_isPumpActive;
    final res = FirebaseRealtimeService.instance.sendPumpCommand(turnOn: targetPumpState);

    if (!res.success && res.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message!), backgroundColor: const Color(0xFFD97706)),
      );
      return;
    }

    setState(() {
      _isPumpActive = targetPumpState;
      if (_isPumpActive) {
        _flowAnimationController.repeat();
      } else {
        _flowAnimationController.stop();
      }
    });

    final updated = widget.initialStatus.copyWith(
      isPumpActive: _isPumpActive,
      isAutomaticMode: _isAutoMode,
    );
    widget.onStatusChanged?.call(updated);

    final msg = _isPumpActive
        ? (isAr ? 'تم تشغيل دورة الري (تحكم يدوي)' : 'Irrigation cycle started (Manual Control)')
        : (isAr ? 'تم إيقاف دورة الري (تحكم يدوي)' : 'Irrigation cycle paused (Manual Control)');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _isPumpActive ? AppColors.flowBlueDark : AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(
              _isPumpActive ? Icons.water_drop_rounded : Icons.pause_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
  }

  void _toggleAutoMode(bool auto) {
    setState(() {
      _isAutoMode = auto;
    });

    FirebaseRealtimeService.instance.toggleAutoMode(autoMode: auto);

    final updated = widget.initialStatus.copyWith(
      isPumpActive: _isPumpActive,
      isAutomaticMode: _isAutoMode,
    );
    widget.onStatusChanged?.call(updated);

    final msg = _isAutoMode
        ? (AppStrings.isArabic(context)
            ? 'النمط الآلي: يتم تشغيل الري وفق حساسات رطوبة التربة'
            : 'Automatic Mode: Irrigation triggers via soil moisture sensors')
        : (AppStrings.isArabic(context)
            ? 'النمط اليدوي: تحكم مباشر بالصمامات والمضخات'
            : 'Manual Mode: Direct operator valve control');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nextScheduled = isArabic
        ? widget.initialStatus.nextScheduledAr
        : widget.initialStatus.nextScheduledEn;

    final lastActivity = isArabic
        ? widget.initialStatus.lastActivityAr
        : widget.initialStatus.lastActivityEn;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isPumpActive
              ? AppColors.flowBlue.withValues(alpha: 0.7)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: _isPumpActive ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isPumpActive ? AppColors.flowBlue : Colors.black)
                .withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Section title + Pump Live Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (_isPumpActive ? AppColors.flowBlue : AppColors.primaryGreen)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.water_drop_rounded,
                        color: _isPumpActive ? AppColors.flowBlue : AppColors.primaryGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.smartIrrigationControl(context),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            AppStrings.demoNotice(context),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
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
              const SizedBox(width: 8),
              StatusBadge(
                label: _isPumpActive
                    ? AppStrings.pumpActive(context)
                    : AppStrings.pumpIdle(context),
                color: _isPumpActive ? AppColors.flowBlue : AppColors.sensorOnline,
                icon: _isPumpActive ? Icons.sync_rounded : Icons.check_circle_outline_rounded,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Auto / Manual Toggle Segmented Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _toggleAutoMode(true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isAutoMode
                            ? AppColors.primaryGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _isAutoMode
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 15,
                            color: _isAutoMode ? Colors.white : (isDark ? Colors.grey : Colors.black54),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.automaticMode(context),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _isAutoMode ? Colors.white : (isDark ? Colors.grey : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _toggleAutoMode(false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isAutoMode
                            ? AppColors.flowBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !_isAutoMode
                            ? [
                                BoxShadow(
                                  color: AppColors.flowBlue.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 15,
                            color: !_isAutoMode ? Colors.white : (isDark ? Colors.grey : Colors.black54),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.manualMode(context),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: !_isAutoMode ? Colors.white : (isDark ? Colors.grey : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Schedule & Last Activity Info Rows
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDark.withValues(alpha: 0.6)
                  : AppColors.flowBlueSurface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: AppColors.flowBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${AppStrings.nextScheduled(context)}: ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        nextScheduled,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      size: 15,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${AppStrings.lastActivity(context)}: ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        lastActivity,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Main Interactive Action Button (Start / Stop Irrigation)
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _isPumpActive
                    ? AppColors.sensorAlert
                    : AppColors.flowBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: _togglePump,
              icon: _isPumpActive
                  ? const Icon(Icons.stop_circle_rounded, size: 20)
                  : const Icon(Icons.play_circle_filled_rounded, size: 20),
              label: Text(
                _isPumpActive
                    ? AppStrings.stopIrrigation(context)
                    : AppStrings.startIrrigation(context),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
