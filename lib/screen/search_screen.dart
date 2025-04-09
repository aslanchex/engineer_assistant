import 'package:flutter/material.dart';
import '../category.dart';

// Экран "Поиск"
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _categories = [MetalsCategory()];

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
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ExpansionTile(
                  leading: Icon(category.icon),
                  title: Text(category.name),
                  initiallyExpanded: category.isExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() => category.isExpanded = expanded);
                  },
                  children: category.calculators.map((calculator) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0),
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