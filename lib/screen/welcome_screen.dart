import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _dbHelper = DatabaseHelper.instance;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  final _positionController = TextEditingController();
  final _organizationController = TextEditingController();
  int? _selectedAreaId; // Изменено: Теперь храним ID области
  List<Map<String, dynamic>> _areas = [];

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    _loadAreas();
  }

  // Загрузка списка областей из базы
  Future<void> _loadAreas() async {
    final areas = await _dbHelper.getAreas();
    if (mounted) {
      // setState(() => _areas = areas);

      setState(() {
        _areas = areas;
      });
    }
  }

  // Проверка, есть ли уже пользователь в базе
  Future<void> _checkFirstLaunch() async {
    final user = await _dbHelper.getUser();
    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // Выбор даты рождения через календарь
  Future<void> _selectBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && mounted) {
      setState(() => _birthDate = pickedDate);
    }
  }

  // Сохранение данных и переход
  Future<void> _saveAndProceed() async {
    if (_selectedAreaId != null) {
      await _dbHelper.saveUser(
        firstName: _firstNameController.text.isEmpty ? '' : _firstNameController.text,
        lastName: _lastNameController.text.isEmpty ? '' : _lastNameController.text,
        gender: _gender ?? '',
        birthDate: _birthDate != null ? _birthDate!.toIso8601String() : '',
        position: _positionController.text.isEmpty ? '' : _positionController.text,
        organization: _organizationController.text.isEmpty ? '' : _organizationController.text,
        areaId: _selectedAreaId!,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите область работы')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добро пожаловать')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Имя'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Фамилия'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: 'Пол'),
                    items: const [
                      DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
                      DropdownMenuItem(value: 'Женский', child: Text('Женский')),
                    ],
                    onChanged: (value) => setState(() => _gender = value),
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
                      text: _birthDate?.toLocal().toString().split(' ')[0] ?? '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _positionController,
                    decoration: const InputDecoration(labelText: 'Должность'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _organizationController,
                    decoration: const InputDecoration(labelText: 'Организация'),
                  ),
                  const SizedBox(height: 16),
                  // Изменено: Области подтягиваются из базы
                  DropdownButton<int>(
                    value: _selectedAreaId,
                    hint: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Область работы'),
                        Text(' *', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    items: _areas.map((area) {
                      return DropdownMenuItem<int>(
                        value: area['id'],
                        child: Text(area['name']),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedAreaId = value),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveAndProceed,
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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