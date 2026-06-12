import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:plant_diagnostics/utils/env.dart';

/// Real-time voice Q&A service.
/// 
/// Pipeline: Microphone → Deepgram STT (streaming) → FastAPI LLM agent 
/// → ElevenLabs TTS → AudioPlayer
/// 
/// Barge-in: if user speaks while TTS is playing, we stop playback
/// immediately and process the new utterance.
class VoiceService {
  VoiceService._();
  static final instance = VoiceService._();

  final _log = Logger();
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();

  bool _isListening = false;
  bool _isSpeaking = false;
  String? _currentDiagnosisId;

  final _stateController = StreamController<VoiceState>.broadcast();
  final _transcriptController = StreamController<String>.broadcast();

  Stream<VoiceState> get stateStream => _stateController.stream;
  Stream<String> get transcriptStream => _transcriptController.stream;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  Future<bool> requestPermissions() async {
    return await _recorder.hasPermission();
  }

  /// Start a voice session for a given diagnosis.
  Future<void> startSession(String diagnosisId) async {
    _currentDiagnosisId = diagnosisId;
    _stateController.add(const VoiceState.idle());
  }

  /// Begin listening for user speech.
  /// If TTS is playing (barge-in), stop it first.
  Future<void> startListening() async {
    if (_isSpeaking) {
      await _player.stop();
      _isSpeaking = false;
      _log.i('Barge-in detected — stopped TTS playback');
    }

    if (!await _recorder.hasPermission()) {
      _stateController.add(const VoiceState.error('Microphone permission denied'));
      return;
    }

    _isListening = true;
    _stateController.add(const VoiceState.listening());

    // Record to bytes (simplified — real app streams to Deepgram WebSocket)
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    // Collect audio chunks with silence detection (VAD)
    final buffer = <int>[];
    StreamSubscription? sub;
    Timer? silenceTimer;

    sub = stream.listen((data) {
      buffer.addAll(data);

      // Reset silence timer on audio
      silenceTimer?.cancel();
      silenceTimer = Timer(const Duration(milliseconds: 800), () async {
        // Silence detected — end utterance
        await sub?.cancel();
        await _recorder.stop();
        _isListening = false;

        if (buffer.isNotEmpty) {
          await _processAudio(Uint8List.fromList(buffer));
        }
      });
    });
  }

  Future<void> _processAudio(Uint8List audioBytes) async {
    _stateController.add(const VoiceState.processing());

    try {
      final dio = Dio(BaseOptions(baseUrl: Env.backendUrl));

      // Send audio to backend STT→LLM→TTS endpoint
      final formData = FormData.fromMap({
        'audio': MultipartFile.fromBytes(
          audioBytes,
          filename: 'speech.pcm',
        ),
        'diagnosis_id': _currentDiagnosisId ?? '',
        'sample_rate': '16000',
      });

      final response = await dio.post(
        '/voice/ask',
        data: formData,
        options: Options(responseType: ResponseType.json),
      );

      final transcript = response.data['transcript'] as String;
      final reply = response.data['reply'] as String;
      final audioBase64 = response.data['audio_b64'] as String?;

      _transcriptController.add('You: $transcript\nCropGuard: $reply');

      if (audioBase64 != null) {
        await _playBase64Audio(audioBase64);
      }
    } catch (e) {
      _log.e('Voice processing error: $e');
      _stateController.add(VoiceState.error(e.toString()));
    }
  }

  Future<void> _playBase64Audio(String base64Audio) async {
    _isSpeaking = true;
    _stateController.add(const VoiceState.speaking());

    try {
      final bytes = base64Decode(base64Audio);
      // Write to temp file and play
      final source = LockCachingAudioSource(
        Uri.parse('data:audio/mpeg;base64,$base64Audio'),
      );
      await _player.setAudioSource(source);
      await _player.play();
    } finally {
      _isSpeaking = false;
      _stateController.add(const VoiceState.idle());
    }
  }

  Future<void> stopListening() async {
    await _recorder.stop();
    _isListening = false;
  }

  Future<void> stopSpeaking() async {
    await _player.stop();
    _isSpeaking = false;
  }

  void dispose() {
    _recorder.dispose();
    _player.dispose();
    _stateController.close();
    _transcriptController.close();
  }
}

sealed class VoiceState {
  const VoiceState();
  const factory VoiceState.idle() = _Idle;
  const factory VoiceState.listening() = _Listening;
  const factory VoiceState.processing() = _Processing;
  const factory VoiceState.speaking() = _Speaking;
  const factory VoiceState.error(String msg) = _Error;
}

class _Idle extends VoiceState { const _Idle(); }
class _Listening extends VoiceState { const _Listening(); }
class _Processing extends VoiceState { const _Processing(); }
class _Speaking extends VoiceState { const _Speaking(); }
class _Error extends VoiceState {
  final String msg;
  const _Error(this.msg);
}
