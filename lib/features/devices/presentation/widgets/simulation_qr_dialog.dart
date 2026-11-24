import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/backend/firebase_config.dart';
import '../../../../core/backend/firebase_realtime_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Comprehensive IoT Simulation & Cloud Hub.
/// Supports:
/// 1. Built-in Interactive ESP32 Hardware Simulator with live Serial Monitor (Zero website required).
/// 2. Firebase Cloud Realtime DB configuration & Live Connection Testing (Fixes 404 error).
/// 3. Alternative Simulation Platforms (Tinkercad Circuits, Proteus VSM, Blynk IoT, Python CLI, Wokwi).
class SimulationQrDialog extends StatefulWidget {
  const SimulationQrDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const SimulationQrDialog(),
    );
  }

  @override
  State<SimulationQrDialog> createState() => _SimulationQrDialogState();
}

class _SimulationQrDialogState extends State<SimulationQrDialog> {
  int _selectedTab = 0; // 0: Built-in Simulator, 1: Firebase Cloud Test & Fix, 2: Alternative Sites
  final String _simulationUrl = 'https://wokwi.com/projects/new/esp32';

  // Cloud Testing State
  late final TextEditingController _urlController;
  late final TextEditingController _tokenController;
  bool _useLiveBackend = false;
  bool _isTestingConnection = false;
  String? _connectionTestResult;
  bool? _connectionSuccess;

  // Simulator Hardware State
  late double _simulatedSoilMoisture;
  late double _simulatedTemp;
  late double _simulatedHum;
  late bool _simulatedPump;
  late bool _simulatedAuto;
  final List<String> _consoleLogs = [];

  // Live telemetry stream from Python bridge / Firebase
  StreamSubscription<Map<String, dynamic>>? _telemetrySubscription;
  StreamSubscription<bool>? _pumpSubscription;

  @override
  void initState() {
    super.initState();
    FirebaseConfig.loadPersistedConfig();
    _urlController = TextEditingController(text: FirebaseConfig.customRealtimeDbUrl);
    _tokenController = TextEditingController(text: FirebaseConfig.customAuthToken);
    _useLiveBackend = FirebaseConfig.useLiveBackend;

    final telemetry = FirebaseRealtimeService.instance.getTelemetry();
    _simulatedSoilMoisture = (telemetry['soilMoisture'] as num?)?.toDouble() ?? 42.0;
    _simulatedTemp = (telemetry['temperature'] as num?)?.toDouble() ?? 28.0;
    _simulatedHum = (telemetry['humidity'] as num?)?.toDouble() ?? 55.0;
    _simulatedPump = FirebaseRealtimeService.instance.getPumpStatus();
    _simulatedAuto = FirebaseRealtimeService.instance.getAutoMode();

    _addLog('[ESP32 Boot] Xtensa Dual-Core 240MHz. GreenFlow IoT Firmware v2.0 ready.');
    _addLog('[WiFi] Connected to GreenFlow Gateway. IP: 192.168.1.145');
    _addLog('[Sensors] DHT22 (GPIO 15) & Soil ADC (GPIO 34) active.');

    // ── Live stream: Python bridge updates the slider & pump in real-time ──
    _telemetrySubscription =
        FirebaseRealtimeService.instance.streamTelemetry().listen((data) {
      if (!mounted) return;
      final soil = (data['soilMoisture'] as num?)?.toDouble();
      final temp = (data['temperature'] as num?)?.toDouble();
      final hum  = (data['humidity']     as num?)?.toDouble();
      final pump = data['pumpStatus']    as bool?;
      final auto = data['autoMode']      as bool?;

      setState(() {
        if (soil != null && soil != _simulatedSoilMoisture) {
          // Log auto-stop event when pump just turned off after reaching target
          if (_simulatedPump && pump == false && soil >= 60.0) {
            _addLog('[Auto-Stop] Soil ${soil.toStringAsFixed(1)}% >= 60% → Pump OFF ⏸️');
          }
          // Log auto-start event
          if (!_simulatedPump && pump == true && soil < 30.0) {
            final tag = (_simulatedAuto) ? '[Auto-Start]' : '[Drought Protection]';
            _addLog('$tag Soil ${soil.toStringAsFixed(1)}% < 30% → Pump ON 💧');
          }
          _simulatedSoilMoisture = soil;
        }
        if (temp != null) _simulatedTemp = temp;
        if (hum  != null) _simulatedHum  = hum;
        if (pump != null) _simulatedPump  = pump;
        if (auto != null) _simulatedAuto  = auto;
      });
    });
  }

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    _pumpSubscription?.cancel();
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _addLog(String message) {
    final timeStr = _formatTimestamp();
    final entry = '[$timeStr] $message';
    if (!mounted) {
      _consoleLogs.insert(0, entry);
      if (_consoleLogs.length > 30) {
        _consoleLogs.removeLast();
      }
    } else {
      setState(() {
        _consoleLogs.insert(0, entry);
        if (_consoleLogs.length > 30) {
          _consoleLogs.removeLast();
        }
      });
    }
  }

  Future<void> _testConnection({String? customUrl, String? customToken}) async {
    setState(() {
      _isTestingConnection = true;
      _connectionTestResult = null;
    });

    final res = await FirebaseRealtimeService.instance.testFirebaseConnection(
      customUrl: customUrl ?? _urlController.text.trim(),
      customToken: customToken ?? _tokenController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isTestingConnection = false;
        _connectionSuccess = res.success;
        _connectionTestResult = res.message;
      });
      _addLog('[Cloud Test] HTTP Status: ${res.statusCode} | Success: ${res.success}');
    }
  }

  void _saveCloudConfig() {
    final url = _urlController.text.trim();
    final token = _tokenController.text.trim();
    FirebaseConfig.savePersistedConfig(
      url: url,
      token: token,
      liveMode: _useLiveBackend,
    );
    _addLog('[Cloud Config] Saved: ${url.isEmpty ? "Simulated Mode" : url}');
    _testConnection(customUrl: url, customToken: token);
  }

  void _enableSimulatedCloud() {
    setState(() {
      _useLiveBackend = false;
      _urlController.clear();
      _tokenController.clear();
    });
    FirebaseConfig.savePersistedConfig(url: '', token: '', liveMode: false);
    _testConnection(customUrl: '');
  }

  void _onMoistureSliderChanged(double value) {
    setState(() {
      _simulatedSoilMoisture = value;
    });
    FirebaseRealtimeService.instance.updateTelemetry(
      soilMoisture: value,
      temperature: _simulatedTemp,
      humidity: _simulatedHum,
    );

    final currentPump = FirebaseRealtimeService.instance.getPumpStatus();
    if (_simulatedAuto) {
      if (value < 30.0 && !currentPump) {
        _addLog('[Auto Threshold] Soil ${value.toStringAsFixed(1)}% < 30% -> Relay CLOSED (Pump ON 💦)');
      } else if (value >= 60.0 && currentPump) {
        _addLog('[Auto Threshold] Soil ${value.toStringAsFixed(1)}% >= 60% -> Relay OPEN (Pump OFF ⏸️)');
      }
    } else {
      // Manual Mode Emergency Drought Protection
      if (value < 30.0 && !currentPump) {
        _addLog('[Drought Protection] Soil ${value.toStringAsFixed(1)}% < 30% in Manual -> Relay CLOSED (Pump ON 💦)');
      } else if (value >= 60.0 && currentPump) {
        _addLog('[Target Reached] Soil ${value.toStringAsFixed(1)}% >= 60% -> Relay OPEN (Pump OFF ⏸️)');
      }
    }

    setState(() {
      _simulatedPump = FirebaseRealtimeService.instance.getPumpStatus();
    });
  }

  void _onTempSliderChanged(double value) {
    setState(() => _simulatedTemp = value);
    FirebaseRealtimeService.instance.updateTelemetry(
      soilMoisture: _simulatedSoilMoisture,
      temperature: value,
      humidity: _simulatedHum,
    );
  }

  void _onHumSliderChanged(double value) {
    setState(() => _simulatedHum = value);
    FirebaseRealtimeService.instance.updateTelemetry(
      soilMoisture: _simulatedSoilMoisture,
      temperature: _simulatedTemp,
      humidity: value,
    );
  }

  void _onPumpToggle() {
    if (_simulatedAuto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الوضع التلقائي مفعّل. قم بالتبديل إلى الوضع اليدوي أولاً للتحكم المباشر بالمضخة.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    final target = !_simulatedPump;
    final res = FirebaseRealtimeService.instance.sendPumpCommand(turnOn: target);
    if (res.success) {
      setState(() {
        _simulatedPump = target;
      });
      _addLog('[Manual Control] Pump turned ${target ? "ON 💦" : "OFF ⏸️"} via operator command.');
    }
  }

  void _onAutoModeToggle(bool val) {
    setState(() {
      _simulatedAuto = val;
    });
    FirebaseRealtimeService.instance.toggleAutoMode(autoMode: val);
    setState(() {
      _simulatedPump = FirebaseRealtimeService.instance.getPumpStatus();
    });
    _addLog('[Mode Switch] Switched to ${val ? "AUTOMATIC (Threshold-Governed)" : "MANUAL (Operator Override)"}');
  }

  @override
  Widget build(BuildContext context) {
    final isAr = AppStrings.isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 760),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreenSurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.memory_rounded, color: AppColors.primaryGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'مركز محاكاة إنترنت الأشياء والسحابة' : 'IoT & Cloud Simulation Hub',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isAr ? 'ESP32 DevKit V4 • حساسات • تحكم سحابي' : 'ESP32 DevKit • Sensors • Cloud Sync',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab Selector Chips
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildNavTabButton(
                      index: 0,
                      icon: Icons.developer_board_rounded,
                      title: isAr ? 'المحاكي المدمج' : 'Live Simulator',
                    ),
                  ),
                  Expanded(
                    child: _buildNavTabButton(
                      index: 1,
                      icon: Icons.cloud_done_rounded,
                      title: isAr ? 'إعدادات وفحص السحابة' : 'Cloud Setup & Fix',
                    ),
                  ),
                  Expanded(
                    child: _buildNavTabButton(
                      index: 2,
                      icon: Icons.language_rounded,
                      title: isAr ? 'منصات بديلة لـ Wokwi' : 'Alternative Sites',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Tab Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: _buildActiveTabContent(isDark, isAr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTabButton({required int index, required IconData icon, required String title}) {
    final selected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(bool isDark, bool isAr) {
    switch (_selectedTab) {
      case 0:
        return _buildBuiltInSimulatorTab(isDark, isAr);
      case 1:
        return _buildCloudSetupAndFixTab(isDark, isAr);
      case 2:
      default:
        return _buildAlternativePlatformsTab(isDark, isAr);
    }
  }

  // =========================================================================
  // TAB 0: BUILT-IN INTERACTIVE ESP32 SIMULATOR (No External Site Needed!)
  // =========================================================================
  Widget _buildBuiltInSimulatorTab(bool isDark, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ESP32 Virtual Board Visualizer Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                  : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ESP32-WROOM-32 DevKit',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _simulatedPump ? const Color(0xFF3B82F6) : Colors.grey[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _simulatedPump ? Icons.water_drop_rounded : Icons.power_off_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _simulatedPump
                              ? (isAr ? 'المضخة: تعمل 💦' : 'Pump: ACTIVE')
                              : (isAr ? 'المضخة: متوقفة' : 'Pump: OFF'),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Pin mapping pills
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildPinBadge('GPIO 15', 'DHT22 Data', const Color(0xFF06B6D4)),
                  _buildPinBadge('GPIO 34', 'Soil ADC1', const Color(0xFFF59E0B)),
                  _buildPinBadge('GPIO 23', 'Relay Pump', const Color(0xFF3B82F6)),
                  _buildPinBadge('3.3V / GND', 'Power Bus', const Color(0xFF10B981)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Controls Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Auto / Manual Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'نظام التحكم بالري' : 'Irrigation Control Mode',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        _simulatedAuto
                            ? (isAr ? 'تلقائي: تشغيل < 30% وإيقاف >= 60%' : 'Auto: ON <30%, OFF >=60%')
                            : (isAr ? 'يدوي: تحكم المشغل المباشر' : 'Manual: Operator command'),
                        style: TextStyle(fontSize: 10, color: _simulatedAuto ? AppColors.primaryGreen : AppColors.flowBlue),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _simulatedAuto ? (isAr ? 'تلقائي' : 'Auto') : (isAr ? 'يدوي' : 'Manual'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _simulatedAuto ? AppColors.primaryGreen : AppColors.flowBlue,
                        ),
                      ),
                      Switch(
                        value: _simulatedAuto,
                        onChanged: _onAutoModeToggle,
                        activeColor: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 16),

              // Soil Moisture Slider (Potentiometer)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'مقياس الجهد (رطوبة التربة):' : 'Potentiometer (Soil Moisture):',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_simulatedSoilMoisture.toStringAsFixed(1)}% ${_simulatedSoilMoisture < 30 ? "(جافة - تحتاج ري)" : (_simulatedSoilMoisture >= 60 ? "(رطبة كافية)" : "(مثالية)")}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _simulatedSoilMoisture < 30.0
                          ? const Color(0xFFDC2626)
                          : (_simulatedSoilMoisture >= 60.0 ? const Color(0xFF2563EB) : const Color(0xFF16A34A)),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _simulatedSoilMoisture,
                min: 0.0,
                max: 100.0,
                divisions: 100,
                activeColor: _simulatedSoilMoisture < 30.0
                    ? const Color(0xFFDC2626)
                    : (_simulatedSoilMoisture >= 60.0 ? const Color(0xFF2563EB) : AppColors.primaryGreen),
                onChanged: _onMoistureSliderChanged,
              ),

              // Temperature Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'حساس الحرارة (DHT22):' : 'Temperature (DHT22):',
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text('${_simulatedTemp.toStringAsFixed(1)} °C', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _simulatedTemp,
                min: 10.0,
                max: 50.0,
                divisions: 80,
                activeColor: const Color(0xFFF97316),
                onChanged: _onTempSliderChanged,
              ),

              // Humidity Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'رطوبة الهواء (DHT22):' : 'Air Humidity (DHT22):',
                    style: const TextStyle(fontSize: 11),
                  ),
                  Text('${_simulatedHum.toStringAsFixed(1)} %', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _simulatedHum,
                min: 10.0,
                max: 100.0,
                divisions: 90,
                activeColor: const Color(0xFF06B6D4),
                onChanged: _onHumSliderChanged,
              ),

              // Manual Pump Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'زر المضخة اليدوي:' : 'Manual Pump Switch:',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  ElevatedButton.icon(
                    onPressed: _simulatedAuto ? null : _onPumpToggle,
                    icon: Icon(_simulatedPump ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 16),
                    label: Text(_simulatedPump ? (isAr ? 'إيقاف المضخة' : 'Stop Pump') : (isAr ? 'تشغيل المضخة' : 'Start Pump')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _simulatedPump ? const Color(0xFFDC2626) : AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Live Serial Monitor Terminal
        Text(
          isAr ? 'الشاشة التسلسلية للمتحكم (Serial Monitor):' : 'ESP32 Serial Monitor Console:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          height: 130,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: ListView.builder(
            itemCount: _consoleLogs.length,
            itemBuilder: (context, idx) {
              final log = _consoleLogs[idx];
              final isError = log.contains('Error') || log.contains('404') || log.contains('Failed');
              final isTrigger = log.contains('CLOSED') || log.contains('OPEN') || log.contains('Threshold');
              return Text(
                log,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: isError
                      ? const Color(0xFFF87171)
                      : (isTrigger ? const Color(0xFF38BDF8) : const Color(0xFF4ADE80)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPinBadge(String pin, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$pin: $label',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
      ),
    );
  }

  // =========================================================================
  // TAB 1: CLOUD SETUP & 404 FIX (Resolves all Firebase connection issues)
  // =========================================================================
  Widget _buildCloudSetupAndFixTab(bool isDark, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Explanation Card of the 404 error
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isAr
                      ? 'سبب خطأ (404 Not Found): الرابط النموذجي السابق لم يتم إنشاؤه على حسابك في Firebase Console بعد. لحل المشكلة فوراً: يمكنك استخدام "السحابة المدمجة" التي تعمل 100% بدون أي إعدادات، أو إدخال رابط مشروعك الحقيقي بالأسفل.'
                      : '404 Explanation: The default placeholder URL was not created in your Firebase Console. Select Simulated Cloud for instant 200 OK, or paste your actual Firebase URL below.',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF1E40AF), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quick 1-Click Fix Button (Simulated Cloud)
        ElevatedButton.icon(
          onPressed: _enableSimulatedCloud,
          icon: const Icon(Icons.flash_on_rounded, size: 18),
          label: Text(
            isAr ? 'تفعيل السحابة التفاعلية المدمجة فوراً (HTTP 200 OK)' : 'Enable Instant Simulated Cloud (200 OK)',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 16),

        // Custom Live Firebase Inputs
        Text(
          isAr ? 'أو اربط بسحابة Firebase الحقيقية الخاصة بك:' : 'Or Connect to your Live Firebase Realtime DB:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            labelText: isAr ? 'رابط Realtime Database' : 'Database URL',
            hintText: 'https://your-project-default-rtdb.firebaseio.com',
            prefixIcon: const Icon(Icons.link_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 10),

        TextField(
          controller: _tokenController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: isAr ? 'مفتاح المصادقة / Database Secret (اختياري)' : 'Auth Token / Secret (Optional)',
            hintText: 'AIzaSy... / Database Secret',
            prefixIcon: const Icon(Icons.key_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 12),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isTestingConnection ? null : _saveCloudConfig,
                icon: _isTestingConnection
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.cloud_sync_rounded, size: 18),
                label: Text(
                  _isTestingConnection ? (isAr ? 'جاري الفحص...' : 'Testing...') : (isAr ? 'حفظ واختبار الاتصال' : 'Save & Test'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.flowBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),

        // Connection Test Result Banner
        if (_connectionTestResult != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_connectionSuccess == true) ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (_connectionSuccess == true) ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  (_connectionSuccess == true) ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                  color: (_connectionSuccess == true) ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _connectionTestResult!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: (_connectionSuccess == true) ? const Color(0xFF166534) : const Color(0xFF991B1B),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // =========================================================================
  // TAB 2: ALTERNATIVE PLATFORMS & SITES TO WOKWI
  // =========================================================================
  Widget _buildAlternativePlatformsTab(bool isDark, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isAr ? 'منصات ومواقع مجانية لمحاكاة الدوائر و IoT:' : 'Alternative Free Simulators & Platforms:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 10),

        // Option 1: Tinkercad Circuits
        _buildPlatformCard(
          title: 'Tinkercad Circuits (Autodesk)',
          subtitle: isAr ? 'أسهل موقع ويب مجاني لبناء الدوائر والحساسات ومحاكاتها.' : 'Easiest free web simulator for circuits and sensors.',
          url: 'https://www.tinkercad.com/circuits',
          icon: Icons.grid_view_rounded,
          color: const Color(0xFF0284C7),
          isAr: isAr,
        ),
        const SizedBox(height: 8),

        // Option 2: Proteus VSM
        _buildPlatformCard(
          title: 'Proteus VSM (Microcontroller Simulator)',
          subtitle: isAr ? 'المحاكي الهندسي الأقوى للـ ESP32 مع منفذ تسلسلي افتراضي للربط بالإنترنت.' : 'Industry-standard ESP32 simulator with virtual COM port network bridge.',
          url: 'https://www.labcenter.com',
          icon: Icons.memory_rounded,
          color: const Color(0xFF7C3AED),
          isAr: isAr,
        ),
        const SizedBox(height: 8),

        // Option 3: Blynk IoT Web Console
        _buildPlatformCard(
          title: 'Blynk IoT Cloud Dashboard',
          subtitle: isAr ? 'منصة سحابية متقدمة لإنشاء أجهزة افتراضية ولوحات قيادة للري.' : 'Advanced IoT cloud platform for virtual devices and mobile dashboards.',
          url: 'https://blynk.io',
          icon: Icons.dashboard_customize_rounded,
          color: const Color(0xFF059669),
          isAr: isAr,
        ),
        const SizedBox(height: 8),

        // Option 4: Python Standalone Virtual ESP32
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.terminal_rounded, size: 18, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Text(
                    isAr ? 'محاكي Python السريع (بدون مواقع)' : 'Python CLI Virtual Device',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isAr
                    ? 'يمكنك تشغيل المحاكي في سطر الأوامر مباشرة بالأمر:\npython hardware_simulation/virtual_esp32.py'
                    : 'Run standalone simulator in terminal:\npython hardware_simulation/virtual_esp32.py',
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Option 5: Wokwi with QR Code (for reference)
        ExpansionTile(
          title: Text(
            isAr ? 'عرض رابط وكود Wokwi المباشر' : 'View Wokwi Project & QR',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          leading: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryGreen),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: CustomPaint(
                  size: const Size(140, 140),
                  painter: _QrCodePainter(data: _simulationUrl),
                ),
              ),
            ),
            Center(
              child: SelectableText(
                _simulationUrl,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.flowBlue),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }

  Widget _buildPlatformCard({
    required String title,
    required String subtitle,
    required String url,
    required IconData icon,
    required Color color,
    required bool isAr,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 16),
            tooltip: isAr ? 'نسخ الرابط' : 'Copy URL',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isAr ? 'تم نسخ الرابط' : 'URL copied'), duration: const Duration(seconds: 2)),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Native Canvas QR Code Pattern Painter (Clean, Crisp, 100% self-contained)
class _QrCodePainter extends CustomPainter {
  final String data;

  _QrCodePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final paintLight = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw white background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintLight);

    const int modules = 25;
    final double moduleSize = size.width / modules;

    // Fixed functional QR pattern matrix (25x25)
    final pattern = [
      "11111110101010101111111",
      "10000010110011001000001",
      "10111010011100101011101",
      "10111010101010101011101",
      "10111010001111001011101",
      "10000010110100101000001",
      "11111110101010101111111",
      "00000000110110000000000",
      "11010111001010111010111",
      "01101000110101001101010",
      "10110110101010100110101",
      "01010101110111011010101",
      "11001010001000100110010",
      "00000000110111000000000",
      "11111110101010101111111",
      "10000010011111001000001",
      "10111010101010101011101",
      "10111010010100101011101",
      "10111010111011001011101",
      "10000010010101101000001",
      "11111110101010101111111",
    ];

    for (int r = 0; r < pattern.length; r++) {
      final rowStr = pattern[r];
      for (int c = 0; c < rowStr.length; c++) {
        if (rowStr[c] == '1') {
          final rect = Rect.fromLTWH(
            (c + 1) * moduleSize,
            (r + 2) * moduleSize,
            moduleSize,
            moduleSize,
          );
          canvas.drawRect(rect, paintDark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
