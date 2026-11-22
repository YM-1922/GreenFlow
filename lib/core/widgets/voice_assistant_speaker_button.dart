import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/voice_assistant_service.dart';

/// Speaker button widget for Farmer Accessibility.
/// Tap to speak the screen's purpose or advice, long press to toggle voice assistance.
class VoiceAssistantSpeakerButton extends StatelessWidget {
  final String arabicMessage;
  final String? englishMessage;
  final String tooltip;

  const VoiceAssistantSpeakerButton({
    super.key,
    required this.arabicMessage,
    this.englishMessage,
    this.tooltip = 'المساعد الصوتي',
  });

  @override
  Widget build(BuildContext context) {
    final service = VoiceAssistantService();

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final isEnabled = service.isEnabled;
        final isSpeaking = service.isSpeaking;

        return Tooltip(
          message: tooltip,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                service.speak(
                  context,
                  arabicText: arabicMessage,
                  englishText: englishMessage,
                );
              },
              onLongPress: () {
                service.toggleVoiceAssistance();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      service.isEnabled ? 'تم تفعيل المساعد الصوتي' : 'تم تعطيل المساعد الصوتي',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSpeaking
                      ? AppColors.primaryGreen.withValues(alpha: 0.25)
                      : (isEnabled
                          ? AppColors.primaryGreen.withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.15)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSpeaking
                        ? AppColors.primaryGreen
                        : (isEnabled
                            ? AppColors.primaryGreen.withValues(alpha: 0.4)
                            : Colors.transparent),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  color: isEnabled ? AppColors.primaryGreenDark : Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
