import 'package:sqflite/sqflite.dart';
// import 'database_helper.dart';
import 'dart:developer' as developer;

class DatabaseSeeder {
  // final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> seed(Database db) async {
    try {
      developer.log(
        'Начало заполнения базы начальными данными',
        name: 'DatabaseSeeder',
      );

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
        final areaId = await db.insert('areas', area);
        developer.log(
          'Добавлена область: ${area['name']} с id: $areaId',
          name: 'DatabaseSeeder',
        );

        // Подразделы и калькуляторы для "Промышленное строительство"
        if (area['name'] == 'Промышленное строительство') {
          final subdivisions = [
            {
              'name': 'Металлы',
              'calculators': [
                'Калькулятор металлопроката',
                'Калькулятор цветных металлов',
                'Калькулятор арматурной сетки',
              ],
            },
            {
              'name': 'Покраска',
              'calculators': [
                'Покраска металлопроката (расчет по массе)',
                'Покраска металлопроката (расчет по длине)',
              ],
            },
            {
              'name': 'Гидроизоляция',
              'calculators': [
                'Гидроизоляции днища колодцев',
                'Гидроизоляция кольца колодца',
                'Гидроизоляция перекрытия колодца',
              ],
            },
            {
              'name': 'Монтаж',
              'calculators': [
                'Объема монтажа ж.б. элементов днища колодцев',
                'Объема монтажа ж.б. элементов кольца колодцев',
                'Объема монтажа ж.б. элементов перекрытия колодцев',
              ],
            },
            {
              'name': 'Земляные работы',
              'calculators': [
                'Прямоугольный котлован',
                'Круглый котлован',
                'Котлован под колодец',
              ],
            },
          ];

          for (var subdivision in subdivisions) {
            final subdData = {'name': subdivision['name'], 'area_id': areaId};
            final subdId = await db.insert('subdivisions', subdData);
            developer.log(
              'Добавлен подраздел: ${subdivision['name']} с id: $subdId',
              name: 'DatabaseSeeder',
            );

            for (var calcName in subdivision['calculators'] as List<String>) {
              final calcData = {'calc_name': calcName, 'subd_id': subdId};
              final calcId = await db.insert('calculators', calcData);
              developer.log(
                'Добавлен калькулятор: $calcName с id: $calcId',
                name: 'DatabaseSeeder',
              );
            }
          }
        }
      }

      developer.log(
        'База успешно заполнена начальными данными',
        name: 'DatabaseSeeder',
      );
    } catch (e) {
      developer.log('Ошибка заполнения базы: $e', name: 'DatabaseSeeder');
    }
  }
}
