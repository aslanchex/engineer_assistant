import 'package:flutter/material.dart';
import '../database_helper.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _areas = [];
  Map<int, List<Map<String, dynamic>>> _calculatorsByArea = {};
  Map<int, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    _loadAreasAndCalculators();
  }

  Future<void> _loadAreasAndCalculators() async {
    final areas = await _dbHelper.getAreas();
    final Map<int, List<Map<String, dynamic>>> calculatorsByArea = {};
    for (var area in areas) {
      final areaId = area['id'] as int;
      final calculators = await _dbHelper.getCalculatorsByArea(areaId);
      calculatorsByArea[areaId] = calculators;
      _isExpanded[areaId] = false; // По умолчанию все области свернуты
    }
    if (mounted) {
      setState(() {
        _areas = areas;
        _calculatorsByArea = calculatorsByArea;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Найти калькулятор...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _areas.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _areas.length,
                    itemBuilder: (context, index) {
                      final area = _areas[index];
                      final areaId = area['id'] as int;
                      final calculators = _calculatorsByArea[areaId] ?? [];
                      return ExpansionTile(
                        leading: const Icon(Icons.build),
                        title: Text(area['name']),
                        initiallyExpanded: _isExpanded[areaId] ?? false,
                        onExpansionChanged: (expanded) {
                          setState(() => _isExpanded[areaId] = expanded);
                        },
                        children: calculators.map((calculator) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: ListTile(
                              title: Text(calculator['calc_name']),
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