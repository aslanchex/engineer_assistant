import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import 'dart:developer' as developer;

import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _dbHelper = DatabaseHelper.instance;
  Map<String, dynamic>? _user;
  bool _isEditing = false;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _positionController;
  late TextEditingController _organizationController;
  String? _gender;
  DateTime? _birthDate;
  bool _isLoading = true; // Добавлено: Флаг загрузки
  String? _theme; // Добавлено: Переменная для темы

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _positionController = TextEditingController();
    _organizationController = TextEditingController();
    _loadData(); // Изменено: Единый метод загрузки
  }

  Future<void> _loadData() async {
    try {
      developer.log('Начало загрузки данных', name: 'ProfileScreen');
      await _loadUser();
      developer.log('Данные загружены успешно', name: 'ProfileScreen');
    } catch (e) {
      developer.log('Ошибка загрузки данных: $e', name: 'ProfileScreen');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Завершаем загрузку
      }
    }
  }

  Future<void> _loadUser() async {
    final user = await _dbHelper.getUser();
    if (user != null) {
      if (mounted) {
        setState(() {
          _user = user;
          _firstNameController.text = user['first_name'] ?? '';
          _lastNameController.text = user['last_name'] ?? '';
          _gender = user['gender'].isNotEmpty ? user['gender'] : null;
          _birthDate =
              user['birth_date'].isNotEmpty
                  ? DateTime.parse(user['birth_date'])
                  : null;
          _positionController.text = user['position'] ?? '';
          _organizationController.text = user['organization'] ?? '';
          _theme = user['theme'] ?? 'system'; // Загружаем тему
          developer.log(
            'Загруженные данные пользователя: $_user',
            name: 'ProfileScreen',
          );
        });
      }
    } else {
      setState(() {
        _user = null;
        _theme = 'system'; // По умолчанию системная тема
        developer.log('Пользователь не найден', name: 'ProfileScreen');
      });
    }
  }

  Future<void> _saveChanges() async {
    final db = await _dbHelper.database;
    final userData = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'gender': _gender ?? '',
      'birth_date': _birthDate != null ? _birthDate!.toIso8601String() : '',
      'position': _positionController.text,
      'organization': _organizationController.text,
      'theme': _theme ?? 'system', // Сохраняем тему
    };
    try {
      if (_user == null) {
        await db.insert(
          'Users',
          userData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        developer.log(
          'Создан новый пользователь: $userData',
          name: 'ProfileScreen',
        );
      } else {
        await _dbHelper.updateUserFull(
          id: _user!['id'],
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          gender: _gender ?? '',
          birthDate: _birthDate != null ? _birthDate!.toIso8601String() : '',
          position: _positionController.text,
          organization: _organizationController.text,
          theme: _theme ?? 'system', // Передаём тему
        );
        developer.log(
          'Обновлён пользователь с id: ${_user!['id']}',
          name: 'ProfileScreen',
        );
      }
      setState(() => _isEditing = false);
      await _loadUser();
      _applyTheme(); // Применяем тему после сохранения
    } catch (e) {
      developer.log('Ошибка сохранения: $e', name: 'ProfileScreen');
      if (mounted) {
        // Изменено: Добавлена проверка mounted
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
      }
    }
  }

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

  void _applyTheme() {
    // Применение темы через уведомление корневого виджета
    final themeMode =
        _theme == 'dark'
            ? ThemeMode.dark
            : _theme == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    // Здесь мы уведомляем корневой виджет (например, через Provider или InheritedWidget)
    if (mounted) {
      CalculatorAppTheme.of(context)?.setThemeMode(themeMode);
    }
  }

  String _formatTheme(String? theme) {
    switch (theme) {
      case 'system':
        return 'Системная';
      case 'dark':
        return 'Тёмная';
      case 'light':
        return 'Светлая';
      default:
        return 'Системная';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Профиль пользователя',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                if (_user == null && !_isEditing) ...[
                  const Text('Данные пользователя не заполнены'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _isEditing = true),
                    child: const Text('Заполнить профиль'),
                  ),
                ] else if (!_isEditing) ...[
                  Text('Имя: ${_user!['first_name'] ?? ''}'),
                  const SizedBox(height: 16),
                  Text('Фамилия: ${_user!['last_name'] ?? ''}'),
                  const SizedBox(height: 16),
                  Text('Пол: ${_user!['gender'] ?? ''}'),
                  const SizedBox(height: 16),
                  Text(
                    'Дата рождения: ${_user!['birth_date'].isNotEmpty ? DateTime.parse(_user!['birth_date']).toLocal().toString().split(' ')[0] : ''}',
                  ),
                  const SizedBox(height: 16),
                  Text('Должность: ${_user!['position'] ?? ''}'),
                  const SizedBox(height: 16),
                  Text('Организация: ${_user!['organization'] ?? ''}'),
                  const SizedBox(height: 16),
                  Text('Тема оформления: ${_formatTheme(_theme)}'),
                ] else ...[
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Имя'),
                    keyboardType: TextInputType.text,
                    onChanged:
                        (value) => developer.log(
                          'Введено имя: $value',
                          name: 'ProfileScreen',
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Фамилия'),
                    keyboardType: TextInputType.text,
                    onChanged:
                        (value) => developer.log(
                          'Введена фамилия: $value',
                          name: 'ProfileScreen',
                        ),
                  ),
                  const SizedBox(height: 16),
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
                          developer.log(
                            'Выбран пол: $_gender',
                            name: 'ProfileScreen',
                          );
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
                          _birthDate?.toLocal().toString().split(' ')[0] ?? '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _positionController,
                    decoration: const InputDecoration(labelText: 'Должность'),
                    keyboardType: TextInputType.text,
                    onChanged:
                        (value) => developer.log(
                          'Введена должность: $value',
                          name: 'ProfileScreen',
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _organizationController,
                    decoration: const InputDecoration(labelText: 'Организация'),
                    keyboardType: TextInputType.text,
                    onChanged:
                        (value) => developer.log(
                          'Введена организация: $value',
                          name: 'ProfileScreen',
                        ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _theme,
                    decoration: const InputDecoration(
                      labelText: 'Тема оформления',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'system',
                        child: Text('Системная'),
                      ),
                      DropdownMenuItem(value: 'dark', child: Text('Тёмная')),
                      DropdownMenuItem(value: 'light', child: Text('Светлая')),
                    ],
                    onChanged:
                        _isEditing
                            ? (value) => setState(() {
                              _theme = value;
                              developer.log(
                                'Выбрана тема: $_theme',
                                name: 'ProfileScreen',
                              );
                            })
                            : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text('Сохранить'),
                  ),
                ],
                ElevatedButton(
                  onPressed: _dbHelper.resetDatabase,
                  child: const Text('Сброс БД'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton:
          !_isEditing && _user != null
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
