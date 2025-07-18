import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/symptom_log_provider.dart';

class LogSymptomsDialog extends StatefulWidget {
  const LogSymptomsDialog({super.key});

  @override
  State<LogSymptomsDialog> createState() => _LogSymptomsDialogState();
}

class _LogSymptomsDialogState extends State<LogSymptomsDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSymptom;
  String? _selectedTrigger;
  String _notes = '';

  final List<String> _symptoms = [
    'Difficulty Breathing',
    'Chest Tightness',
    'Coughing',
    'Wheezing',
    'Shortness of Breath',
  ];

  final List<String> _triggers = [
    'Dust',
    'Harmful Gasses',
    'Exercise',
    'Pollen',
    'Cold Air',
    'Other',
  ];

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Asthma Symptom'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSymptom,
                decoration: const InputDecoration(
                  labelText: 'Symptom*',
                  prefixIcon: Icon(Icons.sick),
                ),
                items: _symptoms
                    .map((symptom) => DropdownMenuItem(
                          value: symptom,
                          child: Text(symptom),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSymptom = value),
                validator: (value) => value == null ? 'Select a symptom' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTrigger,
                decoration: const InputDecoration(
                  labelText: 'Potential Trigger*',
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
                items: _triggers
                    .map((trigger) => DropdownMenuItem(
                          value: trigger,
                          child: Text(trigger),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedTrigger = value),
                validator: (value) => value == null ? 'Select a trigger' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
                onChanged: (value) => _notes = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Log Symptom'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final log = SymptomLog(
      symptom: _selectedSymptom!,
      trigger: _selectedTrigger!,
      notes: _notes,
      date: DateTime.now(),
    );
    Provider.of<SymptomLogProvider>(context, listen: false).addLog(log);
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate save
    setState(
        () => _saving = false); // Set saving to false before closing dialog
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Symptom logged successfully!'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }
}
