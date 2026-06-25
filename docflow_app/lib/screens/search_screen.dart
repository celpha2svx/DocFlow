import 'package:flutter/material.dart';

import 'package:docflow_app/models/category.dart';
import 'package:docflow_app/screens/calculator_screen.dart';
import 'package:docflow_app/screens/feature_request_screen.dart';
import 'package:docflow_app/utils/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<CalculatorMeta>> _groupedResults() {
    final query = _query.trim().toLowerCase();
    final map = <String, List<CalculatorMeta>>{};

    for (final category in categories) {
      final matches = category.calculators.where((calculator) {
        if (query.isEmpty) return true;
        final nameMatch = calculator.name.toLowerCase().contains(query);
        final categoryMatch = calculator.category.toLowerCase().contains(query);
        final tagMatch = calculator.searchTags.any((tag) => tag.toLowerCase().contains(query));
        return nameMatch || categoryMatch || tagMatch;
      }).toList();

      if (matches.isNotEmpty) {
        map[category.name] = matches;
      }
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedResults();
    final hasResults = grouped.isNotEmpty;

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
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: hasResults
                    ? ListView.separated(
                        itemCount: grouped.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 18),
                        itemBuilder: (context, groupIndex) {
                          final categoryName = grouped.keys.elementAt(groupIndex);
                          final calculators = grouped[categoryName]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppConstants.textColor,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              ...calculators.map(
                                (calculator) => Card(
                                  child: ListTile(
                                    title: Text(calculator.name),
                                    subtitle: Text(calculator.searchTags.join(', ')),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CalculatorScreen(calculatorId: calculator.id),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No results for "$_query"',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppConstants.textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Try another keyword or submit a feature request.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppConstants.subtextColor,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const FeatureRequestScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.lightbulb_outline),
                              label: const Text('Request a Feature'),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
