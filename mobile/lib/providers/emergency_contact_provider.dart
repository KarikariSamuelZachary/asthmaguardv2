import 'package:flutter/material.dart';

class EmergencyContactProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _contacts = [];
  bool isLoading = false;

  List<Map<String, dynamic>> get contacts => _contacts;

  Future<void> fetchContacts() async {
    isLoading = true;
    notifyListeners();
    // Simulate fetching contacts from a backend or local storage
    await Future.delayed(const Duration(milliseconds: 500));
    // Example data
    _contacts = [
      {
        'Id': '1',
        'name': 'John Doe',
        'relationship': 'Father',
        'phone': '+1234567890',
        'email': 'john@example.com',
        'role': 'family',
        'priority': 'high',
      },
      {
        'Id': '2',
        'name': 'Jane Smith',
        'relationship': 'Doctor',
        'phone': '+1987654321',
        'email': 'jane@hospital.com',
        'role': 'doctor',
        'priority': 'medium',
      },
    ];
    isLoading = false;
    notifyListeners();
  }

  Future<void> createContact(Map<String, dynamic> contact) async {
    // Simulate saving to backend or local storage
    await Future.delayed(const Duration(milliseconds: 300));
    _contacts.add(contact);
    notifyListeners();
  }

  Future<void> sendEmergencyAlert(
      {bool isTest = false, String? contactId}) async {
    // Simulate sending an alert (to all or a specific contact)
    await Future.delayed(const Duration(milliseconds: 500));
    // You can add logic here for real API calls
    // For now, just simulate success
    return;
  }
}
