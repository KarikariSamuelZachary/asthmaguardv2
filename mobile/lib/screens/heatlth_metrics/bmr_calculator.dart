import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class BMRCalculator extends StatefulWidget {
  const BMRCalculator({super.key});

  @override
  State<BMRCalculator> createState() => _BMRCalculatorState();
}

class _BMRCalculatorState extends State<BMRCalculator> {
  final _formKey = GlobalKey<FormState>();
  String _gender = 'male';
  String _activityLevel = 'sedentary';
  String _goal = 'maintain';
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  double _bmr = 0;
  double _tdee = 0;
  Map<String, double> _macros = {
    'protein': 0,
    'carbs': 0,
    'fat': 0,
    'calories': 0
  };
  Map<String, double> _idealWeight = {'min': 0, 'max': 0};
  bool _isMetric = false;
  List<Map<String, dynamic>> _history = [];

  void _calculateBMR() {
    if (_formKey.currentState!.validate()) {
      final age = int.parse(_ageController.text);
      final weight = _isMetric
          ? double.parse(_weightController.text)
          : double.parse(_weightController.text) * 0.453592; // lbs to kg
      final height = _isMetric
          ? double.parse(_heightController.text)
          : double.parse(_heightController.text) * 2.54; // in to cm

      setState(() {
        if (_gender == 'male') {
          _bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
        } else {
          _bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
        }
        _tdee = _calculateTDEE(_bmr, _activityLevel);
        _macros = _calculateMacros(_tdee, _goal);
        _idealWeight = _calculateIdealWeight(height, _gender);
      });
    }
  }

  void _saveResult() {
    final now = DateTime.now();
    setState(() {
      _history.insert(0, {
        'date': now,
        'bmr': _bmr,
        'tdee': _tdee,
        'goal': _goal,
        'macros': Map<String, double>.from(_macros),
      });
    });
  }

  void _shareResult() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('BMR & Nutrition Plan',
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue)),
            pw.SizedBox(height: 16),
            pw.Text('BMR: ${_bmr.round()} kcal',
                style: pw.TextStyle(fontSize: 18)),
            pw.Text('TDEE: ${_tdee.round()} kcal',
                style: pw.TextStyle(fontSize: 18)),
            pw.Text('Goal: $_goal', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 12),
            pw.Text('Macros:',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text('  Protein: ${_macros['protein']}g'),
            pw.Text('  Carbs:   ${_macros['carbs']}g'),
            pw.Text('  Fat:     ${_macros['fat']}g'),
            pw.SizedBox(height: 12),
            pw.Text(
                'Ideal Weight Range: ${_idealWeight['min']} - ${_idealWeight['max']} kg',
                style: pw.TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/bmr_result.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)],
        subject: 'My BMR & Nutrition Plan');
  }

  double _calculateTDEE(double bmr, String activityLevel) {
    const activityMultipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'veryActive': 1.9,
    };
    return bmr * activityMultipliers[activityLevel]!;
  }

  Map<String, double> _calculateMacros(double tdee, String goal) {
    const macroRatios = {
      'lose': {'protein': 0.4, 'carbs': 0.3, 'fat': 0.3},
      'maintain': {'protein': 0.3, 'carbs': 0.4, 'fat': 0.3},
      'gain': {'protein': 0.3, 'carbs': 0.45, 'fat': 0.25},
    };
    const calorieAdjustment = {
      'lose': -500,
      'maintain': 0,
      'gain': 500,
    };
    final adjustedTDEE = tdee + calorieAdjustment[goal]!;
    final ratios = macroRatios[goal]!;
    return {
      'calories': adjustedTDEE,
      'protein': (adjustedTDEE * ratios['protein']! / 4).roundToDouble(),
      'carbs': (adjustedTDEE * ratios['carbs']! / 4).roundToDouble(),
      'fat': (adjustedTDEE * ratios['fat']! / 9).roundToDouble(),
    };
  }

  Map<String, double> _calculateIdealWeight(double height, String gender) {
    // height is already in cm
    if (gender == 'male') {
      return {
        'min': ((height - 100) * 0.9).roundToDouble(),
        'max': ((height - 100) * 1.1).roundToDouble(),
      };
    }
    return {
      'min': ((height - 100) * 0.85).roundToDouble(),
      'max': ((height - 100) * 1.05).roundToDouble(),
    };
  }

  Widget _buildMacroBarChart() {
    final maxVal = [
      _macros['protein'] ?? 0,
      _macros['carbs'] ?? 0,
      _macros['fat'] ?? 0
    ].reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Macros Breakdown',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBar('Protein', _macros['protein']!, maxVal, Colors.blue),
              const SizedBox(width: 8),
              _buildBar('Carbs', _macros['carbs']!, maxVal, Colors.green),
              const SizedBox(width: 8),
              _buildBar('Fat', _macros['fat']!, maxVal, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double value, double max, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 80,
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: value / max,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                width: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('${value.round()}g',
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text('History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        ..._history.map((entry) {
          final date = DateFormat('MMM d, yyyy – HH:mm').format(entry['date']);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                  'BMR: ${entry['bmr'].round()} | TDEE: ${entry['tdee'].round()}'),
              subtitle: Text('Goal: ${entry['goal']} | $date'),
              trailing: IconButton(
                icon: const Icon(Icons.share, color: Color(0xFF4285F4)),
                onPressed: () {
                  final macros = entry['macros'];
                  final summary =
                      'BMR: ${entry['bmr'].round()} kcal\nTDEE: ${entry['tdee'].round()} kcal\nGoal: ${entry['goal']}\nMacros: Protein ${macros['protein']}g, Carbs ${macros['carbs']}g, Fat ${macros['fat']}g';
                  Share.share(summary, subject: 'My BMR & Nutrition Plan');
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BMR Calculator',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF4285F4)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Metric',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isMetric ? Colors.blue : Colors.grey)),
                  Switch(
                    value: _isMetric,
                    onChanged: (val) {
                      setState(() => _isMetric = val);
                      _weightController.clear();
                      _heightController.clear();
                    },
                  ),
                  Text('Imperial',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !_isMetric ? Colors.blue : Colors.grey)),
                ],
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gender',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                              value: 'male',
                              label: Text('Male'),
                              icon: Icon(Icons.male)),
                          ButtonSegment(
                              value: 'female',
                              label: Text('Female'),
                              icon: Icon(Icons.female)),
                        ],
                        selected: {_gender},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() => _gender = newSelection.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Age', suffixText: 'years'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your age'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Weight',
                            suffixText: _isMetric ? 'kg' : 'lbs'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your weight'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Height',
                            suffixText: _isMetric ? 'cm' : 'inches'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your height'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Activity Level',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _activityLevel,
                        items: const [
                          DropdownMenuItem(
                              value: 'sedentary', child: Text('Sedentary')),
                          DropdownMenuItem(
                              value: 'light', child: Text('Light')),
                          DropdownMenuItem(
                              value: 'moderate', child: Text('Moderate')),
                          DropdownMenuItem(
                              value: 'active', child: Text('Active')),
                          DropdownMenuItem(
                              value: 'veryActive', child: Text('Very Active')),
                        ],
                        onChanged: (value) =>
                            setState(() => _activityLevel = value!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Goal',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _goal,
                        items: const [
                          DropdownMenuItem(
                              value: 'lose', child: Text('Weight Loss')),
                          DropdownMenuItem(
                              value: 'maintain',
                              child: Text('Maintain Weight')),
                          DropdownMenuItem(
                              value: 'gain', child: Text('Weight Gain')),
                        ],
                        onChanged: (value) => setState(() => _goal = value!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _calculateBMR,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('Calculate BMR'),
              ),
              const SizedBox(height: 24),
              if (_bmr > 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Align all result texts left
                      children: [
                        const Text('Your Basal Metabolic Rate (BMR)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('${_bmr.round()} calories/day',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4285F4))),
                        const SizedBox(height: 16),
                        Text(
                            'Total Daily Energy Expenditure (TDEE): ${_tdee.round()} calories/day',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 16),
                        Text(
                            'Ideal Weight Range: ${_idealWeight['min']} - ${_idealWeight['max']} kg',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 16),
                        Text('Recommended Macros:',
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          'Protein:  9${_macros['protein']}g\nCarbs:   ${_macros['carbs']}g\nFat:     ${_macros['fat']}g',
                          style: const TextStyle(fontSize: 16),
                        ),
                        _buildMacroBarChart(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _saveResult();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Result saved to history!')),
                                );
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Save Result'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  _shareResult();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Failed to share: $e')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share Result'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4285F4),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              _buildHistory(),
            ],
          ),
        ),
      ),
    );
  }
}
