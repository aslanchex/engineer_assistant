// Временный класс для управления темой (должен быть в корневом виджете)
import 'package:flutter/material.dart';

class SearchAppTheme extends InheritedWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) setThemeMode;

  const SearchAppTheme({
    super.key,
    required this.themeMode,
    required this.setThemeMode,
    required super.child,
  });

  static SearchAppTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SearchAppTheme>();
  }

  @override
  bool updateShouldNotify(SearchAppTheme oldWidget) => themeMode != oldWidget.themeMode;
}