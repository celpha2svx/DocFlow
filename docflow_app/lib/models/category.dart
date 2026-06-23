class Category {
  final String name;
  final String icon;
  final List<CalculatorMeta> calculators;

  Category({
    required this.name,
    required this.icon,
    required this.calculators,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'calculators': calculators.map((c) => c.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      icon: json['icon'] as String,
      calculators: (json['calculators'] as List<dynamic>)
          .map((c) => CalculatorMeta.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Create a copy with optional fields replaced
  Category copyWith({
    String? name,
    String? icon,
    List<CalculatorMeta>? calculators,
  }) {
    return Category(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      calculators: calculators ?? this.calculators,
    );
  }
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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'searchTags': searchTags,
    };
  }

  /// Create from JSON
  factory CalculatorMeta.fromJson(Map<String, dynamic> json) {
    return CalculatorMeta(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      searchTags: List<String>.from(json['searchTags'] as List),
    );
  }

  /// Create a copy with optional fields replaced
  CalculatorMeta copyWith({
    String? id,
    String? name,
    String? category,
    List<String>? searchTags,
  }) {
    return CalculatorMeta(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      searchTags: searchTags ?? this.searchTags,
    );
  }
}
