import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:docflow_app/calculators/body_metrics.dart';
import 'package:docflow_app/calculators/cardiac.dart';
import 'package:docflow_app/calculators/fluids_drips.dart';
import 'package:docflow_app/calculators/paediatrics.dart';
import 'package:docflow_app/calculators/renal.dart';
import 'package:docflow_app/models/category.dart';
import 'package:docflow_app/screens/save_to_patient_screen.dart';
import 'package:docflow_app/widgets/calculator_input.dart';
import 'package:docflow_app/widgets/result_display.dart';
import 'package:docflow_app/widgets/formula_display.dart';
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
  String _resultValue = '';
  String _resultUnit = '';
  String _resultLabel = '';
  String _interpretation = '';
  String _transparency = '';
  bool _showResult = false;

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
  }) {
    return NumberField(
      label: label,
      unit: unit,
      controller: controller,
      hintText: hintText,
      validator: (value) => _validateNumeric(value, label.toLowerCase()),
      onChanged: (_) {
        if (_showResult) {
          setState(() {
            _showResult = false;
          });
        }
      },
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

  List<Widget> _buildCalculatorInputs() {
    switch (widget.calculator.id) {
      case 'bmi':
        return [
          _buildNumberField(label: 'Weight', unit: 'kg', controller: _weightController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Height', unit: 'cm', controller: _heightController),
        ];
      case 'bsa':
        return [
          _buildNumberField(label: 'Weight', unit: 'kg', controller: _weightController),
          const SizedBox(height: 16),
          _buildNumberField(label: 'Height', unit: 'cm', controller: _heightController),
        ];
      case 'ibw':
        return [
          _buildNumberField(label: 'Height', unit: 'cm', controller: _heightController),
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
          _buildNumberField(label: 'Height', unit: 'cm', controller: _heightController),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _showResult = true;
      _interpretation = '';
      _transparency = '';

      switch (widget.calculator.id) {
        case 'bmi':
          final weight = _parseDouble(_weightController.text)!;
          final height = _parseDouble(_heightController.text)!;
          final result = BodyMetrics.calculateBMI(weightKg: weight, heightCm: height);
          _resultValue = result.value.toStringAsFixed(1);
          _resultUnit = 'kg/m²';
          _resultLabel = result.category;
          _interpretation = 'BMI calculated from weight and height.';
          _transparency = result.transparency;
          break;
        case 'bsa':
          final weight = _parseDouble(_weightController.text)!;
          final height = _parseDouble(_heightController.text)!;
          final result = BodyMetrics.calculateBSA(weightKg: weight, heightCm: height);
          _resultValue = '${result.mosteller} / ${result.dubois}';
          _resultUnit = 'm²';
          _resultLabel = 'Mosteller / DuBois';
          _interpretation = 'Body surface area estimate.';
          _transparency = result.transparency;
          break;
        case 'ibw':
          final height = _parseDouble(_heightController.text)!;
          final result = BodyMetrics.calculateIBW(heightCm: height, isMale: _isMale);
          _resultValue = result.value.toStringAsFixed(1);
          _resultUnit = 'kg';
          _resultLabel = 'Ideal body weight';
          _interpretation = 'Using ${_isMale ? 'male' : 'female'} Devine formula.';
          _transparency = result.transparency;
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
          _resultValue = result.rounded.toString();
          _resultUnit = 'gtt/min';
          _resultLabel = 'Drip rate';
          _interpretation = 'IV infusion rate for the selected volume and drop factor.';
          _transparency = result.transparency;
          break;
        case 'maintenance_fluid':
          final weight = _parseDouble(_weightController.text)!;
          final result = FluidsAndDrips.calculateMaintenanceFluid(weightKg: weight);
          _resultValue = result.hourlyRate.toStringAsFixed(1);
          _resultUnit = 'mL/hr';
          _resultLabel = 'Hourly maintenance fluid';
          _interpretation = 'Daily rate = ${result.dailyRate.toStringAsFixed(1)} mL/day.';
          _transparency = result.transparency;
          break;
        case 'parkland':
          final weight = _parseDouble(_weightController.text)!;
          final tbsa = _parseDouble(_tbsaController.text)!;
          final result = FluidsAndDrips.calculateParkland(weightKg: weight, tbsaPercent: tbsa);
          _resultValue = result.total24hr.toStringAsFixed(1);
          _resultUnit = 'mL';
          _resultLabel = '24hr total fluid';
          _interpretation = 'First 8hr: ${result.first8hrRate.toStringAsFixed(1)} mL/hr, next 16hr: ${result.next16hrRate.toStringAsFixed(1)} mL/hr.';
          _transparency = result.transparency;
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
          _resultValue = result.egfr.toStringAsFixed(1);
          _resultUnit = 'mL/min';
          _resultLabel = result.stage;
          _interpretation = 'Estimated glomerular filtration rate.';
          _transparency = result.transparency;
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
          _resultValue = result.value.toStringAsFixed(1);
          _resultUnit = 'mEq/L';
          _resultLabel = result.elevated ? 'Elevated' : 'Normal';
          _interpretation = result.elevated ? 'Raised anion gap suggests metabolic acidosis.' : 'Anion gap is within the normal range.';
          _transparency = result.transparency;
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
          _resultValue = result.value.toStringAsFixed(2);
          _resultUnit = '%';
          _resultLabel = result.interpretation;
          _interpretation = 'Fractional excretion of sodium.';
          _transparency = result.transparency;
          break;
        case 'map':
          final systolic = _parseDouble(_systolicController.text)!;
          final diastolic = _parseDouble(_diastolicController.text)!;
          final result = Cardiac.calculateMAP(systolic: systolic, diastolic: diastolic);
          _resultValue = result.value.toStringAsFixed(1);
          _resultUnit = 'mmHg';
          _resultLabel = result.interpretation;
          _interpretation = 'Mean arterial pressure estimation.';
          _transparency = result.transparency;
          break;
        case 'qtc':
          final qtMs = _parseDouble(_qtController.text)!;
          final heartRate = _parseDouble(_heartRateController.text)!;
          final result = Cardiac.calculateQTc(qtMs: qtMs, heartRate: heartRate);
          _resultValue = '${result.bazett} / ${result.fridericia}';
          _resultUnit = 'ms';
          _resultLabel = result.interpretation;
          _interpretation = 'QTc using Bazett and Fridericia corrections.';
          _transparency = result.transparency;
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
          _resultValue = result.cardiacOutput.toStringAsFixed(2);
          _resultUnit = 'L/min';
          _resultLabel = result.interpretation;
          _interpretation = bsa != null
              ? 'Cardiac index: ${result.cardiacIndex?.toStringAsFixed(2) ?? 'n/a'} L/min/m²'
              : 'Cardiac output without BSA.';
          _transparency = result.transparency;
          break;
        case 'paed_weight':
          final age = _parseInt(_ageController.text)!;
          final result = Paediatrics.estimateWeight(age: age);
          _resultValue = result.recommended.toStringAsFixed(1);
          _resultUnit = 'kg';
          _resultLabel = 'Estimated paediatric weight';
          _interpretation = 'Recommended weight using APLS and Nelson formulas.';
          _transparency = result.transparency;
          break;
        case 'schwartz':
          final height = _parseDouble(_heightController.text)!;
          final serumCreatinine = _parseDouble(_serumCreatinineController.text)!;
          final result = Paediatrics.calculateSchwartz(heightCm: height, serumCreatinine: serumCreatinine);
          _resultValue = result.egfr.toStringAsFixed(1);
          _resultUnit = 'mL/min/1.73m²';
          _resultLabel = result.stage;
          _interpretation = 'Schwartz paediatric eGFR estimate.';
          _transparency = result.transparency;
          break;
        case 'paed_dose':
          final doseMg = _parseDouble(_doseMgPerKgController.text)!;
          final weight = _parseDouble(_weightController.text)!;
          final result = Paediatrics.calculateDose(
            doseMgPerKg: doseMg,
            weightKg: weight,
            frequencyPerDay: _selectedFrequency,
          );
          _resultValue = result.singleDoseMg.toStringAsFixed(1);
          _resultUnit = 'mg';
          _resultLabel = 'Single dose';
          _interpretation = 'Daily total = ${result.dailyTotalMg.toStringAsFixed(1)} mg.';
          _transparency = result.transparency;
          break;
        default:
          _showResult = false;
          break;
      }
    });
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
              if (_showResult) ...[
                const SizedBox(height: 24),
                ResultDisplay(
                  resultValue: _resultValue,
                  resultUnit: _resultUnit,
                  resultLabel: _resultLabel,
                  interpretation: _interpretation,
                ),
                const SizedBox(height: 16),
                FormulaDisplay(
                  formula: _transparency,
                  formulaName: 'Transparency',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SaveToPatientScreen(
                                calculationSummary: '${widget.calculator.name} • $_resultValue $_resultUnit ($_resultLabel)',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        label: const Text('Save to Patient'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text: '${widget.calculator.name}: $_resultValue $_resultUnit - $_resultLabel',
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share Result'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
