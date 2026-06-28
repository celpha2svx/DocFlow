import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'formula_evaluator.dart';

const String _cachedFileName = 'cached_calculators.json';
const String _remoteUrl =
    'https://raw.githubusercontent.com/celpha2svx/DocFlow/main/docflow_app/assets/calculators.json';

class InputAltUnit {
  final String label;
  final num toBase;
  InputAltUnit.fromJson(Map<String, dynamic> json)
      : label = json['label'],
        toBase = json['to_base'];
}

class InputOption {
  final String label;
  final dynamic value;
  InputOption.fromJson(Map<String, dynamic> json)
      : label = json['label'],
        value = json['value'];
}

class InputDefinition {
  final String id;
  final String label;
  final String type;
  final String? unit;
  final bool required;
  final String? hint;
  final List<InputAltUnit>? altUnits;
  final List<InputOption>? options;
  final dynamic defaultValue;

  InputDefinition.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        label = json['label'],
        type = json['type'],
        unit = json['unit'],
        required = json['required'] ?? false,
        hint = json['hint'],
        altUnits = json['alt_units'] != null
            ? (json['alt_units'] as List)
                .map((e) => InputAltUnit.fromJson(e))
                .toList()
            : null,
        options = json['options'] != null
            ? (json['options'] as List)
                .map((e) => InputOption.fromJson(e))
                .toList()
            : null,
        defaultValue = json['default'];
}

class ResultDefinition {
  final String key;
  final String label;
  final String formula;
  final String unit;
  final int decimals;
  final bool isPrimary;

  ResultDefinition.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        label = json['label'],
        formula = json['formula'],
        unit = json['unit'],
        decimals = json['decimals'] ?? 0,
        isPrimary = json['is_primary'] ?? false;
}

class InterpretationRule {
  final String condition;
  final String label;
  final String severity;
  final String? detail;

  InterpretationRule.fromJson(Map<String, dynamic> json)
      : condition = json['condition'],
        label = json['label'],
        severity = json['severity'] ?? 'normal',
        detail = json['detail'];
}

class CalculatorDefinition {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<InputDefinition> inputs;
  final List<ResultDefinition> results;
  final String transparencyTemplate;
  final List<InterpretationRule> interpretations;

  CalculatorDefinition.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        category = json['category'],
        description = json['description'] ?? '',
        inputs = (json['inputs'] as List)
            .map((e) => InputDefinition.fromJson(e))
            .toList(),
        results = (json['results'] as List)
            .map((e) => ResultDefinition.fromJson(e))
            .toList(),
        transparencyTemplate = json['transparency_template'] ?? '',
        interpretations = json['interpretations'] != null
            ? (json['interpretations'] as List)
                .map((e) => InterpretationRule.fromJson(e))
                .toList()
            : [];

  ResultDefinition get primaryResult =>
      results.firstWhere((r) => r.isPrimary, orElse: () => results.first);
}

class EvaluationResult {
  final Map<String, dynamic> values;
  final String primaryKey;

  EvaluationResult(this.values, this.primaryKey);

  dynamic get primaryValue => values[primaryKey];
}

class CalculatorEngine {
  static Map<String, dynamic> evaluate(
    CalculatorDefinition calc,
    Map<String, dynamic> inputValues,
  ) {
    final allVars = Map<String, dynamic>.from(inputValues);
    final results = <String, dynamic>{};

    for (final result in calc.results) {
      final evaluator = FormulaEvaluator(allVars, result.formula);
      final val = evaluator.evaluate();
      final rounded = _round(val, result.decimals);
      results[result.key] = rounded;
      allVars[result.key] = rounded;
    }

    return results;
  }

  static num _round(dynamic val, int decimals) {
    if (val is! num) return 0;
    if (decimals <= 0) return val.round();
    final factor = math.pow(10, decimals).toDouble();
    return (val * factor).round() / factor;
  }
}

class CalculatorLoader {
  static final CalculatorLoader instance = CalculatorLoader._();
  CalculatorLoader._();

  List<CalculatorDefinition>? _calculators;
  Map<String, CalculatorDefinition>? _byId;

  List<CalculatorDefinition> get calculators =>
      _calculators ?? [];
  Map<String, CalculatorDefinition> get byId =>
      _byId ?? {};

  bool get isLoaded => _calculators != null;

  List<String> get categories {
    if (_calculators == null) return [];
    return _calculators!
        .map((c) => c.category)
        .toSet()
        .toList()
      ..sort();
  }

  List<CalculatorDefinition> byCategory(String category) {
    if (_calculators == null) return [];
    return _calculators!.where((c) => c.category == category).toList();
  }

  CalculatorDefinition? get(String id) => _byId?[id];

  Future<void> load() async {
    String jsonStr;

    try {
      jsonStr = await _loadFromCache();
    } catch (_) {
      jsonStr = await _loadFromAssets();
    }

    _parse(jsonStr);

    _fetchAndCache();
  }

  void _parse(String jsonStr) {
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final rawList = data['calculators'] as List;
    final list = <CalculatorDefinition>[];
    for (final e in rawList) {
      try {
        list.add(CalculatorDefinition.fromJson(e));
      } catch (_) {
        // Skip malformed calculator entries so a single bad entry
        // does not crash the entire app.
      }
    }
    _calculators = list;
    _byId = {for (final c in list) c.id: c};
  }

  Future<String> _loadFromAssets() async {
    return await rootBundle.loadString('assets/calculators.json');
  }

  Future<String> _loadFromCache() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_cachedFileName');
    return await file.readAsString();
  }

  Future<void> _saveToCache(String content) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_cachedFileName');
      await file.writeAsString(content);
    } catch (_) {}
  }

  Future<void> _fetchAndCache() async {
    try {
      final response = await http
          .get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        await _saveToCache(response.body);
        _parse(response.body);
      }
    } catch (_) {}
  }

  static String fillTemplate(String template, Map<String, dynamic> vars) {
    return template.replaceAllMapped(RegExp(r'\{(\w+)\}'), (match) {
      final key = match.group(1)!;
      if (vars.containsKey(key)) {
        final val = vars[key];
        if (val is double) {
          if (val == val.roundToDouble()) return val.toStringAsFixed(0);
          return val.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
        }
        return val.toString();
      }
      return match.group(0)!;
    });
  }
}
