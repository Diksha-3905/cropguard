// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiagnosisImpl _$$DiagnosisImplFromJson(Map<String, dynamic> json) =>
    _$DiagnosisImpl(
      id: json['id'] as String,
      imageLocalPath: json['imageLocalPath'] as String,
      imageRemoteUrl: json['imageRemoteUrl'] as String?,
      diseaseName: json['diseaseName'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      severity: json['severity'] as String?,
      treatmentAdvice: json['treatmentAdvice'] as String?,
      rawResponse: json['rawResponse'] as String?,
      isOod: json['isOod'] as bool? ?? false,
      status: $enumDecodeNullable(_$DiagnosisStatusEnumMap, json['status']) ??
          DiagnosisStatus.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
      vectorClock: (json['vectorClock'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$DiagnosisImplToJson(_$DiagnosisImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageLocalPath': instance.imageLocalPath,
      'imageRemoteUrl': instance.imageRemoteUrl,
      'diseaseName': instance.diseaseName,
      'confidence': instance.confidence,
      'severity': instance.severity,
      'treatmentAdvice': instance.treatmentAdvice,
      'rawResponse': instance.rawResponse,
      'isOod': instance.isOod,
      'status': _$DiagnosisStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'vectorClock': instance.vectorClock,
    };

const _$DiagnosisStatusEnumMap = {
  DiagnosisStatus.pending: 'pending',
  DiagnosisStatus.syncing: 'syncing',
  DiagnosisStatus.synced: 'synced',
  DiagnosisStatus.failed: 'failed',
};

_$DiagnosisResultImpl _$$DiagnosisResultImplFromJson(
        Map<String, dynamic> json) =>
    _$DiagnosisResultImpl(
      isPlant: json['isPlant'] as bool,
      diseaseName: json['diseaseName'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      severity: json['severity'] as String?,
      treatments: (json['treatments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      summary: json['summary'] as String?,
      disclaimer: json['disclaimer'] as String?,
    );

Map<String, dynamic> _$$DiagnosisResultImplToJson(
        _$DiagnosisResultImpl instance) =>
    <String, dynamic>{
      'isPlant': instance.isPlant,
      'diseaseName': instance.diseaseName,
      'confidence': instance.confidence,
      'severity': instance.severity,
      'treatments': instance.treatments,
      'summary': instance.summary,
      'disclaimer': instance.disclaimer,
    };
