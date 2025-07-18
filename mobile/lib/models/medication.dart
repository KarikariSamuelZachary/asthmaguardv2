class Medication {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> times;
  final String? startDate;
  final String? endDate;
  final String? notes;
  final bool active;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    this.startDate,
    this.endDate,
    this.notes,
    required this.active,
  });
}
