import 'package:flutter/material.dart';

// Базовый класс для категорий (подразделов)
class Category {
  // Название категории
  final String name;
  // Список калькуляторов в категории
  final List<String> calculators;
  // Флаг, раскрыт ли подраздел в UI
  bool isExpanded;
  // Иконка для категории (для визуального оформления)
  final IconData icon;

  // Конструктор
  Category({
    required this.name,
    required this.calculators,
    this.isExpanded = false, // По умолчанию подраздел свернут
    required this.icon,
  });
}

// Подраздел "Металлы", наследуется от Category
class MetalsCategory extends Category {
  MetalsCategory()
      : super(
          name: 'Металлы',
          calculators: [
            'Расчет массы арматуры',
            'Расчет веса стального листа',
          ],
          icon: Icons.shortcut_rounded, // Иконка для категории
        );
}