import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient.dart';
import '../models/health_record.dart'; // Import HealthRecord model

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('patients.db');
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(
      path,
      version: 6, // Incremented version from 5 to 6
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE patients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      age INTEGER NOT NULL,
      condition TEXT NOT NULL,
      body_temperature REAL,
      systolic INTEGER,
      diastolic INTEGER,
      blood_glucose_level REAL,
      sex TEXT
    )
    ''');
    
    await db.execute('''
    CREATE TABLE health_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      patient_id INTEGER NOT NULL,
      body_temperature REAL,
      systolic INTEGER,
      diastolic INTEGER,
      blood_glucose_level REAL,
      blood_oxygen_level REAL,
      heart_rate INTEGER,
      condition TEXT,
      timestamp TEXT NOT NULL,
      FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
    )
    ''');
  }

  // Handle database upgrade
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE patients ADD COLUMN body_temperature REAL;
      ''');
      await db.execute('''
        ALTER TABLE patients ADD COLUMN blood_glucose_level REAL;
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE patients ADD COLUMN systolic INTEGER;
      ''');
      await db.execute('''
        ALTER TABLE patients ADD COLUMN diastolic INTEGER;
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE patients ADD COLUMN sex TEXT;
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS health_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          patient_id INTEGER NOT NULL,
          body_temperature REAL,
          systolic INTEGER,
          diastolic INTEGER,
          blood_glucose_level REAL,
          condition TEXT,
          timestamp TEXT NOT NULL,
          FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5) { // Added block for version <5
      await db.execute('''
        CREATE TABLE IF NOT EXISTS health_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          patient_id INTEGER NOT NULL,
          body_temperature REAL,
          systolic INTEGER,
          diastolic INTEGER,
          blood_glucose_level REAL,
          condition TEXT,
          timestamp TEXT NOT NULL,
          FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 6) { // Added block for version <6
      await db.execute('''
        ALTER TABLE health_records ADD COLUMN blood_oxygen_level REAL;
      ''');
      await db.execute('''
        ALTER TABLE health_records ADD COLUMN heart_rate INTEGER;
      ''');
    }
  }

  Future<int> insertPatient(Patient patient) async {
    final db = await instance.database;
    return await db.insert('patients', patient.toMap());
  }

  Future<List<Patient>> getPatients() async {
    final db = await instance.database;
    final maps = await db.query('patients');

    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  Future<int> deletePatient(int id) async {
    final db = await instance.database;
    return await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePatients(List<int> ids) async {
    final db = await instance.database;
    // Use parameterized queries for safety
    String whereClause = 'id IN (${List.filled(ids.length, '?').join(',')})';
    return await db.delete(
      'patients',
      where: whereClause,
      whereArgs: ids,
    );
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await instance.database;
    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  // CRUD operations for HealthRecord

  Future<int> insertHealthRecord(HealthRecord record) async {
    final db = await instance.database;
    return await db.insert('health_records', record.toMap());
  }

  Future<List<HealthRecord>> getHealthRecords(int patientId) async {
    final db = await instance.database;
    final maps = await db.query(
      'health_records',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => HealthRecord.fromMap(map)).toList();
  }

  Future<int> deleteHealthRecord(int id) async {
    final db = await instance.database;
    return await db.delete(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateHealthRecord(HealthRecord record) async {
    final db = await instance.database;
    return await db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Define CRUD operations here
}