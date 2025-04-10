import 'package:sqflite/sqflite.dart';
// import 'database_helper.dart';
import 'dart:developer' as developer;

class DatabaseSeeder {
  // final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> seed(Database db) async {
    try {
      developer.log('Начало заполнения базы начальными данными', name: 'DatabaseSeeder');

      // Начальные данные для areas
      final areas = [
        {'name': 'Промышленное строительство'},
        {'name': 'Гражданское строительство'},
        {'name': 'Инфраструктурное строительство'},
        {'name': 'Энергетическое строительство'},
        {'name': 'Гидротехническое строительство'},
        {'name': 'Ландшафтное строительство'},
        {'name': 'Специализированное строительство'},
        {'name': 'Реконструкция и реставрация'},
      ];
      for (var area in areas) {
        await db.insert('areas', area, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Пока не заполняем subdivisions и calculators, оставляем для будущего
      final subdivisions = [];
      for (var subdivision in subdivisions) {
        await db.insert('subdivisions', subdivision, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      final calculators = [];
      for (var calculator in calculators) {
        await db.insert('calculators', calculator, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      developer.log('База успешно заполнена начальными данными', name: 'DatabaseSeeder');
    } catch (e) {
      developer.log('Ошибка заполнения базы: $e', name: 'DatabaseSeeder');
    }
  }
}