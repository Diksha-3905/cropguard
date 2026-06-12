import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:plant_diagnostics/models/diagnosis.dart';
import 'package:plant_diagnostics/utils/env.dart';

class DiagnosisApiService {
  DiagnosisApiService._();
  static final instance = DiagnosisApiService._();

  final _log = Logger();
  late final Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.backendUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) {
          _log.e('API error: ${e.message}');
          handler.next(e);
        },
      ),
    );
  }

  /// Send image file for diagnosis. Returns DiagnosisResult.
  Future<DiagnosisResult> diagnose(File imageFile) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'leaf.jpg',
      ),
    });

    final response = await _dio.post('/diagnose', data: formData);
    return DiagnosisResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// Sync a list of local diagnoses to the backend (idempotent).
  Future<List<Map<String, dynamic>>> syncDiagnoses(
    List<Map<String, dynamic>> diagnoses,
  ) async {
    final response = await _dio.post('/sync', data: {'diagnoses': diagnoses});
    return List<Map<String, dynamic>>.from(response.data['results'] as List);
  }

  /// Retries with exponential backoff.
  Future<T> withRetry<T>(
    Future<T> Function() fn, {
    int maxAttempts = 3,
  }) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await fn();
      } on DioException catch (e) {
        if (attempt == maxAttempts) rethrow;
        if (e.response?.statusCode != null &&
            e.response!.statusCode! < 500) rethrow;
        await Future.delayed(Duration(seconds: attempt * 2));
        _log.w('Retry $attempt/$maxAttempts after error: ${e.message}');
      }
    }
    throw Exception('Max retries exceeded');
  }
}
