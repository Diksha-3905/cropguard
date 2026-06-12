import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:plant_diagnostics/models/diagnosis.dart';
import 'package:plant_diagnostics/services/voice_service.dart';
import 'package:plant_diagnostics/widgets/confidence_bar.dart';
import 'package:plant_diagnostics/widgets/voice_panel.dart';

class ResultScreen extends StatefulWidget {
  final String diagnosisId;
  final DiagnosisResult result;
  final File imageFile;
  final bool isOffline;

  const ResultScreen({
    super.key,
    required this.diagnosisId,
    required this.result,
    required this.imageFile,
    this.isOffline = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showVoicePanel = false;

  @override
  void initState() {
    super.initState();
    VoiceService.instance.startSession(widget.diagnosisId);
  }

  Color _severityColor(BuildContext context, String? severity) {
    final cs = Theme.of(context).colorScheme;
    switch (severity?.toLowerCase()) {
      case 'high':
      case 'severe':
        return cs.error;
      case 'medium':
      case 'moderate':
        return Colors.orange;
      case 'low':
      case 'mild':
        return Colors.green;
      default:
        return cs.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final result = widget.result;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: const Text('Diagnosis result'),
        actions: [
          if (widget.isOffline)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: const Text('Offline'),
                avatar: const Icon(Icons.wifi_off, size: 16),
                backgroundColor: cs.errorContainer,
                labelStyle: TextStyle(color: cs.onErrorContainer, fontSize: 12),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      widget.imageFile,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const Gap(20),

                  // OOD rejection
                  if (!result.isPlant)
                    _OodBanner()
                  else ...[
                    // Disease name
                    Text(
                      result.diseaseName ?? 'Unknown disease',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),

                    if (result.severity != null) ...[
                      const Gap(6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _severityColor(context, result.severity)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              result.severity!,
                              style: TextStyle(
                                color:
                                    _severityColor(context, result.severity),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const Gap(16),

                    // Confidence
                    if (result.confidence != null) ...[
                      ConfidenceBar(
                        label: 'Confidence',
                        value: result.confidence!,
                      ),
                      const Gap(20),
                    ],

                    // Summary
                    if (result.summary != null) ...[
                      Text(
                        'Summary',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Gap(8),
                      Text(
                        result.summary!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                      ),
                      const Gap(20),
                    ],

                    // Treatments
                    if (result.treatments?.isNotEmpty == true) ...[
                      Text(
                        'Treatment recommendations',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Gap(8),
                      ...result.treatments!.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${e.key + 1}',
                                      style: TextStyle(
                                        color: cs.onPrimaryContainer,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                Expanded(
                                  child: Text(
                                    e.value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Gap(20),
                    ],

                    // Disclaimer
                    if (result.disclaimer != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 16,
                                color: cs.onSurface.withOpacity(0.5)),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                result.disclaimer!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withOpacity(0.6),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],

                  // Spacer for FAB
                  const Gap(80),
                ],
              ),
            ),

            // Voice panel overlay
            if (_showVoicePanel)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VoicePanel(
                  diagnosisContext: result,
                  onClose: () => setState(() => _showVoicePanel = false),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: result.isPlant
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _showVoicePanel = !_showVoicePanel),
              icon: Icon(_showVoicePanel ? Icons.close : Icons.mic_rounded),
              label: Text(_showVoicePanel ? 'Close' : 'Ask a question'),
            )
          : null,
    );
  }
}

class _OodBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.block_rounded, size: 40, color: cs.error),
          const Gap(12),
          Text(
            'Not a plant image',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onErrorContainer,
            ),
          ),
          const Gap(8),
          Text(
            'This image doesn\'t appear to contain a plant leaf. Please capture a clear photo of a leaf for an accurate diagnosis.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onErrorContainer.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
