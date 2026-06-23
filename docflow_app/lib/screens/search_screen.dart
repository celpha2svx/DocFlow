import 'package:flutter/material.dart';
import 'package:docflow_app/utils/constants.dart';
import 'package:docflow_app/models/category.dart';
import 'package:docflow_app/screens/calculator_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<CalculatorMeta> get _matchingCalculators {
    if (_query.isEmpty) return categories.expand((c) => c.calculators).toList();
    return categories
        .expand((c) => c.calculators)
        .where((calculator) {
          final lower = calculator.name.toLowerCase();
          final query = _query.toLowerCase();
          return lower.contains(query) || calculator.searchTags.any((tag) => tag.contains(query));
        })
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Calculators')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by name, category, or keyword',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _matchingCalculators.isEmpty
                    ? Center(
                        child: Text(
                          'No calculators found matching "$_query".',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppConstants.subtextColor,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _matchingCalculators.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final calculator = _matchingCalculators[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              title: Text(
                                calculator.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppConstants.textColor,
                                    ),
                              ),
                              subtitle: Text(
                                calculator.category,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppConstants.subtextColor,
                                    ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CalculatorScreen(calculator: calculator),
                                  ),
                                );
                              },
                            ),
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
