import 'package:flutter/material.dart';

class SymptomLog {
  final String symptom;
  final String trigger;
  final String notes;
  final DateTime date;

  SymptomLog({
    required this.symptom,
    required this.trigger,
    required this.notes,
    required this.date,
  });
}

class SymptomLogProvider extends ChangeNotifier {
  final List<SymptomLog> _logs = [];

  List<SymptomLog> get logs => List.unmodifiable(_logs);

  void addLog(SymptomLog log) {
    _logs.insert(0, log);
    notifyListeners();
  }
}
