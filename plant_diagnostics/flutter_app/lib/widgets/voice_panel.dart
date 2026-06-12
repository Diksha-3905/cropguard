import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:plant_diagnostics/models/diagnosis.dart';
import 'package:plant_diagnostics/services/voice_service.dart';

class VoicePanel extends StatefulWidget {
  final DiagnosisResult diagnosisContext;
  final VoidCallback onClose;

  const VoicePanel({
    super.key,
    required this.diagnosisContext,
    required this.onClose,
  });

  @override
  State<VoicePanel> createState() => _VoicePanelState();
}

class _VoicePanelState extends State<VoicePanel> {
  final _voice = VoiceService.instance;
  final List<String> _transcript = [];

  @override
  void initState() {
    super.initState();
    _voice.transcriptStream.listen((text) {
      if (mounted) setState(() => _transcript.add(text));
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Gap(12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Voice Q&A',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
                iconSize: 20,
              ),
            ],
          ),

          const Gap(8),

          // Transcript area
          if (_transcript.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView(
                shrinkWrap: true,
                children: _transcript
                    .map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            t,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ))
                    .toList(),
              ),
            ),

          const Gap(16),

          // Voice state + mic button
          StreamBuilder<VoiceState>(
            stream: _voice.stateStream,
            initialData: const VoiceState.idle(),
            builder: (context, snapshot) {
              final state = snapshot.data!;

              return Column(
                children: [
                  // Visual feedback
                  SizedBox(
                    height: 48,
                    child: switch (state) {
                      _Listening() => SpinKitWave(
                          color: cs.primary,
                          size: 32,
                        ),
                      _Processing() => SpinKitThreeBounce(
                          color: cs.primary,
                          size: 24,
                        ),
                      _Speaking() => SpinKitPulse(
                          color: cs.secondary,
                          size: 32,
                        ),
                      _ => Text(
                          state is _Error
                              ? (state as _Error).msg
                              : 'Tap to ask a question',
                          style: TextStyle(
                            color: state is _Error
                                ? cs.error
                                : cs.onSurface.withOpacity(0.5),
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    },
                  ),

                  const Gap(12),

                  // Mic button (tap to speak; tap again to interrupt TTS)
                  GestureDetector(
                    onTap: () {
                      if (state is _Listening) {
                        _voice.stopListening();
                      } else {
                        _voice.startListening();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: state is _Listening
                            ? cs.error
                            : state is _Speaking
                                ? cs.secondary
                                : cs.primary,
                      ),
                      child: Icon(
                        state is _Listening
                            ? Icons.stop_rounded
                            : state is _Speaking
                                ? Icons.volume_up_rounded
                                : Icons.mic_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
