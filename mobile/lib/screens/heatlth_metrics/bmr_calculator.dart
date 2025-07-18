import 'package:flutter/material.dart';

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

  void _calculateBMR() {
    if (_formKey.currentState!.validate()) {
      final age = int.parse(_ageController.text);
      final weight =
          double.parse(_weightController.text) * 0.453592; // lbs to kg
      final height = double.parse(_heightController.text) * 2.54; // in to cm

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMR Calculator'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                        decoration: const InputDecoration(
                            labelText: 'Weight', suffixText: 'lbs'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your weight'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Height', suffixText: 'inches'),
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
                style:
                    FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('Calculate BMR'),
              ),
              const SizedBox(height: 24),
              if (_bmr > 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
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
                        Text(
                            'Recommended Macros: Protein: ${_macros['protein']}g, Carbs: ${_macros['carbs']}g, Fat: ${_macros['fat']}g',
                            style: const TextStyle(fontSize: 18)),
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
