import 'package:flutter/material.dart';
import '../area.dart';
import 'dart:developer' as developer;
import '../data/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Area _areaManager = Area(); // Singleton экземпляр
  int? _selectedAreaId; // Выбранная область
  String? _selectedAreaName; // Добавлено: Название выбранной области
  List<Map<String, dynamic>> _subdivisions = [];
  Map<int, List<Map<String, dynamic>>> _calculatorsBySubdivision = {};
  final Map<int, bool> _isExpanded = {};
  bool _isLoading = true;

  final _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadCachedArea();
  }

  Future<void> _loadCachedArea() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedAreaId = prefs.getInt('selectedAreaId');
    if (cachedAreaId != null) {
      developer.log(
        'Загружаем сохранённую область: $cachedAreaId',
        name: 'SearchScreen',
      );
      await _selectArea(cachedAreaId);
    }
  }

  Future<void> _showAreasList() async {
    await _areaManager.loadAreas(); // Загружаем области (только первый раз)
    if (mounted) {
      showModalBottomSheet(
        context: context,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              16.0,
              16.0,
              16.0,
              16.0 +
                  MediaQuery.of(
                    context,
                  ).padding.bottom, // Отступ снизу с учётом панели управления
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Области строительства',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (_areaManager.areas.isEmpty)
                  const Text('Области не найдены')
                else
                  Flexible(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _areaManager.areas.length,
                        itemBuilder: (context, index) {
                          final area = _areaManager.areas[index];
                          return ListTile(
                            title: Text(
                              area['name'] ?? 'Без названия',
                              textAlign: TextAlign.left,
                            ),
                            onTap: () {
                              developer.log(
                                'Выбрана область: ${area['name']}',
                                name: 'SearchScreen',
                              );
                              _selectArea(area['id'] as int);
                              Navigator.pop(context);
                              // Здесь можно добавить логику выбора области
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _selectArea(int areaId) async {
    setState(() => _isLoading = true);
    try {
      final subdivisions = await _dbHelper.getSubdivisionsByArea(areaId);
      final Map<int, List<Map<String, dynamic>>> calculatorsBySubdivision = {};
      for (var subdivision in subdivisions) {
        final subId = subdivision['id'] as int;
        final calculators = await _dbHelper.getCalculatorsBySubdivision(subId);
        calculatorsBySubdivision[subId] = calculators;
        _isExpanded[subId] = false;
      }

      final areaName = await _dbHelper.getAreaName(areaId); // Получаем название области
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('selectedAreaId', areaId); // Сохраняем выбор в кэш
      if (mounted) {
        setState(() {
          _selectedAreaId = areaId;
          _selectedAreaName = areaName; // Сохраняем название
          _subdivisions = subdivisions;
          _calculatorsBySubdivision = calculatorsBySubdivision;
          _isLoading = false;
        });
        developer.log(
          'Загружено подразделов: ${subdivisions.length}',
          name: 'SearchScreen',
        );
      }
    } catch (e) {
      developer.log('Ошибка загрузки подразделов: $e', name: 'SearchScreen');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Найти калькулятор...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        developer.log(
                          'Поисковый запрос: $value',
                          name: 'SearchScreen',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.build),
                    onPressed: _showAreasList,
                    tooltip: 'Показать области',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Добавлено: Вывод наименования выбранной области
              Text(
                _selectedAreaName != null ? '$_selectedAreaName' : '',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _selectedAreaId == null
                        ? const Center(
                          child: Text('Выберите область строительства'),
                        )
                        : _subdivisions.isEmpty
                        ? const Center(child: Text('Подразделы не найдены'))
                        : ListView.builder(
                          itemCount: _subdivisions.length,
                          itemBuilder: (context, index) {
                            final subdivision = _subdivisions[index];
                            final subId = subdivision['id'] as int;
                            final calculators =
                                _calculatorsBySubdivision[subId] ?? [];
                            return ExpansionTile(
                              title: Text(subdivision['name']),
                              initiallyExpanded: _isExpanded[subId] ?? false,
                              onExpansionChanged: (expanded) {
                                setState(() => _isExpanded[subId] = expanded);
                              },
                              children:
                                  calculators.map((calculator) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16.0,
                                      ),
                                      child: ListTile(
                                        title: Text(calculator['calc_name']),
                                        onTap: () {
                                          developer.log(
                                            'Выбран калькулятор: ${calculator['calc_name']}',
                                            name: 'SearchScreen',
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
