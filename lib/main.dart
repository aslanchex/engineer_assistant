import 'package:flutter/material.dart';
import 'package:engineer_assistant/screen/home_screen.dart';
import 'package:engineer_assistant/data/database_helper.dart';

// Точка входа приложения
void main() {
  runApp(const CalculatorApp());
}

// Главный класс приложения
class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});
  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final user = await _dbHelper.getUser();
      if (user != null && user['theme'] != null) {
        setState(() {
          _themeMode =
              user['theme'] == 'dark'
                  ? ThemeMode.dark
                  : user['theme'] == 'light'
                  ? ThemeMode.light
                  : ThemeMode.system;
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки темы: $e');
    }
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorAppTheme(
      themeMode: _themeMode,
      setThemeMode: _setThemeMode,
      child: MaterialApp(
        title: 'Агрегатор калькуляторов ПТО',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.green,
          brightness: Brightness.dark,
        ),
        themeMode: _themeMode,
        home: const HomeScreen(),
      ),
    );
  }
}

// InheritedWidget для управления темой
class CalculatorAppTheme extends InheritedWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) setThemeMode;

  const CalculatorAppTheme({
    super.key,
    required this.themeMode,
    required this.setThemeMode,
    required super.child,
  });

  static CalculatorAppTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CalculatorAppTheme>();
  }

  @override
  bool updateShouldNotify(CalculatorAppTheme oldWidget) =>
      themeMode != oldWidget.themeMode;
}
