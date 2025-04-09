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
  bool _isEditing = false; // Изменено: Добавлен флаг режима редактирования
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _positionController;
  late TextEditingController _organizationController;
  String? _gender;
  DateTime? _birthDate;
  int? _selectedAreaId;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAreas();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _positionController = TextEditingController();
    _organizationController = TextEditingController();
  }

  Future<void> _loadUser() async {
    final user = await _dbHelper.getUser();
    if (user != null && user['area_id'] != null) {
      final areaName = await _dbHelper.getAreaName(user['area_id']);
      if (mounted) {
        setState(() {
          _user = user;
          _areaName = areaName;
          _firstNameController.text = user['first_name'];
          _lastNameController.text = user['last_name'];
          _gender = user['gender'];
          _birthDate =
              user['birth_date'].isNotEmpty
                  ? DateTime.parse(user['birth_date'])
                  : null;
          _positionController.text = user['position'];
          _organizationController.text = user['organization'];
          _selectedAreaId = user['area_id'];
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

  // Изменено: Метод для сохранения изменений
  Future<void> _saveChanges() async {
    if (_user != null && _selectedAreaId != null) {
      await _dbHelper.updateUserFull(
        id: _user!['id'],
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        gender: _gender ?? '',
        birthDate: _birthDate != null ? _birthDate!.toIso8601String() : '',
        position: _positionController.text,
        organization: _organizationController.text,
        areaId: _selectedAreaId!,
      );
      setState(() => _isEditing = false);
      await _loadUser(); // Перезагрузка данных
    }
  }

  // Изменено: Выбор даты рождения
  Future<void> _selectBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && mounted) {
      setState(() => _birthDate = pickedDate);
    }
  }

  Future<void> _updateField(String field, int value) async {
    if (_user != null) {
      await _dbHelper.updateUser(
        id: _user!['id'],
        areaId: field == 'area_id' ? value : null,
      );
      await _loadUser(); // Перезагрузка данных
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Изменено: Добавлен SafeArea для отступа от области уведомлений
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              _user == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Профиль пользователя',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 16),
                        if (!_isEditing) ...[
                          Text('Имя: ${_user!['first_name']}'),
                          const SizedBox(height: 16),
                          Text('Фамилия: ${_user!['last_name']}'),
                          const SizedBox(height: 16),
                          Text('Пол: ${_user!['gender']}'),
                          const SizedBox(height: 16),
                          Text(
                            'Дата рождения: ${_user!['birth_date'].isNotEmpty ? DateTime.parse(_user!['birth_date']).toLocal().toString().split(' ')[0] : ''}',
                          ),
                          const SizedBox(height: 16),
                          Text('Должность: ${_user!['position']}'),
                          const SizedBox(height: 16),
                          Text('Организация: ${_user!['organization']}'),
                          const SizedBox(height: 32),
                          const Text('Область работы:'),
                          DropdownButton<int>(
                            value: _user!['area_id'],
                            items:
                                _areas.map((area) {
                                  return DropdownMenuItem<int>(
                                    value: area['id'],
                                    child: Text(area['name']),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) _updateField('area_id', value);
                            },
                          ),
                        ] else ...[
                          TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(labelText: 'Имя'),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Фамилия',
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Изменено: Добавлена проверка на валидность _gender
                          DropdownButtonFormField<String>(
                            value:
                                _gender != null &&
                                        ['Мужской', 'Женский'].contains(_gender)
                                    ? _gender
                                    : null,
                            decoration: const InputDecoration(labelText: 'Пол'),
                            items: const [
                              DropdownMenuItem(
                                value: 'Мужской',
                                child: Text('Мужской'),
                              ),
                              DropdownMenuItem(
                                value: 'Женский',
                                child: Text('Женский'),
                              ),
                            ],
                            onChanged:
                                (value) => setState(() {
                                  _gender = value;
                                  print('Выбран пол: $_gender');
                                }),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Дата рождения',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: _selectBirthDate,
                              ),
                            ),
                            controller: TextEditingController(
                              text:
                                  _birthDate?.toLocal().toString().split(
                                    ' ',
                                  )[0] ??
                                  '',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _positionController,
                            decoration: const InputDecoration(
                              labelText: 'Должность',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _organizationController,
                            decoration: const InputDecoration(
                              labelText: 'Организация',
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text('Область работы:'),
                          // Изменено: Проверка на валидность _selectedAreaId
                          DropdownButton<int>(
                            value:
                                _selectedAreaId != null &&
                                        _areas.any(
                                          (area) =>
                                              area['id'] == _selectedAreaId,
                                        )
                                    ? _selectedAreaId
                                    : null,
                            hint: const Text('Выберите область'),
                            items:
                                _areas.map((area) {
                                  return DropdownMenuItem<int>(
                                    value: area['id'],
                                    child: Text(area['name']),
                                  );
                                }).toList(),
                            onChanged:
                                (value) => setState(() {
                                  _selectedAreaId = value;
                                  print('Выбрана область: $_selectedAreaId');
                                }),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _saveChanges,
                            child: const Text('Сохранить'),
                          ),
                        ],
                      ],
                    ),
                  ),
        ),
      ),
      // Изменено: Добавлена кнопка "Редактировать" как FloatingActionButton
      floatingActionButton:
          !_isEditing
              ? FloatingActionButton(
                onPressed: () => setState(() => _isEditing = true),
                child: const Icon(Icons.edit),
              )
              : null,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _organizationController.dispose();
    super.dispose();
  }
}
