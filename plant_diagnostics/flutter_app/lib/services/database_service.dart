import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database_service.g.dart';

// ──────────────────────────────────────────────
// Table definitions
// ──────────────────────────────────────────────

class DiagnosesTable extends Table {
  TextColumn get id => text()();
  TextColumn get imageLocalPath => text()();
  TextColumn get imageRemoteUrl => text().nullable()();
  TextColumn get diseaseName => text().nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get severity => text().nullable()();
  TextColumn get treatmentAdvice => text().nullable()();
  TextColumn get rawResponse => text().nullable()();
  BoolColumn get isOod => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  TextColumn get vectorClockJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class VoiceSessionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get diagnosisId => text()();
  TextColumn get transcript => text()();
  TextColumn get responseText => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ──────────────────────────────────────────────
// Database
// ──────────────────────────────────────────────

@DriftDatabase(tables: [DiagnosesTable, VoiceSessionsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'plant_diagnostics_db');
  }

  // ── Diagnoses ──

  Future<List<DiagnosesTableData>> getPendingDiagnoses() =>
      (select(diagnosesTable)
            ..where((t) => t.status.equals('pending') | t.status.equals('failed')))
          .get();

  Future<List<DiagnosesTableData>> getAllDiagnoses() =>
      (select(diagnosesTable)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<void> upsertDiagnosis(DiagnosesTableCompanion entry) =>
      into(diagnosesTable).insertOnConflictUpdate(entry);

  Future<void> updateDiagnosisStatus(String id, String status) =>
      (update(diagnosesTable)..where((t) => t.id.equals(id)))
          .write(DiagnosesTableCompanion(status: Value(status)));

  Future<void> markSynced(String id, DateTime syncedAt) =>
      (update(diagnosesTable)..where((t) => t.id.equals(id))).write(
        DiagnosesTableCompanion(
          status: const Value('synced'),
          syncedAt: Value(syncedAt),
        ),
      );

  // ── Voice sessions ──

  Future<void> insertVoiceSession(VoiceSessionsTableCompanion entry) =>
      into(voiceSessionsTable).insert(entry);

  Future<List<VoiceSessionsTableData>> getSessionsForDiagnosis(
    String diagnosisId,
  ) =>
      (select(voiceSessionsTable)
            ..where((t) => t.diagnosisId.equals(diagnosisId)))
          .get();
}

// Singleton
class DatabaseService {
  DatabaseService._();
  static final instance = DatabaseService._();

  late AppDatabase _db;

  Future<void> init() async {
    _db = AppDatabase();
  }

  AppDatabase get db => _db;
}
