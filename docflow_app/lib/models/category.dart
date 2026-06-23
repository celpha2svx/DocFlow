class Category {
  final String name;
  final String icon;
  final List<CalculatorMeta> calculators;

  Category({
    required this.name,
    required this.icon,
    required this.calculators,
  });
}

class CalculatorMeta {
  final String id;
  final String name;
  final String category;
  final List<String> searchTags;

  CalculatorMeta({
    required this.id,
    required this.name,
    required this.category,
    required this.searchTags,
  });
}
