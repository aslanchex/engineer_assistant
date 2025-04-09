import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    developer.log(
      'Initializing database...',
      name: 'DatabaseHelper',
    ); // <<<< Добавлено логирование

    // Изменено: Добавлены таблицы areas и calculators
    return await openDatabase(
      'calculator_app.db',
      version: 1,
      onCreate: (db, version) async {
        developer.log(
          'Creating tables...',
          name: 'DatabaseHelper',
        ); // <<<< Добавлено логирование

        // Таблица Users
        await db.execute('''
          CREATE TABLE Users (
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

        // Таблица areas
        await db.execute('''
          CREATE TABLE areas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');

        // Таблица calculators
        await db.execute('''
          CREATE TABLE calculators (
            calc_subarea_key TEXT PRIMARY KEY,
            area_id INTEGER NOT NULL,
            calc_id INTEGER NOT NULL,
            calc_name TEXT NOT NULL,
            FOREIGN KEY (area_id) REFERENCES areas(id),
            UNIQUE(area_id, calc_id)
          )
        ''');

        // Вставка начальных данных в таблицу areas
        await db.insert('areas', {'name': 'Гражданское строительство'});
        await db.insert('areas', {'name': 'Промышленное строительство'});
        await db.insert('areas', {'name': 'Инфраструктурное строительство'});
        await db.insert('areas', {'name': 'Энергетическо строительство'});
        await db.insert('areas', {'name': 'Гидротехническое строительство'});
        await db.insert('areas', {'name': 'Ландшафтное строительство'});
        await db.insert('areas', {'name': 'Специализированное строительство'});
        await db.insert('areas', {'name': 'Реконструкция и реставрация'});

        developer.log(
          'Inserted data into areas table',
          name: 'DatabaseHelper',
        ); // <<<< Добавлено логирование

        // Вставка начальных данных в таблицу calculators
        await db.insert('calculators', {
          'calc_subarea_key': 'civil_rebar_mass',
          'area_id': 1, // Гражданское
          'calc_id': 1,
          'calc_name': 'Расчет массы арматуры',
        });
        await db.insert('calculators', {
          'calc_subarea_key': 'civil_steel_sheet',
          'area_id': 1, // Гражданское
          'calc_id': 2,
          'calc_name': 'Расчет веса стального листа',
        });
        await db.insert('calculators', {
          'calc_subarea_key': 'industrial_rebar_mass',
          'area_id': 2, // Промышленное
          'calc_id': 1,
          'calc_name': 'Расчет массы арматуры',
        });
        developer.log(
          'Inserted data into calculators table',
          name: 'DatabaseHelper',
        ); // <<<< Добавлено логирование
      },
    );
  }

  // Изменено: Добавлен метод для сброса базы данных
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/calculator_app.db';
    await database; // Убедись, что база инициализирована
    await _database?.close(); // Закрываем текущую базу
    _database = null; // Сбрасываем ссылку
    await deleteDatabase(path); // Удаляем файл базы
    developer.log('Database reset at $path', name: 'DatabaseHelper');
    await database; // Повторно открываем, что вызовет onCreate
  }

  // Сохранение данных пользователя
  Future<void> saveUser({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthDate,
    required String position,
    required String organization,
    required int areaId, // Изменено: Теперь сохраняем area_id
  }) async {
    final db = await database;
    await db.insert('Users', {
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'birth_date': birthDate,
      'position': position,
      'organization': organization,
      'area_id': areaId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Изменено: Добавлен метод для полного обновления пользователя
  Future<void> updateUserFull({
    required int id,
    required String firstName,
    required String lastName,
    required String gender,
    required String birthDate,
    required String position,
    required String organization,
    required int areaId,
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
        'area_id': areaId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Получение данных пользователя
  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final result = await db.query('Users', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  // Обновление данных пользователя
  Future<void> updateUser({
    required int id,
    String? firstName,
    String? lastName,
    String? gender,
    String? birthDate,
    String? position,
    String? organization,
    int? areaId,
  }) async {
    final db = await database;
    final updatedData = <String, dynamic>{};

    if (firstName != null) updatedData['first_name'] = firstName;
    if (lastName != null) updatedData['last_name'] = lastName;
    if (gender != null) updatedData['gender'] = gender;
    if (birthDate != null) updatedData['birth_date'] = birthDate;
    if (position != null) updatedData['position'] = position;
    if (organization != null) updatedData['organization'] = organization;
    if (areaId != null) updatedData['area_id'] = areaId;

    if (updatedData.isNotEmpty) {
      await db.update('Users', updatedData, where: 'id = ?', whereArgs: [id]);
    }
  }

  // Получение списка областей
  Future<List<Map<String, dynamic>>> getAreas() async {
    final db = await database;
    return await db.query('areas');
  }

  // Получение названия области по ID
  Future<String?> getAreaName(int areaId) async {
    final db = await database;
    final result = await db.query(
      'areas',
      where: 'id = ?',
      whereArgs: [areaId],
    );
    return result.isNotEmpty ? result.first['name'] as String? : null;
  }

  // Получение калькуляторов по area_id
  Future<List<Map<String, dynamic>>> getCalculatorsByArea(int areaId) async {
    final db = await database;
    return await db.query(
      'calculators',
      where: 'area_id = ?',
      whereArgs: [areaId],
    );
  }
}
