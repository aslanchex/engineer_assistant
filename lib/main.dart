import 'package:engineer_assistant/screen/home_screen.dart';
import 'package:flutter/material.dart';

// Точка входа приложения
void main() {
  runApp(const CalculatorApp());
}

// Главный класс приложения
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Изменено: Упрощена структура, все экраны вынесены в отдельные файлы
    return MaterialApp(
      title: 'Агрегатор калькуляторов ПТО',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}