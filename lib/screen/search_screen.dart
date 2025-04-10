import 'package:flutter/material.dart';
import '../area.dart';
import 'dart:developer' as developer;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Area _areaManager = Area(); // Singleton экземпляр
  Map<int, List<Map<String, dynamic>>> _calculatorsByArea = {};
  final Map<int, bool> _isExpanded = {};
  bool _isLoading = true; // Добавляем флаг загрузки

  @override
  void initState() {
    super.initState();
    _loadAreasAndCalculators();
  }

  Future<void> _loadAreasAndCalculators() async {
    try {
      developer.log(
        'Начало загрузки областей и калькуляторов',
        name: 'SearchScreen',
      );
      await _areaManager.loadAreas(); // Загружаем области через singleton
      final Map<int, List<Map<String, dynamic>>> calculatorsByArea = {};
      for (var area in _areaManager.areas) {
        final areaId = area['id'] as int;
        _isExpanded[areaId] = false; // По умолчанию все области свернуты
      }
      if (mounted) {
        setState(() {
          _calculatorsByArea = calculatorsByArea;
          _isLoading = false;
        });
        developer.log(
          'Загружено областей: ${_areaManager.areas.length}, калькуляторов: ${_calculatorsByArea.length}',
          name: 'SearchScreen',
        );
      }
    } catch (e) {
      developer.log('Ошибка загрузки: $e', name: 'SearchScreen');
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              const SizedBox(height: 16),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _areaManager.areas.isEmpty
                        ? const Center(child: Text('Области не найдены'))
                        : ListView.builder(
                          itemCount: _areaManager.areas.length,
                          itemBuilder: (context, index) {
                            final area = _areaManager.areas[index];
                            final areaId = area['id'] as int;
                            final calculators =
                                _calculatorsByArea[areaId] ?? [];
                            return ExpansionTile(
                              title: Text(area['name']),
                              initiallyExpanded: _isExpanded[areaId] ?? false,
                              onExpansionChanged: (expanded) {
                                setState(() => _isExpanded[areaId] = expanded);
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
