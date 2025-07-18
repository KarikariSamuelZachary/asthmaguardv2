import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationProvider extends ChangeNotifier {
  final List<Medication> _medications = [];
  String? error;

  List<Medication> get medications => List.unmodifiable(_medications);

  Future<bool> addMedication(Medication medication) async {
    try {
      _medications.add(medication);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }

  Future<bool> updateMedication(Medication medication) async {
    try {
      final index = _medications.indexWhere((m) => m.id == medication.id);
      if (index != -1) {
        _medications[index] = medication;
        notifyListeners();
        return true;
      }
      error = 'Medication not found';
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    }
  }
}
