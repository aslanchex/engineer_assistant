import 'package:engineer_assistant/data/db_seeder.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE areas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        gender TEXT,
        birth_date TEXT,
        position TEXT,
        organization TEXT,
        area_id INTEGER,
        FOREIGN KEY (area_id) REFERENCES areas(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE subdivisions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        area_id INTEGER NOT NULL,
        FOREIGN KEY (area_id) REFERENCES areas(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE calculators (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calc_name TEXT NOT NULL,
        subd_id INTEGER NOT NULL,
        FOREIGN KEY (subd_id) REFERENCES subdivisions(id)
      )
    ''');

    // Заполнение начальными данными
    final seeder = DatabaseSeeder();
    await seeder.seed(db);
  }

  Future<List<Map<String, dynamic>>> getAreas() async {
    final db = await database;
    return await db.query('areas');
  }

  Future<List<Map<String, dynamic>>> getSubdivisionsByArea(int areaId) async {
    final db = await database;
    return await db.query('subdivisions', where: 'area_id = ?', whereArgs: [areaId]);
  }

  Future<List<Map<String, dynamic>>> getCalculatorsBySubdivision(int subdId) async {
    final db = await database;
    return await db.query('calculators', where: 'subd_id = ?', whereArgs: [subdId]);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUser({required int id, int? areaId}) async {
    final db = await database;
    await db.update('users', {'area_id': areaId}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateUserFull({
    required int id,
    required String firstName,
    required String lastName,
    required String gender,
    required String birthDate,
    required String position,
    required String organization,
  }) async {
    final db = await database;
    await db.update(
      'users',
      {
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'birth_date': birthDate,
        'position': position,
        'organization': organization,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String?> getAreaName(int areaId) async {
    final db = await database;
    final result = await db.query('areas', where: 'id = ?', whereArgs: [areaId], limit: 1);
    return result.isNotEmpty ? result.first['name'] as String? : null;
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');
    await deleteDatabase(path);
    _database = null;
    await database; // Пересоздаём базу
  }
}