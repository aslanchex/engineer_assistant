import 'package:flutter/material.dart';
import '../database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _dbHelper = DatabaseHelper.instance;
  Map<String, dynamic>? _user;
  String? _areaName;
  List<Map<String, dynamic>> _areas = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAreas();
  }

  Future<void> _loadUser() async {
    final user = await _dbHelper.getUser();
    if (user != null && user['area_id'] != null) {
      final areaName = await _dbHelper.getAreaName(user['area_id']);
      if (mounted) {
        setState(() {
          _user = user;
          _areaName = areaName;
        });
      }
    }
  }

  Future<void> _loadAreas() async {
    final areas = await _dbHelper.getAreas();
    if (mounted) {
      setState(() => _areas = areas);
    }
  }

  Future<void> _updateField(String field, int value) async {
    if (_user != null) {
      await _dbHelper.updateUser(id: _user!['id'], areaId: field == 'area_id' ? value : null);
      await _loadUser(); // Перезагрузка данных
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const Text('Профиль пользователя', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  Text('Имя: ${_user!['first_name']}'),
                  Text('Фамилия: ${_user!['last_name']}'),
                  Text('Пол: ${_user!['gender']}'),
                  Text('Дата рождения: ${_user!['birth_date']}'),
                  Text('Должность: ${_user!['position']}'),
                  Text('Организация: ${_user!['organization']}'),
                  const SizedBox(height: 16),
                  const Text('Область работы:'),
                  // Изменено: Области подтягиваются из базы
                  DropdownButton<int>(
                    value: _user!['area_id'],
                    items: _areas.map((area) {
                      return DropdownMenuItem<int>(
                        value: area['id'],
                        child: Text(area['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) _updateField('area_id', value);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}