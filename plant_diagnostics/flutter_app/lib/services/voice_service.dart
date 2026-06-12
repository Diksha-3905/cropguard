import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:plant_diagnostics/utils/env.dart';

enum VoiceState { idle, listening, processing, speaking, error }

/// Simplified voice service — uses text input fallback when mic unavailable.
/// Full STT streaming requires record package which has platform conflicts.
class VoiceService {
  VoiceService._();
  static final instance = VoiceService._();

  final _log = Logger();
  final _player = AudioPlayer();

  String? _currentDiagnosisId;
  String _lastError = '';

  final _stateController = StreamController<VoiceState>.broadcast();
  final _transcriptController = StreamController<String>.broadcast();

  Stream<VoiceState> get stateStream => _stateController.stream;
  Stream<String> get transcriptStream => _transcriptController.stream;
  String get lastError => _lastError;

  Future<void> startSession(String diagnosisId) async {
    _currentDiagnosisId = diagnosisId;
    _stateController.add(VoiceState.idle);
  }

  /// Send a text question to the backend (voice fallback).
  Future<void> askQuestion(String question) async {
    if (question.trim().isEmpty) return;
    _stateController.add(VoiceState.processing);

    try {
      final dio = Dio(BaseOptions(baseUrl: Env.backendUrl));
      final response = await dio.post('/voice/ask-text', data: {
        'question': question,
        'diagnosis_id': _currentDiagnosisId ?? '',
      });

      final reply = response.data['reply'] as String? ?? '';
      final audioB64 = response.data['audio_b64'] as String?;

      _transcriptController.add('You: $question\nCropGuard: $reply');

      if (audioB64 != null && audioB64.isNotEmpty) {
        _stateController.add(VoiceState.speaking);
        final bytes = base64Decode(audioB64);
        await _player.play(BytesSource(bytes));
      }
      _stateController.add(VoiceState.idle);
    } catch (e) {
      _log.e('Voice error: $e');
      _lastError = 'Could not get response. Please try again.';
      _stateController.add(VoiceState.error);
    }
  }

  void dispose() {
    _player.dispose();
    _stateController.close();
    _transcriptController.close();
  }
}
