import 'package:flutter/material.dart';
import '../database_helper.dart';

// Экран "Профиль"
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _dbHelper = DatabaseHelper.instance;
  String? _currentArea;

  @override
  void initState() {
    super.initState();
    _loadArea();
  }

  Future<void> _loadArea() async {
    final area = await _dbHelper.getArea();
    if (mounted) setState(() => _currentArea = area);
  }

  Future<void> _updateArea(String area) async {
    await _dbHelper.updateArea(area);
    if (mounted) setState(() => _currentArea = area);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('Профиль пользователя'),
          const SizedBox(height: 16),
          Text('Текущая область: ${_currentArea ?? "Не выбрана"}'),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: _currentArea,
            hint: const Text('Сменить область'),
            items: const [
              DropdownMenuItem(value: 'Гражданское', child: Text('Гражданское')),
              DropdownMenuItem(value: 'Промышленное', child: Text('Промышленное')),
            ],
            onChanged: (value) {
              if (value != null) _updateArea(value);
            },
          ),
        ],
      ),
    );
  }
}