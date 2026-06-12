import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DiagnosisRow {
  final String id;
  final String imageLocalPath;
  final String? diseaseName;
  final double? confidence;
  final String? severity;
  final String? treatmentAdvice;
  final String? rawResponse;
  final bool isOod;
  final String status;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final String vectorClockJson;

  DiagnosisRow({
    required this.id,
    required this.imageLocalPath,
    this.diseaseName,
    this.confidence,
    this.severity,
    this.treatmentAdvice,
    this.rawResponse,
    required this.isOod,
    required this.status,
    required this.createdAt,
    this.syncedAt,
    required this.vectorClockJson,
  });

  factory DiagnosisRow.fromMap(Map<String, dynamic> map) => DiagnosisRow(
        id: map['id'] as String,
        imageLocalPath: map['image_local_path'] as String,
        diseaseName: map['disease_name'] as String?,
        confidence: map['confidence'] as double?,
        severity: map['severity'] as String?,
        treatmentAdvice: map['treatment_advice'] as String?,
        rawResponse: map['raw_response'] as String?,
        isOod: (map['is_ood'] as int) == 1,
        status: map['status'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        syncedAt: map['synced_at'] != null
            ? DateTime.parse(map['synced_at'] as String)
            : null,
        vectorClockJson: map['vector_clock_json'] as String? ?? '{}',
      );
}

class DatabaseService {
  DatabaseService._();
  static final instance = DatabaseService._();
  Database? _db;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'plant_diagnostics.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE diagnoses (
            id TEXT PRIMARY KEY,
            image_local_path TEXT NOT NULL,
            disease_name TEXT,
            confidence REAL,
            severity TEXT,
            treatment_advice TEXT,
            raw_response TEXT,
            is_ood INTEGER DEFAULT 0,
            status TEXT DEFAULT 'pending',
            created_at TEXT NOT NULL,
            synced_at TEXT,
            vector_clock_json TEXT DEFAULT '{}'
          )
        ''');
      },
    );
  }

  Database get db => _db!;

  Future<void> upsertDiagnosis(Map<String, dynamic> data) async {
    await db.insert(
      'diagnoses',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DiagnosisRow>> getPendingDiagnoses() async {
    final maps = await db.query(
      'diagnoses',
      where: "status = ? OR status = ?",
      whereArgs: ['pending', 'failed'],
    );
    return maps.map(DiagnosisRow.fromMap).toList();
  }

  Future<List<DiagnosisRow>> getAllDiagnoses() async {
    final maps = await db.query('diagnoses', orderBy: 'created_at DESC');
    return maps.map(DiagnosisRow.fromMap).toList();
  }

  Future<void> updateDiagnosisStatus(String id, String status) async {
    await db.update(
      'diagnoses',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSynced(String id, DateTime syncedAt) async {
    await db.update(
      'diagnoses',
      {'status': 'synced', 'synced_at': syncedAt.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
