// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnosis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Diagnosis _$DiagnosisFromJson(Map<String, dynamic> json) {
  return _Diagnosis.fromJson(json);
}

/// @nodoc
mixin _$Diagnosis {
  String get id => throw _privateConstructorUsedError;
  String get imageLocalPath => throw _privateConstructorUsedError;
  String? get imageRemoteUrl => throw _privateConstructorUsedError;
  String? get diseaseName => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;
  String? get severity => throw _privateConstructorUsedError;
  String? get treatmentAdvice => throw _privateConstructorUsedError;
  String? get rawResponse => throw _privateConstructorUsedError;
  bool get isOod =>
      throw _privateConstructorUsedError; // out-of-distribution (not a plant)
  DiagnosisStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get syncedAt =>
      throw _privateConstructorUsedError; // Vector clock for conflict resolution: {deviceId: lamportTimestamp}
  Map<String, int> get vectorClock => throw _privateConstructorUsedError;

  /// Serializes this Diagnosis to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Diagnosis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiagnosisCopyWith<Diagnosis> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiagnosisCopyWith<$Res> {
  factory $DiagnosisCopyWith(Diagnosis value, $Res Function(Diagnosis) then) =
      _$DiagnosisCopyWithImpl<$Res, Diagnosis>;
  @useResult
  $Res call(
      {String id,
      String imageLocalPath,
      String? imageRemoteUrl,
      String? diseaseName,
      double? confidence,
      String? severity,
      String? treatmentAdvice,
      String? rawResponse,
      bool isOod,
      DiagnosisStatus status,
      DateTime createdAt,
      DateTime? syncedAt,
      Map<String, int> vectorClock});
}

/// @nodoc
class _$DiagnosisCopyWithImpl<$Res, $Val extends Diagnosis>
    implements $DiagnosisCopyWith<$Res> {
  _$DiagnosisCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Diagnosis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageLocalPath = null,
    Object? imageRemoteUrl = freezed,
    Object? diseaseName = freezed,
    Object? confidence = freezed,
    Object? severity = freezed,
    Object? treatmentAdvice = freezed,
    Object? rawResponse = freezed,
    Object? isOod = null,
    Object? status = null,
    Object? createdAt = null,
    Object? syncedAt = freezed,
    Object? vectorClock = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageLocalPath: null == imageLocalPath
          ? _value.imageLocalPath
          : imageLocalPath // ignore: cast_nullable_to_non_nullable
              as String,
      imageRemoteUrl: freezed == imageRemoteUrl
          ? _value.imageRemoteUrl
          : imageRemoteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      diseaseName: freezed == diseaseName
          ? _value.diseaseName
          : diseaseName // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: freezed == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
      treatmentAdvice: freezed == treatmentAdvice
          ? _value.treatmentAdvice
          : treatmentAdvice // ignore: cast_nullable_to_non_nullable
              as String?,
      rawResponse: freezed == rawResponse
          ? _value.rawResponse
          : rawResponse // ignore: cast_nullable_to_non_nullable
              as String?,
      isOod: null == isOod
          ? _value.isOod
          : isOod // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DiagnosisStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncedAt: freezed == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vectorClock: null == vectorClock
          ? _value.vectorClock
          : vectorClock // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiagnosisImplCopyWith<$Res>
    implements $DiagnosisCopyWith<$Res> {
  factory _$$DiagnosisImplCopyWith(
          _$DiagnosisImpl value, $Res Function(_$DiagnosisImpl) then) =
      __$$DiagnosisImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String imageLocalPath,
      String? imageRemoteUrl,
      String? diseaseName,
      double? confidence,
      String? severity,
      String? treatmentAdvice,
      String? rawResponse,
      bool isOod,
      DiagnosisStatus status,
      DateTime createdAt,
      DateTime? syncedAt,
      Map<String, int> vectorClock});
}

/// @nodoc
class __$$DiagnosisImplCopyWithImpl<$Res>
    extends _$DiagnosisCopyWithImpl<$Res, _$DiagnosisImpl>
    implements _$$DiagnosisImplCopyWith<$Res> {
  __$$DiagnosisImplCopyWithImpl(
      _$DiagnosisImpl _value, $Res Function(_$DiagnosisImpl) _then)
      : super(_value, _then);

  /// Create a copy of Diagnosis
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageLocalPath = null,
    Object? imageRemoteUrl = freezed,
    Object? diseaseName = freezed,
    Object? confidence = freezed,
    Object? severity = freezed,
    Object? treatmentAdvice = freezed,
    Object? rawResponse = freezed,
    Object? isOod = null,
    Object? status = null,
    Object? createdAt = null,
    Object? syncedAt = freezed,
    Object? vectorClock = null,
  }) {
    return _then(_$DiagnosisImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageLocalPath: null == imageLocalPath
          ? _value.imageLocalPath
          : imageLocalPath // ignore: cast_nullable_to_non_nullable
              as String,
      imageRemoteUrl: freezed == imageRemoteUrl
          ? _value.imageRemoteUrl
          : imageRemoteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      diseaseName: freezed == diseaseName
          ? _value.diseaseName
          : diseaseName // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: freezed == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
      treatmentAdvice: freezed == treatmentAdvice
          ? _value.treatmentAdvice
          : treatmentAdvice // ignore: cast_nullable_to_non_nullable
              as String?,
      rawResponse: freezed == rawResponse
          ? _value.rawResponse
          : rawResponse // ignore: cast_nullable_to_non_nullable
              as String?,
      isOod: null == isOod
          ? _value.isOod
          : isOod // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DiagnosisStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncedAt: freezed == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vectorClock: null == vectorClock
          ? _value._vectorClock
          : vectorClock // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiagnosisImpl implements _Diagnosis {
  const _$DiagnosisImpl(
      {required this.id,
      required this.imageLocalPath,
      this.imageRemoteUrl,
      this.diseaseName,
      this.confidence,
      this.severity,
      this.treatmentAdvice,
      this.rawResponse,
      this.isOod = false,
      this.status = DiagnosisStatus.pending,
      required this.createdAt,
      this.syncedAt,
      final Map<String, int> vectorClock = const {}})
      : _vectorClock = vectorClock;

  factory _$DiagnosisImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiagnosisImplFromJson(json);

  @override
  final String id;
  @override
  final String imageLocalPath;
  @override
  final String? imageRemoteUrl;
  @override
  final String? diseaseName;
  @override
  final double? confidence;
  @override
  final String? severity;
  @override
  final String? treatmentAdvice;
  @override
  final String? rawResponse;
  @override
  @JsonKey()
  final bool isOod;
// out-of-distribution (not a plant)
  @override
  @JsonKey()
  final DiagnosisStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? syncedAt;
// Vector clock for conflict resolution: {deviceId: lamportTimestamp}
  final Map<String, int> _vectorClock;
// Vector clock for conflict resolution: {deviceId: lamportTimestamp}
  @override
  @JsonKey()
  Map<String, int> get vectorClock {
    if (_vectorClock is EqualUnmodifiableMapView) return _vectorClock;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_vectorClock);
  }

  @override
  String toString() {
    return 'Diagnosis(id: $id, imageLocalPath: $imageLocalPath, imageRemoteUrl: $imageRemoteUrl, diseaseName: $diseaseName, confidence: $confidence, severity: $severity, treatmentAdvice: $treatmentAdvice, rawResponse: $rawResponse, isOod: $isOod, status: $status, createdAt: $createdAt, syncedAt: $syncedAt, vectorClock: $vectorClock)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiagnosisImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageLocalPath, imageLocalPath) ||
                other.imageLocalPath == imageLocalPath) &&
            (identical(other.imageRemoteUrl, imageRemoteUrl) ||
                other.imageRemoteUrl == imageRemoteUrl) &&
            (identical(other.diseaseName, diseaseName) ||
                other.diseaseName == diseaseName) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.treatmentAdvice, treatmentAdvice) ||
                other.treatmentAdvice == treatmentAdvice) &&
            (identical(other.rawResponse, rawResponse) ||
                other.rawResponse == rawResponse) &&
            (identical(other.isOod, isOod) || other.isOod == isOod) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.syncedAt, syncedAt) ||
                other.syncedAt == syncedAt) &&
            const DeepCollectionEquality()
                .equals(other._vectorClock, _vectorClock));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      imageLocalPath,
      imageRemoteUrl,
      diseaseName,
      confidence,
      severity,
      treatmentAdvice,
      rawResponse,
      isOod,
      status,
      createdAt,
      syncedAt,
      const DeepCollectionEquality().hash(_vectorClock));

  /// Create a copy of Diagnosis
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiagnosisImplCopyWith<_$DiagnosisImpl> get copyWith =>
      __$$DiagnosisImplCopyWithImpl<_$DiagnosisImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiagnosisImplToJson(
      this,
    );
  }
}

abstract class _Diagnosis implements Diagnosis {
  const factory _Diagnosis(
      {required final String id,
      required final String imageLocalPath,
      final String? imageRemoteUrl,
      final String? diseaseName,
      final double? confidence,
      final String? severity,
      final String? treatmentAdvice,
      final String? rawResponse,
      final bool isOod,
      final DiagnosisStatus status,
      required final DateTime createdAt,
      final DateTime? syncedAt,
      final Map<String, int> vectorClock}) = _$DiagnosisImpl;

  factory _Diagnosis.fromJson(Map<String, dynamic> json) =
      _$DiagnosisImpl.fromJson;

  @override
  String get id;
  @override
  String get imageLocalPath;
  @override
  String? get imageRemoteUrl;
  @override
  String? get diseaseName;
  @override
  double? get confidence;
  @override
  String? get severity;
  @override
  String? get treatmentAdvice;
  @override
  String? get rawResponse;
  @override
  bool get isOod; // out-of-distribution (not a plant)
  @override
  DiagnosisStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime?
      get syncedAt; // Vector clock for conflict resolution: {deviceId: lamportTimestamp}
  @override
  Map<String, int> get vectorClock;

  /// Create a copy of Diagnosis
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiagnosisImplCopyWith<_$DiagnosisImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiagnosisResult _$DiagnosisResultFromJson(Map<String, dynamic> json) {
  return _DiagnosisResult.fromJson(json);
}

/// @nodoc
mixin _$DiagnosisResult {
  bool get isPlant => throw _privateConstructorUsedError;
  String? get diseaseName => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;
  String? get severity => throw _privateConstructorUsedError;
  List<String>? get treatments => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  String? get disclaimer => throw _privateConstructorUsedError;

  /// Serializes this DiagnosisResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiagnosisResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiagnosisResultCopyWith<DiagnosisResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiagnosisResultCopyWith<$Res> {
  factory $DiagnosisResultCopyWith(
          DiagnosisResult value, $Res Function(DiagnosisResult) then) =
      _$DiagnosisResultCopyWithImpl<$Res, DiagnosisResult>;
  @useResult
  $Res call(
      {bool isPlant,
      String? diseaseName,
      double? confidence,
      String? severity,
      List<String>? treatments,
      String? summary,
      String? disclaimer});
}

/// @nodoc
class _$DiagnosisResultCopyWithImpl<$Res, $Val extends DiagnosisResult>
    implements $DiagnosisResultCopyWith<$Res> {
  _$DiagnosisResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiagnosisResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlant = null,
    Object? diseaseName = freezed,
    Object? confidence = freezed,
    Object? severity = freezed,
    Object? treatments = freezed,
    Object? summary = freezed,
    Object? disclaimer = freezed,
  }) {
    return _then(_value.copyWith(
      isPlant: null == isPlant
          ? _value.isPlant
          : isPlant // ignore: cast_nullable_to_non_nullable
              as bool,
      diseaseName: freezed == diseaseName
          ? _value.diseaseName
          : diseaseName // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: freezed == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
      treatments: freezed == treatments
          ? _value.treatments
          : treatments // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      disclaimer: freezed == disclaimer
          ? _value.disclaimer
          : disclaimer // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiagnosisResultImplCopyWith<$Res>
    implements $DiagnosisResultCopyWith<$Res> {
  factory _$$DiagnosisResultImplCopyWith(_$DiagnosisResultImpl value,
          $Res Function(_$DiagnosisResultImpl) then) =
      __$$DiagnosisResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isPlant,
      String? diseaseName,
      double? confidence,
      String? severity,
      List<String>? treatments,
      String? summary,
      String? disclaimer});
}

/// @nodoc
class __$$DiagnosisResultImplCopyWithImpl<$Res>
    extends _$DiagnosisResultCopyWithImpl<$Res, _$DiagnosisResultImpl>
    implements _$$DiagnosisResultImplCopyWith<$Res> {
  __$$DiagnosisResultImplCopyWithImpl(
      _$DiagnosisResultImpl _value, $Res Function(_$DiagnosisResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiagnosisResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlant = null,
    Object? diseaseName = freezed,
    Object? confidence = freezed,
    Object? severity = freezed,
    Object? treatments = freezed,
    Object? summary = freezed,
    Object? disclaimer = freezed,
  }) {
    return _then(_$DiagnosisResultImpl(
      isPlant: null == isPlant
          ? _value.isPlant
          : isPlant // ignore: cast_nullable_to_non_nullable
              as bool,
      diseaseName: freezed == diseaseName
          ? _value.diseaseName
          : diseaseName // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: freezed == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
      treatments: freezed == treatments
          ? _value._treatments
          : treatments // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      disclaimer: freezed == disclaimer
          ? _value.disclaimer
          : disclaimer // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiagnosisResultImpl implements _DiagnosisResult {
  const _$DiagnosisResultImpl(
      {required this.isPlant,
      this.diseaseName,
      this.confidence,
      this.severity,
      final List<String>? treatments,
      this.summary,
      this.disclaimer})
      : _treatments = treatments;

  factory _$DiagnosisResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiagnosisResultImplFromJson(json);

  @override
  final bool isPlant;
  @override
  final String? diseaseName;
  @override
  final double? confidence;
  @override
  final String? severity;
  final List<String>? _treatments;
  @override
  List<String>? get treatments {
    final value = _treatments;
    if (value == null) return null;
    if (_treatments is EqualUnmodifiableListView) return _treatments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? summary;
  @override
  final String? disclaimer;

  @override
  String toString() {
    return 'DiagnosisResult(isPlant: $isPlant, diseaseName: $diseaseName, confidence: $confidence, severity: $severity, treatments: $treatments, summary: $summary, disclaimer: $disclaimer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiagnosisResultImpl &&
            (identical(other.isPlant, isPlant) || other.isPlant == isPlant) &&
            (identical(other.diseaseName, diseaseName) ||
                other.diseaseName == diseaseName) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            const DeepCollectionEquality()
                .equals(other._treatments, _treatments) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.disclaimer, disclaimer) ||
                other.disclaimer == disclaimer));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isPlant,
      diseaseName,
      confidence,
      severity,
      const DeepCollectionEquality().hash(_treatments),
      summary,
      disclaimer);

  /// Create a copy of DiagnosisResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiagnosisResultImplCopyWith<_$DiagnosisResultImpl> get copyWith =>
      __$$DiagnosisResultImplCopyWithImpl<_$DiagnosisResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiagnosisResultImplToJson(
      this,
    );
  }
}

abstract class _DiagnosisResult implements DiagnosisResult {
  const factory _DiagnosisResult(
      {required final bool isPlant,
      final String? diseaseName,
      final double? confidence,
      final String? severity,
      final List<String>? treatments,
      final String? summary,
      final String? disclaimer}) = _$DiagnosisResultImpl;

  factory _DiagnosisResult.fromJson(Map<String, dynamic> json) =
      _$DiagnosisResultImpl.fromJson;

  @override
  bool get isPlant;
  @override
  String? get diseaseName;
  @override
  double? get confidence;
  @override
  String? get severity;
  @override
  List<String>? get treatments;
  @override
  String? get summary;
  @override
  String? get disclaimer;

  /// Create a copy of DiagnosisResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiagnosisResultImplCopyWith<_$DiagnosisResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
