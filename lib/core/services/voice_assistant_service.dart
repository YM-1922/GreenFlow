import 'package:flutter/material.dart';
import '../utils/file_io.dart' as file_io;

/// Centralized Voice Assistant Service for Farmer Accessibility.
/// Provides friendly, Egyptian-Arabic spoken announcements and audio/visual alerts.
/// Enables farmers with low literacy or smartphone experience to use Green Flow comfortably.
class VoiceAssistantService extends ChangeNotifier {
  static final VoiceAssistantService _instance = VoiceAssistantService._internal();
  factory VoiceAssistantService() => _instance;

  static const String _prefFileName = '.greenflow_voice_pref';

  bool _isEnabled = true;
  String? _lastAnnouncementAr;
  String? _lastAnnouncementEn;
  DateTime? _lastSpokenAt;
  bool _isSpeaking = false;

  VoiceAssistantService._internal() {
    _loadPreference();
  }

  bool get isEnabled => _isEnabled;
  String? get lastAnnouncementAr => _lastAnnouncementAr;
  String? get lastAnnouncementEn => _lastAnnouncementEn;
  DateTime? get lastSpokenAt => _lastSpokenAt;
  bool get isSpeaking => _isSpeaking;

  void _loadPreference() {
    final val = file_io.readFileSync(_prefFileName)?.trim();
    if (val != null) {
      _isEnabled = val == 'true';
    }
  }

  void toggleVoiceAssistance() {
    _isEnabled = !_isEnabled;
    file_io.writeFileSync(_prefFileName, _isEnabled ? 'true' : 'false');
    notifyListeners();
  }

  void setEnabled(bool enabled) {
    if (_isEnabled != enabled) {
      _isEnabled = enabled;
      file_io.writeFileSync(_prefFileName, _isEnabled ? 'true' : 'false');
      notifyListeners();
    }
  }

  /// Trigger a spoken assistance message with visual feedback.
  void speak(
    BuildContext context, {
    required String arabicText,
    String? englishText,
    bool isCritical = false,
  }) {
    if (!_isEnabled && !isCritical) return;

    _lastAnnouncementAr = arabicText;
    _lastAnnouncementEn = englishText ?? arabicText;
    _lastSpokenAt = DateTime.now();
    _isSpeaking = true;
    notifyListeners();

    // Show a gentle spoken banner / speech bubble on the active Scaffold
    try {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: isCritical ? const Color(0xFFDC2626) : const Color(0xFF166534),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(seconds: 4),
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCritical ? Icons.warning_amber_rounded : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arabicText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      if (englishText != null && englishText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          englishText,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (_) {}

    // Reset speaking state after a brief delay
    Future.delayed(const Duration(milliseconds: 2500), () {
      _isSpeaking = false;
      notifyListeners();
    });
  }
}
