// Импорт SQLite
import 'package:sqflite/sqflite.dart';

// Класс для работы с базой данных
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Получение экземпляра базы данных
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Инициализация базы данных
  Future<Database> _initDatabase() async {
    return await openDatabase(
      'calculator_app.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE settings (id INTEGER PRIMARY KEY, area TEXT)',
        );
      },
    );
  }

  // Сохранение области строительства
  Future<void> saveArea(String area) async {
    final db = await database;
    await db.insert(
      'settings',
      {'id': 1, 'area': area},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Получение текущей области
  Future<String?> getArea() async {
    final db = await database;
    final result = await db.query('settings');
    return result.isNotEmpty ? result[0]['area'] as String? : null;
  }

  // Обновление области
  Future<void> updateArea(String area) async {
    final db = await database;
    await db.update(
      'settings',
      {'area': area},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}