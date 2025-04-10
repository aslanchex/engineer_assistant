import 'data/database_helper.dart';
import 'dart:developer' as developer;

class Area {
  static final Area _instance = Area._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _areas = [];

  factory Area() {
    return _instance;
  }

  Area._internal();

  Future<void> loadAreas() async {
    if (_areas.isEmpty) {
      try {
        _areas = await _dbHelper.getAreas();
        developer.log('Области загружены из БД: $_areas', name: 'Area');
      } catch (e) {
        developer.log('Ошибка загрузки областей: $e', name: 'Area');
        _areas = [];
      }
    } else {
      developer.log('Области уже загружены: $_areas', name: 'Area');
    }
  }

  List<Map<String, dynamic>> get areas => _areas;
}