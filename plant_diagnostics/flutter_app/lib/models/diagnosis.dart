import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnosis.freezed.dart';
part 'diagnosis.g.dart';

enum DiagnosisStatus { pending, syncing, synced, failed }

@freezed
class Diagnosis with _$Diagnosis {
  const factory Diagnosis({
    required String id,
    required String imageLocalPath,
    String? imageRemoteUrl,
    String? diseaseName,
    double? confidence,
    String? severity,
    String? treatmentAdvice,
    String? rawResponse,
    @Default(false) bool isOod, // out-of-distribution (not a plant)
    @Default(DiagnosisStatus.pending) DiagnosisStatus status,
    required DateTime createdAt,
    DateTime? syncedAt,
    // Vector clock for conflict resolution: {deviceId: lamportTimestamp}
    @Default({}) Map<String, int> vectorClock,
  }) = _Diagnosis;

  factory Diagnosis.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisFromJson(json);
}

@freezed
class DiagnosisResult with _$DiagnosisResult {
  const factory DiagnosisResult({
    required bool isPlant,
    String? diseaseName,
    double? confidence,
    String? severity,
    List<String>? treatments,
    String? summary,
    String? disclaimer,
  }) = _DiagnosisResult;

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisResultFromJson(json);
}
