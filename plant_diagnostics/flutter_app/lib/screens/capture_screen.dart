import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:plant_diagnostics/models/diagnosis.dart';
import 'package:plant_diagnostics/screens/result_screen.dart';
import 'package:plant_diagnostics/services/diagnosis_api_service.dart';
import 'package:plant_diagnostics/services/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum _CaptureState { idle, loading, error }

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _picker = ImagePicker();
  File? _selectedImage;
  _CaptureState _state = _CaptureState.idle;
  String? _errorMsg;

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (xfile == null) return;
    setState(() {
      _selectedImage = File(xfile.path);
      _state = _CaptureState.idle;
      _errorMsg = null;
    });
  }

  Future<void> _diagnose() async {
    if (_selectedImage == null) return;

    setState(() => _state = _CaptureState.loading);

    final id = const Uuid().v4();

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    final hasNet = connectivity != ConnectivityResult.none;

    try {
      late DiagnosisResult result;

      if (hasNet) {
        // Online: call API directly
        result = await DiagnosisApiService.instance.withRetry(
          () => DiagnosisApiService.instance.diagnose(_selectedImage!),
        );
      } else {
        // Offline: create a placeholder result, queue for later
        result = const DiagnosisResult(
          isPlant: true,
          diseaseName: 'Pending (offline)',
          confidence: null,
          severity: 'Unknown',
          treatments: ['Will be determined when connectivity is restored.'],
          summary: 'Image queued. Diagnosis will complete on next sync.',
        );
      }

      // Always persist locally
      await SyncService.instance.enqueueDiagnosis(
        id: id,
        imageLocalPath: _selectedImage!.path,
        diagnosisData: {
          'disease_name': result.diseaseName,
          'confidence': result.confidence,
          'severity': result.severity,
          'treatment_advice': result.treatments?.join('\n'),
          'is_ood': !result.isPlant,
        },
      );

      // If online, try to sync immediately
      if (hasNet) unawaited(SyncService.instance.syncPending());

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            diagnosisId: id,
            result: result,
            imageFile: _selectedImage!,
            isOffline: !hasNet,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _state = _CaptureState.error;
        _errorMsg = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture leaf'),
        backgroundColor: cs.surface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Image preview
              Expanded(
                child: _selectedImage == null
                    ? _EmptyPreview()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
              const Gap(20),

              // Error state
              if (_state == _CaptureState.error)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: cs.error),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          _errorMsg ?? 'Something went wrong. Please retry.',
                          style: TextStyle(color: cs.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_state == _CaptureState.error) const Gap(12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                ],
              ),

              const Gap(12),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedImage == null || _state == _CaptureState.loading
                      ? null
                      : _diagnose,
                  icon: _state == _CaptureState.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(
                    _state == _CaptureState.loading ? 'Analyzing...' : 'Diagnose',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outline.withOpacity(0.4),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 56, color: cs.onSurface.withOpacity(0.4)),
          const Gap(12),
          Text(
            'Select or capture a leaf image',
            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

// Helper to fire-and-forget
void unawaited(Future<void> future) {
  future.ignore();
}
