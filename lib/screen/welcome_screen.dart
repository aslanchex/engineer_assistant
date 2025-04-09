import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'home_screen.dart';

// Экран приветствия для выбора области при первом входе
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? _selectedArea;
  final _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  // Проверка, первый ли это запуск
  Future<void> _checkFirstLaunch() async {
    final area = await _dbHelper.getArea();
    if (area != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // Сохранение выбранной области и переход
  Future<void> _saveAndProceed() async {
    if (_selectedArea != null) {
      await _dbHelper.saveArea(_selectedArea!);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добро пожаловать')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Выберите область строительства:'),
            DropdownButton<String>(
              value: _selectedArea,
              hint: const Text('Выберите область'),
              items: const [
                DropdownMenuItem(value: 'Гражданское', child: Text('Гражданское')),
                DropdownMenuItem(value: 'Промышленное', child: Text('Промышленное')),
              ],
              onChanged: (value) => setState(() => _selectedArea = value),
            ),
            ElevatedButton(
              onPressed: _selectedArea != null ? _saveAndProceed : null,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}