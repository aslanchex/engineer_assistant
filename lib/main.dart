// Импорт необходимых библиотек Flutter
import 'package:flutter/material.dart';
// Импорт файла с классом Category
import 'category.dart';

// Точка входа приложения
void main() {
  runApp(const CalculatorApp());
}

// Главный класс приложения
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp - это основа приложения с поддержкой Material Design
    return MaterialApp(
      title: 'Агрегатор калькуляторов ПТО',
      theme: ThemeData(
        // Светлая тема: белый фон, черный текст
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        // Темная тема: темно-серый фон, зеленые акценты
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system, // Тема зависит от настроек устройства
      home: const HomeScreen(), // Устанавливаем главный экран
    );
  }
}

// Главный экран с навигацией
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Индекс текущей выбранной вкладки

  // Список экранов для навигации
  static const List<Widget> _screens = <Widget>[
    SearchScreen(), // Экран "Поиск"
    CalculatorScreen(), // Экран "Расчет"
    HistoryScreen(), // Экран "История"
    ProfileScreen(), // Экран "Профиль"
  ];

  // Обработчик нажатия на вкладку
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Обновляем индекс при выборе вкладки
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Агрегатор калькуляторов ПТО')),
      body: _screens[_selectedIndex], // Отображаем текущий экран
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Расчет'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'История'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
        currentIndex: _selectedIndex, // Текущая активная вкладка
        selectedItemColor: Colors.green, // Цвет активной вкладки
        unselectedItemColor: Colors.grey, // Цвет неактивных вкладок
        onTap: _onItemTapped, // Вызываем обработчик при нажатии
      ),
    );
  }
}

// Экран "Поиск" с категориями и выпадающими списками
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Список категорий (в будущем можно добавить новые)
  final List<Category> categories = [
    MetalsCategory(), // Подраздел "Металлы"
    // Здесь можно добавить другие категории, например: ConcreteCategory()
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Поле поиска
          TextField(
            decoration: InputDecoration(
              hintText: 'Найти калькулятор...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 16), // Отступ
          // Кнопка фильтра
          // ElevatedButton(
          //   onPressed: () {
          //     // Здесь будет логика фильтрации по области строительства
          //   },
          //   child: const Text('Фильтр по области'),
          // ),
          // const SizedBox(height: 16),
          // Список категорий с выпадающими подразделами
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ExpansionTile(
                  leading: Icon(category.icon), // Иконка категории
                  title: Text(category.name), // Название категории
                  initiallyExpanded: category.isExpanded, // Начальное состояние
                  onExpansionChanged: (expanded) {
                    setState(() {
                      category.isExpanded = expanded; // Обновляем состояние
                    });
                  },
                  children:
                      category.calculators.map((calculator) {
                        return Padding(
                          // Изменено: Добавлен отступ слева для выравнивания правее заголовка
                          padding: const EdgeInsets.only(left: 64.0),
                          child: ListTile(
                            title: Text(calculator),
                            onTap: () {},
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Экран "Расчет" (заглушка)
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Выберите калькулятор для выполнения расчета'),
    );
  }
}

// Экран "История" (заглушка)
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('История расчетов пока пуста'));
  }
}

// Экран "Профиль" (заглушка)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Профиль пользователя'));
  }
}
