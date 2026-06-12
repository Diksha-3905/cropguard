import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gap/gap.dart';
import 'package:plant_diagnostics/models/diagnosis.dart';
import 'package:plant_diagnostics/services/voice_service.dart';

class VoicePanel extends StatefulWidget {
  final DiagnosisResult diagnosisContext;
  final VoidCallback onClose;

  const VoicePanel({super.key, required this.diagnosisContext, required this.onClose});

  @override
  State<VoicePanel> createState() => _VoicePanelState();
}

class _VoicePanelState extends State<VoicePanel> {
  final _voice = VoiceService.instance;
  final _controller = TextEditingController();
  final List<String> _transcript = [];

  @override
  void initState() {
    super.initState();
    _voice.transcriptStream.listen((text) {
      if (mounted) setState(() => _transcript.add(text));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: cs.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ask a question', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close), iconSize: 20),
            ],
          ),
          const Gap(8),
          if (_transcript.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: ListView(shrinkWrap: true,
                children: _transcript.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(t, style: const TextStyle(fontSize: 13, height: 1.4)),
                )).toList()),
            ),
          const Gap(12),
          StreamBuilder<VoiceState>(
            stream: _voice.stateStream,
            initialData: VoiceState.idle,
            builder: (context, snapshot) {
              final state = snapshot.data!;
              final isLoading = state == VoiceState.processing || state == VoiceState.speaking;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'e.g. How do I treat this?',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (v) => _send(),
                    ),
                  ),
                  const Gap(8),
                  isLoading
                      ? SizedBox(width: 48, height: 48,
                          child: Center(child: SpinKitThreeBounce(color: cs.primary, size: 20)))
                      : FilledButton(
                          onPressed: _send,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Icon(Icons.send_rounded),
                        ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _send() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    _controller.clear();
    _voice.askQuestion(q);
  }
}
