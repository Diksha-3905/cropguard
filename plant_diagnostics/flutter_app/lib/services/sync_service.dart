import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:plant_diagnostics/services/database_service.dart';
import 'package:plant_diagnostics/services/diagnosis_api_service.dart';

/// Manages offline queueing and conflict-resolving sync.
/// 
/// Conflict strategy: vector clocks with merge semantics.
/// - Each device tracks a Lamport-like clock per entry.
/// - On sync, the server merges using the highest clock value per field.
/// - If clocks are equal (concurrent edit), server wins for diagnosis fields,
///   local wins for user-added notes.
class SyncService {
  SyncService._();
  static final instance = SyncService._();

  final _log = Logger();
  final _uuid = const Uuid();
  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  final _syncController = StreamController<SyncState>.broadcast();
  Stream<SyncState> get syncStream => _syncController.stream;

  late final String _deviceId;

  Future<void> init() async {
    _deviceId = await _getOrCreateDeviceId();
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      (results) {
        final hasNet = results.any((r) => r != ConnectivityResult.none);
        if (hasNet) {
          _log.i('Connectivity restored — triggering sync');
          syncPending();
        }
      },
    );
  }

  Future<String> _getOrCreateDeviceId() async {
    // In real app use flutter_secure_storage; simplified here
    const key = 'device_id';
    // Return fixed id for now; replace with SharedPreferences read/write
    return 'device_${_uuid.v4().substring(0, 8)}';
  }

  /// Increments the local vector clock for this device.
  Map<String, int> _incrementClock(Map<String, int> clock) {
    final updated = Map<String, int>.from(clock);
    updated[_deviceId] = (updated[_deviceId] ?? 0) + 1;
    return updated;
  }

  /// Merges two vector clocks by taking the max of each entry.
  static Map<String, int> mergeClocks(
    Map<String, int> a,
    Map<String, int> b,
  ) {
    final result = Map<String, int>.from(a);
    b.forEach((k, v) {
      result[k] = result.containsKey(k) ? (result[k]! > v ? result[k]! : v) : v;
    });
    return result;
  }

  /// Compares clocks: returns -1 (a<b), 0 (concurrent), 1 (a>b).
  static int compareClock(Map<String, int> a, Map<String, int> b) {
    final keys = {...a.keys, ...b.keys};
    bool aLeadsAnywhere = false;
    bool bLeadsAnywhere = false;
    for (final k in keys) {
      final av = a[k] ?? 0;
      final bv = b[k] ?? 0;
      if (av > bv) aLeadsAnywhere = true;
      if (bv > av) bLeadsAnywhere = true;
    }
    if (aLeadsAnywhere && !bLeadsAnywhere) return 1;
    if (bLeadsAnywhere && !aLeadsAnywhere) return -1;
    return 0; // concurrent
  }

  /// Enqueue a new diagnosis locally with pending status.
  Future<void> enqueueDiagnosis({
    required String id,
    required String imageLocalPath,
    required Map<String, dynamic> diagnosisData,
  }) async {
    final clock = _incrementClock({});
    final db = DatabaseService.instance.db;
    await db.upsertDiagnosis(
      DiagnosesTableCompanion(
        id: Value(id),
        imageLocalPath: Value(imageLocalPath),
        diseaseName: Value(diagnosisData['disease_name'] as String?),
        confidence: Value((diagnosisData['confidence'] as num?)?.toDouble()),
        severity: Value(diagnosisData['severity'] as String?),
        treatmentAdvice: Value(diagnosisData['treatment_advice'] as String?),
        rawResponse: Value(jsonEncode(diagnosisData)),
        isOod: Value(diagnosisData['is_ood'] as bool? ?? false),
        status: const Value('pending'),
        createdAt: Value(DateTime.now()),
        vectorClockJson: Value(jsonEncode(clock)),
      ),
    );
  }

  /// Syncs all pending/failed diagnoses to backend.
  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _syncController.add(const SyncState.syncing());

    try {
      final db = DatabaseService.instance.db;
      final pending = await db.getPendingDiagnoses();
      if (pending.isEmpty) {
        _syncController.add(const SyncState.idle());
        return;
      }

      _log.i('Syncing ${pending.length} pending diagnoses');

      final payload = pending.map((d) => {
        'id': d.id,
        'disease_name': d.diseaseName,
        'confidence': d.confidence,
        'severity': d.severity,
        'treatment_advice': d.treatmentAdvice,
        'is_ood': d.isOod,
        'created_at': d.createdAt.toIso8601String(),
        'vector_clock': jsonDecode(d.vectorClockJson) as Map<String, dynamic>,
      }).toList();

      final results = await DiagnosisApiService.instance.withRetry(
        () => DiagnosisApiService.instance.syncDiagnoses(payload),
      );

      for (final result in results) {
        final id = result['id'] as String;
        final serverStatus = result['status'] as String;
        if (serverStatus == 'accepted' || serverStatus == 'merged') {
          await db.markSynced(id, DateTime.now());
        } else if (serverStatus == 'conflict_resolved') {
          // Server resolved conflict — update local with server version
          final serverData = result['resolved'] as Map<String, dynamic>;
          await db.upsertDiagnosis(DiagnosesTableCompanion(
            id: Value(id),
            diseaseName: Value(serverData['disease_name'] as String?),
            confidence: Value((serverData['confidence'] as num?)?.toDouble()),
            severity: Value(serverData['severity'] as String?),
            status: const Value('synced'),
            syncedAt: Value(DateTime.now()),
          ));
        }
      }

      _syncController.add(SyncState.done(synced: results.length));
    } catch (e) {
      _log.e('Sync failed: $e');
      _syncController.add(SyncState.error(e.toString()));
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _syncController.close();
  }
}

// Sealed sync states
sealed class SyncState {
  const SyncState();
  const factory SyncState.idle() = _Idle;
  const factory SyncState.syncing() = _Syncing;
  const factory SyncState.done({required int synced}) = _Done;
  const factory SyncState.error(String message) = _Error;
}

class _Idle extends SyncState { const _Idle(); }
class _Syncing extends SyncState { const _Syncing(); }
class _Done extends SyncState {
  final int synced;
  const _Done({required this.synced});
}
class _Error extends SyncState {
  final String message;
  const _Error(this.message);
}
