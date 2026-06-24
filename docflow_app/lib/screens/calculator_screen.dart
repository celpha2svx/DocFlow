import 'package:flutter/material.dart';
import 'package:docflow_app/calculators/body_metrics.dart';
import 'package:docflow_app/calculators/cardiac.dart';
import 'package:docflow_app/calculators/fluids_drips.dart';
import 'package:docflow_app/calculators/paediatrics.dart';
import 'package:docflow_app/calculators/renal.dart';
import 'package:docflow_app/models/category.dart';
import 'package:docflow_app/screens/result_screen.dart';
import 'package:docflow_app/widgets/calculator_input.dart';
import 'package:docflow_app/utils/constants.dart';

class CalculatorScreen extends StatefulWidget {
  final CalculatorMeta calculator;

  const CalculatorScreen({super.key, required this.calculator});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _qtController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _strokeVolumeController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _serumCreatinineController = TextEditingController();
  final TextEditingController _sodiumController = TextEditingController();
  final TextEditingController _chlorideController = TextEditingController();
  final TextEditingController _bicarbonateController = TextEditingController();
  final TextEditingController _urineNaController = TextEditingController();
  final TextEditingController _urineCreatinineController = TextEditingController();
  final TextEditingController _doseMgPerKgController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _tbsaController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dropFactorController = TextEditingController();
  bool _isMale = true;
  int _selectedFrequency = 1;
  String _heightUnit = 'cm';

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _qtController.dispose();
    _heartRateController.dispose();
    _strokeVolumeController.dispose();
    _ageController.dispose();
    _serumCreatinineController.dispose();
    _sodiumController.dispose();
    _chlorideController.dispose();
    _bicarbonateController.dispose();
    _urineNaController.dispose();
    _urineCreatinineController.dispose();
    _doseMgPerKgController.dispose();
    _frequencyController.dispose();
    _tbsaController.dispose();
    _volumeController.dispose();
    _timeController.dispose();
    _dropFactorController.dispose();
    super.dispose();
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.trim());
  }

  int? _parseInt(String value) {
    return int.tryParse(value.trim());
  }

  String? _validateNumeric(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $label';
    }
    if (_parseDouble(value) == null) {
      return 'Enter a valid $label';
    }
    return null;
  }

  Widget _buildNumberField({
    required String label,
    required String unit,
    required TextEditingController controller,
    String? hintText,
    Widget? suffixWidget,
  }) {
    return NumberField(
      label: label,
      unit: unit,
      suffixWidget: suffixWidget,
      controller: controller,
      hintText: hintText,
      validator: (value) => _validateNumeric(value, label.toLowerCase()),
    );
  }

  Widget _buildSexToggle() {
    return ToggleField(
      label: 'Sex',
      optionA: 'Male',
      optionB: 'Female',
      selectedA: _isMale,
      onChanged: (value) {
        setState(() {
          _isMale = value;
        });
      },
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownField<int>(
      label: 'Dose frequency',
      value: _selectedFrequency,
      hintText: 'Per day',
      items: [1, 2, 3, 4, 6, 8, 12]
          .map((value) => DropdownMenuItem(value: value, child: Text('$value times/day')))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedFrequency = value ?? 1;
        });
      },
    );
  }

  Widget _buildHeightField() {
    return _buildNumberField(
      label: 'Height',
      unit: _heightUnit,
      controller: _heightController,
      suffixWidget: GestureDetector(
        onTap: () {
          setState(() {
            _heightUnit = _heightUnit == 'cm' ? 'm' : 'cm';
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppConstants.secondaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _heightUnit,
            style: const TextStyle(
              color: AppConstants.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  double _getHeightInCm() {
    final h = _parseDouble(_heightController.text)!;
    return _heightUnit == 'm' ? h * 100 : h;
  }

  Map<String, dynamic> _buildInputValues() {
    return {
      'weight': _weightController.text,
      'height': _heightController.text,
      'systolic': _systolicController.text,
      'diastolic': _diastolicController.text,
      'qt': _qtController.text,
      'heartRate': _heartRateController.text,
      'strokeVolume': _strokeVolumeController.text,
      'age': _ageController.text,
      'serumCreatinine': _serumCreatinineController.text,
      'sodium': _sodiumController.text,
      'chloride': _chlorideController.text,
      'bicarbonate': _bicarbonateController.text,
      'urineNa': _urineNaController.text,
      'urineCreatinine': _urineCreatinineController.text,
      'doseMgPerKg': _doseMgPerKgController.text,
      'frequency': _frequencyController.text,
      'tbsa': _tbsaController.text,
      'volume': _volumeController.text,
      'time': _timeController.text,
      'dropFactor': _dropFactorController.text,
      'isMale': _isMale.toString(),
      'heightUnit': _heightUnit,
    };
  }

  List<Widget> _buildCalculatorInputs() {
    switch (widget.calculator.id) {
      case 'bmi':
        return [
          _buildNumberField(label: 'Weight', unit: 'kg', controller: _weightController),
          const SizedBox(height: 16),
          _buildHeightField(),
        ];
      case 'bsa':
        return [
          _buildNumberField(label: 'Weight', unit: 'kg', controller: _weightController),
          const SizedBox(height: 16),
          _buildHeightField(),
        ];
      case 'ibw':
        return [
          _buildHeightField(),
          const SizedBox(height: 16),
          _buildSexToggle(),
        ];
      case 'iv_drip_rate':
        return [
          _buildNumberField(label: 'Volume', unit: 'mL', controller: _volumeController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Time', unit: 'h', controller: _timeController, hintText: 'e.g. 1.5'),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Drop factor', unit: 'gtt/mL', controller: _dropFactorController),
        ];
      case 'maintenance_fluid':
        return [
          _buildNumberField(label: 'Weight', unit: 'kg', controller: _weightController),
        ];
      case 'parkland':
        return [
          _buildNumberField(label: 'Weight', unit: 'kg', controller: _weightController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'TBSA', unit: '%', controller: _tbsaController),
        ];
      case 'egfr':
        return [
          _buildNumberField(label: 'Age', unit: 'yrs', controller: _ageController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Weight', unit: 'kg', controller: _weightController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Serum creatinine', unit: 'mg/dL', controller: _serumCreatinineController),
          const SizedBox(height: 16),
          _buildSexToggle(),
        ];
      case 'anion_gap':
        return [
          _buildNumberField(label: 'Sodium', unit: 'mEq/L', controller: _sodiumController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Chloride', unit: 'mEq/L', controller: _chlorideController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Bicarbonate', unit: 'mEq/L', controller: _bicarbonateController),
        ];
      case 'fena':
        return [
          _buildNumberField(label: 'Urine Na', unit: 'mEq/L', controller: _urineNaController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Serum creatinine', unit: 'mg/dL', controller: _serumCreatinineController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Serum Na', unit: 'mEq/L', controller: _sodiumController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Urine creatinine', unit: 'mg/dL', controller: _urineCreatinineController),
        ];
      case 'map':
        return [
          _buildNumberField(label: 'Systolic', unit: 'mmHg', controller: _systolicController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Diastolic', unit: 'mmHg', controller: _diastolicController),
        ];
      case 'qtc':
        return [
          _buildNumberField(label: 'QT interval', unit: 'ms', controller: _qtController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Heart rate', unit: 'bpm', controller: _heartRateController),
        ];
      case 'cardiac_output':
        return [
          _buildNumberField(label: 'Heart rate', unit: 'bpm', controller: _heartRateController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Stroke volume', unit: 'mL', controller: _strokeVolumeController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'BSA (optional)', unit: 'm²', controller: _heightController, hintText: 'If known'),
        ];
      case 'paed_weight':
        return [
          _buildNumberField(label: 'Age', unit: 'yrs', controller: _ageController),
        ];
      case 'schwartz':
        return [
          _buildHeightField(),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Serum creatinine', unit: 'mg/dL', controller: _serumCreatinineController),
        ];
      case 'paed_dose':
        return [
          _buildNumberField(label: 'Dose', unit: 'mg/kg', controller: _doseMgPerKgController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Weight', unit: 'kg', controller: _weightController),
          const SizedBox(height: 16),
          _buildFrequencyDropdown(),
        ];
      default:
        return [
          Text(
            'This calculator is not implemented yet.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppConstants.subtextColor,
                ),
          ),
        ];
    }
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    String resultValue = '';
    String resultUnit = '';
    String resultLabel = '';
    String interpretation = '';
    String transparency = '';

    switch (widget.calculator.id) {
      case 'bmi':
        final weight = _parseDouble(_weightController.text)!;
        final height = _getHeightInCm();
        final result = BodyMetrics.calculateBMI(weightKg: weight, heightCm: height);
        resultValue = result.value.toStringAsFixed(1);
        resultUnit = 'kg/m\u{00B2}';
        resultLabel = result.category;
        interpretation = 'BMI calculated from weight and height.';
        transparency = result.transparency;
        break;
      case 'bsa':
        final weight = _parseDouble(_weightController.text)!;
        final height = _getHeightInCm();
        final result = BodyMetrics.calculateBSA(weightKg: weight, heightCm: height);
        resultValue = '${result.mosteller} / ${result.dubois}';
        resultUnit = 'm\u{00B2}';
        resultLabel = 'Mosteller / DuBois';
        interpretation = 'Body surface area estimate.';
        transparency = result.transparency;
        break;
      case 'ibw':
        final height = _getHeightInCm();
        final result = BodyMetrics.calculateIBW(heightCm: height, isMale: _isMale);
        resultValue = result.value.toStringAsFixed(1);
        resultUnit = 'kg';
        resultLabel = 'Ideal body weight';
        interpretation = 'Using ${_isMale ? 'male' : 'female'} Devine formula.';
        transparency = result.transparency;
        break;
      case 'iv_drip_rate':
        final volume = _parseDouble(_volumeController.text)!;
        final time = _parseDouble(_timeController.text)!;
        final factor = _parseDouble(_dropFactorController.text)!.round();
        final result = FluidsAndDrips.calculateIVDrip(
          volumeMl: volume,
          timeHours: time,
          dropFactor: factor,
        );
        resultValue = result.rounded.toString();
        resultUnit = 'gtt/min';
        resultLabel = 'Drip rate';
        interpretation = 'IV infusion rate for the selected volume and drop factor.';
        transparency = result.transparency;
        break;
      case 'maintenance_fluid':
        final weight = _parseDouble(_weightController.text)!;
        final result = FluidsAndDrips.calculateMaintenanceFluid(weightKg: weight);
        resultValue = result.hourlyRate.toStringAsFixed(1);
        resultUnit = 'mL/hr';
        resultLabel = 'Hourly maintenance fluid';
        interpretation = 'Daily rate = ${result.dailyRate.toStringAsFixed(1)} mL/day.';
        transparency = result.transparency;
        break;
      case 'parkland':
        final weight = _parseDouble(_weightController.text)!;
        final tbsa = _parseDouble(_tbsaController.text)!;
        final result = FluidsAndDrips.calculateParkland(weightKg: weight, tbsaPercent: tbsa);
        resultValue = result.total24hr.toStringAsFixed(1);
        resultUnit = 'mL';
        resultLabel = '24hr total fluid';
        interpretation = 'First 8hr: ${result.first8hrRate.toStringAsFixed(1)} mL/hr, next 16hr: ${result.next16hrRate.toStringAsFixed(1)} mL/hr.';
        transparency = result.transparency;
        break;
      case 'egfr':
        final age = _parseInt(_ageController.text)!;
        final weight = _parseDouble(_weightController.text)!;
        final creatinine = _parseDouble(_serumCreatinineController.text)!;
        final result = Renal.calculateEGFR(
          age: age,
          weightKg: weight,
          serumCreatinine: creatinine,
          isFemale: !_isMale,
        );
        resultValue = result.egfr.toStringAsFixed(1);
        resultUnit = 'mL/min';
        resultLabel = result.stage;
        interpretation = 'Estimated glomerular filtration rate.';
        transparency = result.transparency;
        break;
      case 'anion_gap':
        final sodium = _parseDouble(_sodiumController.text)!;
        final chloride = _parseDouble(_chlorideController.text)!;
        final bicarbonate = _parseDouble(_bicarbonateController.text)!;
        final result = Renal.calculateAnionGap(
          sodium: sodium,
          chloride: chloride,
          bicarbonate: bicarbonate,
        );
        resultValue = result.value.toStringAsFixed(1);
        resultUnit = 'mEq/L';
        resultLabel = result.elevated ? 'Elevated' : 'Normal';
        interpretation = result.elevated ? 'Raised anion gap suggests metabolic acidosis.' : 'Anion gap is within the normal range.';
        transparency = result.transparency;
        break;
      case 'fena':
        final urineNa = _parseDouble(_urineNaController.text)!;
        final serumCreatinine = _parseDouble(_serumCreatinineController.text)!;
        final serumNa = _parseDouble(_sodiumController.text)!;
        final urineCreatinine = _parseDouble(_urineCreatinineController.text)!;
        final result = Renal.calculateFeNa(
          urineNa: urineNa,
          serumCreatinine: serumCreatinine,
          serumNa: serumNa,
          urineCreatinine: urineCreatinine,
        );
        resultValue = result.value.toStringAsFixed(2);
        resultUnit = '%';
        resultLabel = result.interpretation;
        interpretation = 'Fractional excretion of sodium.';
        transparency = result.transparency;
        break;
      case 'map':
        final systolic = _parseDouble(_systolicController.text)!;
        final diastolic = _parseDouble(_diastolicController.text)!;
        final result = Cardiac.calculateMAP(systolic: systolic, diastolic: diastolic);
        resultValue = result.value.toStringAsFixed(1);
        resultUnit = 'mmHg';
        resultLabel = result.interpretation;
        interpretation = 'Mean arterial pressure estimation.';
        transparency = result.transparency;
        break;
      case 'qtc':
        final qtMs = _parseDouble(_qtController.text)!;
        final heartRate = _parseDouble(_heartRateController.text)!;
        final result = Cardiac.calculateQTc(qtMs: qtMs, heartRate: heartRate);
        resultValue = '${result.bazett} / ${result.fridericia}';
        resultUnit = 'ms';
        resultLabel = result.interpretation;
        interpretation = 'QTc using Bazett and Fridericia corrections.';
        transparency = result.transparency;
        break;
      case 'cardiac_output':
        final heartRate = _parseDouble(_heartRateController.text)!;
        final strokeVolume = _parseDouble(_strokeVolumeController.text)!;
        final bsa = _parseDouble(_heightController.text);
        final result = Cardiac.calculateCardiacOutput(
          heartRate: heartRate,
          strokeVolume: strokeVolume,
          bsa: bsa,
        );
        resultValue = result.cardiacOutput.toStringAsFixed(2);
        resultUnit = 'L/min';
        resultLabel = result.interpretation;
        interpretation = bsa != null
            ? 'Cardiac index: ${result.cardiacIndex?.toStringAsFixed(2) ?? "n/a"} L/min/m\u{00B2}'
            : 'Cardiac output without BSA.';
        transparency = result.transparency;
        break;
      case 'paed_weight':
        final age = _parseInt(_ageController.text)!;
        final result = Paediatrics.estimateWeight(age: age);
        resultValue = result.recommended.toStringAsFixed(1);
        resultUnit = 'kg';
        resultLabel = 'Estimated paediatric weight';
        interpretation = 'Recommended weight using APLS and Nelson formulas.';
        transparency = result.transparency;
        break;
      case 'schwartz':
        final height = _getHeightInCm();
        final serumCreatinine = _parseDouble(_serumCreatinineController.text)!;
        final result = Paediatrics.calculateSchwartz(heightCm: height, serumCreatinine: serumCreatinine);
        resultValue = result.egfr.toStringAsFixed(1);
        resultUnit = 'mL/min/1.73m\u{00B2}';
        resultLabel = result.stage;
        interpretation = 'Schwartz paediatric eGFR estimate.';
        transparency = result.transparency;
        break;
      case 'paed_dose':
        final doseMg = _parseDouble(_doseMgPerKgController.text)!;
        final weight = _parseDouble(_weightController.text)!;
        final result = Paediatrics.calculateDose(
          doseMgPerKg: doseMg,
          weightKg: weight,
          frequencyPerDay: _selectedFrequency,
        );
        resultValue = result.singleDoseMg.toStringAsFixed(1);
        resultUnit = 'mg';
        resultLabel = 'Single dose';
        interpretation = 'Daily total = ${result.dailyTotalMg.toStringAsFixed(1)} mg.';
        transparency = result.transparency;
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This calculator is not implemented yet.')),
        );
        return;
    }

    if (!mounted) return;

    final inputValues = _buildInputValues();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          calculatorName: widget.calculator.name,
          calculatorId: widget.calculator.id,
          category: widget.calculator.category,
          inputValues: inputValues,
          resultValue: resultValue,
          resultUnit: resultUnit,
          resultLabel: resultLabel,
          interpretation: interpretation,
          transparency: transparency,
          calculationSummary: '${widget.calculator.name}: $resultValue $resultUnit ($resultLabel)',
        ),
      ),
    );
  }

  String _buildSubtitle() {
    switch (widget.calculator.id) {
      case 'bmi':
        return 'Calculate body mass index from weight and height.';
      case 'bsa':
        return 'Estimate body surface area using Mosteller and DuBois formulas.';
      case 'ibw':
        return 'Determine ideal body weight with Devine formula.';
      case 'iv_drip_rate':
        return 'Convert infusion volume to drops per minute.';
      case 'maintenance_fluid':
        return 'Calculate hourly maintenance fluid using 4-2-1 rule.';
      case 'parkland':
        return 'Calculate Parkland burn resuscitation fluids.';
      case 'egfr':
        return 'Estimate creatinine clearance using Cockcroft-Gault.';
      case 'anion_gap':
        return 'Calculate serum anion gap for metabolic evaluation.';
      case 'fena':
        return 'Calculate fractional excretion of sodium (FeNa).';
      case 'map':
        return 'Calculate mean arterial pressure.';
      case 'qtc':
        return 'Correct QT interval for heart rate.';
      case 'cardiac_output':
        return 'Calculate cardiac output from heart rate and stroke volume.';
      case 'paed_weight':
        return 'Estimate paediatric weight by age.';
      case 'schwartz':
        return 'Calculate paediatric eGFR with Schwartz formula.';
      case 'paed_dose':
        return 'Calculate paediatric drug dosing by weight.';
      default:
        return 'This calculator is not implemented yet.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.calculator.name)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _buildSubtitle(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.subtextColor,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    ..._buildCalculatorInputs(),
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

            ],
          ),
        ),
      ),
    );
  }
}
