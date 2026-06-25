import 'package:flutter/material.dart';
import 'package:docflow_app/screens/result_screen.dart';
import 'package:docflow_app/services/calculator_loader.dart';
import 'package:docflow_app/widgets/calculator_input.dart';
import 'package:docflow_app/utils/constants.dart';

class CalculatorScreen extends StatefulWidget {
  final String calculatorId;

  const CalculatorScreen({super.key, required this.calculatorId});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  final _toggleValues = <String, dynamic>{};
  final _dropdownValues = <String, dynamic>{};
  final _unitSelections = <String, String>{};
  CalculatorDefinition? _calc;
  String? _error;

  @override
  void initState() {
    super.initState();
    final calc = CalculatorLoader.instance.get(widget.calculatorId);
    if (calc == null) {
      _error = 'Calculator not found';
      return;
    }
    _calc = calc;
    for (final input in calc.inputs) {
      if (input.type == 'number') {
        _controllers[input.id] = TextEditingController();
        _unitSelections[input.id] = input.unit ?? '';
      } else if (input.type == 'toggle') {
        _toggleValues[input.id] = input.defaultValue ?? input.options!.first.value;
      } else if (input.type == 'dropdown') {
        _dropdownValues[input.id] = input.defaultValue ?? input.options!.first.value;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleUnit(InputDefinition input) {
    if (input.altUnits == null || input.altUnits!.isEmpty) return;
    final current = _unitSelections[input.id]!;
    final base = input.unit!;
    final altLabel = input.altUnits!.first.label;
    final controller = _controllers[input.id]!;
    final raw = double.tryParse(controller.text.trim());

    if (current == base) {
      _unitSelections[input.id] = altLabel;
      if (raw != null) {
        final alt = input.altUnits!.firstWhere((u) => u.label == altLabel);
        controller.text = (raw / alt.toBase).toStringAsFixed(4);
      }
    } else {
      _unitSelections[input.id] = base;
      if (raw != null) {
        final alt = input.altUnits!.firstWhere((u) => u.label == altLabel);
        controller.text = (raw * alt.toBase).toStringAsFixed(4);
      }
    }
    setState(() {});
  }

  double _getInputValue(InputDefinition input) {
    final raw = double.parse(_controllers[input.id]!.text.trim());
    final selected = _unitSelections[input.id];
    if (input.altUnits != null && selected != input.unit) {
      final alt = input.altUnits!.firstWhere((u) => u.label == selected);
      return raw * alt.toBase;
    }
    return raw;
  }

  Map<String, dynamic> _collectInputs() {
    final vars = <String, dynamic>{};
    for (final input in _calc!.inputs) {
      if (input.type == 'number') {
        final raw = _controllers[input.id]!.text.trim();
        if (raw.isNotEmpty) {
          final selected = _unitSelections[input.id];
          var val = double.parse(raw);
          if (input.altUnits != null && selected != input.unit) {
            final alt = input.altUnits!.firstWhere((u) => u.label == selected);
            val *= alt.toBase;
          }
          vars[input.id] = val;
        } else {
          vars[input.id] = 0;
        }
      } else if (input.type == 'toggle') {
        vars[input.id] = _toggleValues[input.id];
      } else if (input.type == 'dropdown') {
        vars[input.id] = _dropdownValues[input.id];
      }
    }
    return vars;
  }

  Map<String, dynamic> _buildInputValues() {
    final map = <String, dynamic>{};
    for (final input in _calc!.inputs) {
      if (input.type == 'number') {
        final raw = _controllers[input.id]?.text ?? '';
        map[input.id] = raw;
        map['${input.id}_unit'] = _unitSelections[input.id] ?? input.unit ?? '';
      } else if (input.type == 'toggle') {
        map[input.id] = _toggleValues[input.id];
      } else if (input.type == 'dropdown') {
        map[input.id] = _dropdownValues[input.id];
      }
    }
    return map;
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final inputVars = _collectInputs();
    try {
      final resultValues = CalculatorEngine.evaluate(_calc!, inputVars);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            calculator: _calc!,
            inputValues: _buildInputValues(),
            resultValues: resultValues,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calculation error: ${e.toString().replaceAll('FormatException: ', '')}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  Widget _buildNumberInput(InputDefinition input) {
    final controller = _controllers[input.id]!;
    final unit = _unitSelections[input.id] ?? input.unit ?? '';
    Widget? suffixWidget;
    if (input.altUnits != null && input.altUnits!.isNotEmpty) {
      suffixWidget = GestureDetector(
        onTap: () => _toggleUnit(input),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppConstants.secondaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            unit,
            style: const TextStyle(
              color: AppConstants.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
    }
    return NumberField(
      label: input.label,
      unit: unit,
      suffixWidget: suffixWidget,
      controller: controller,
      hintText: input.hint,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return input.required ? 'Enter ${input.label.toLowerCase()}' : null;
        }
        if (double.tryParse(value.trim()) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildToggleInput(InputDefinition input) {
    final options = input.options!;
    final selected = _toggleValues[input.id] == options[0].value;
    return ToggleField(
      label: input.label,
      optionA: options[0].label,
      optionB: options[1].label,
      selectedA: selected,
      onChanged: (isA) {
        setState(() => _toggleValues[input.id] = isA ? options[0].value : options[1].value);
      },
    );
  }

  Widget _buildDropdownInput(InputDefinition input) {
    final options = input.options!;
    return DropdownField<dynamic>(
      label: input.label,
      value: _dropdownValues[input.id],
      items: options
          .map((opt) => DropdownMenuItem(
                value: opt.value,
                child: Text(opt.label),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _dropdownValues[input.id] = value);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calculator')),
        body: Center(child: Text(_error!)),
      );
    }
    final calc = _calc!;

    return Scaffold(
      appBar: AppBar(title: Text(calc.name)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                calc.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.subtextColor,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ...List.generate(calc.inputs.length, (i) {
                          final input = calc.inputs[i];
                          return Padding(
                            padding: EdgeInsets.only(top: i > 0 ? 16 : 0),
                            child: _buildDynamicInput(input),
                          );
                        }),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.secondaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _calculate,
                          child: const Text('Calculate'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicInput(InputDefinition input) {
    switch (input.type) {
      case 'number':
        return _buildNumberInput(input);
      case 'toggle':
        return _buildToggleInput(input);
      case 'dropdown':
        return _buildDropdownInput(input);
      default:
        return const SizedBox.shrink();
    }
  }
}
