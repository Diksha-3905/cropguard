import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:plant_diagnostics/services/database_service.dart';

class SyncService {
  SyncService._();
  static final instance = SyncService._();

  final _log = Logger();
  final _uuid = const Uuid();
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  final _syncController = StreamController<SyncState>.broadcast();
  Stream<SyncState> get syncStream => _syncController.stream;

  late final String _deviceId;

  Future<void> init() async {
    _deviceId = _uuid.v4().substring(0, 8);
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      final hasNet = result != ConnectivityResult.none;
      if (hasNet) syncPending();
    });
  }

  Map<String, int> _incrementClock(Map<String, int> clock) {
    final updated = Map<String, int>.from(clock);
    updated[_deviceId] = (updated[_deviceId] ?? 0) + 1;
    return updated;
  }

  static Map<String, int> mergeClocks(Map<String, int> a, Map<String, int> b) {
    final result = Map<String, int>.from(a);
    b.forEach((k, v) {
      result[k] = result.containsKey(k) ? (result[k]! > v ? result[k]! : v) : v;
    });
    return result;
  }

  static int compareClock(Map<String, int> a, Map<String, int> b) {
    final keys = {...a.keys, ...b.keys};
    bool aLeads = false, bLeads = false;
    for (final k in keys) {
      if ((a[k] ?? 0) > (b[k] ?? 0)) aLeads = true;
      if ((b[k] ?? 0) > (a[k] ?? 0)) bLeads = true;
    }
    if (aLeads && !bLeads) return 1;
    if (bLeads && !aLeads) return -1;
    return 0;
  }

  Future<void> enqueueDiagnosis({
    required String id,
    required String imageLocalPath,
    required Map<String, dynamic> diagnosisData,
  }) async {
    final clock = _incrementClock({});
    await DatabaseService.instance.upsertDiagnosis({
      'id': id,
      'image_local_path': imageLocalPath,
      'disease_name': diagnosisData['disease_name'],
      'confidence': diagnosisData['confidence'],
      'severity': diagnosisData['severity'],
      'treatment_advice': diagnosisData['treatment_advice'],
      'raw_response': jsonEncode(diagnosisData),
      'is_ood': (diagnosisData['is_ood'] as bool? ?? false) ? 1 : 0,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
      'vector_clock_json': jsonEncode(clock),
    });
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _syncController.add(SyncState.syncing);

    try {
      final pending = await DatabaseService.instance.getPendingDiagnoses();
      if (pending.isEmpty) {
        _syncController.add(SyncState.idle);
        return;
      }

      int synced = 0;
      for (final d in pending) {
        try {
          final incomingClock = Map<String, int>.from(
              jsonDecode(d.vectorClockJson) as Map);
          final docRef = _firestore.collection('diagnoses').doc(d.id);
          final docSnap = await docRef.get();

          if (!docSnap.exists) {
            await docRef.set({
              'id': d.id,
              'disease_name': d.diseaseName,
              'confidence': d.confidence,
              'severity': d.severity,
              'treatment_advice': d.treatmentAdvice,
              'is_ood': d.isOod,
              'created_at': d.createdAt.toIso8601String(),
              'vector_clock': incomingClock,
            });
          } else {
            final stored = docSnap.data()!;
            final storedClock = Map<String, int>.from(
                stored['vector_clock'] as Map? ?? {});
            final cmp = compareClock(incomingClock, storedClock);
            if (cmp >= 0) {
              await docRef.update({
                'disease_name': d.diseaseName,
                'confidence': d.confidence,
                'severity': d.severity,
                'vector_clock': mergeClocks(incomingClock, storedClock),
              });
            }
          }
          await DatabaseService.instance.markSynced(d.id, DateTime.now());
          synced++;
        } catch (e) {
          _log.e('Failed to sync ${d.id}: $e');
          await DatabaseService.instance.updateDiagnosisStatus(d.id, 'failed');
        }
      }
      _syncController.add(SyncState.done);
    } catch (e) {
      _syncController.add(SyncState.error);
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _syncController.close();
  }
}

enum SyncState { idle, syncing, done, error }
