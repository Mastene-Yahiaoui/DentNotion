class Treatment {
  final String patientName;
  final String description;
  final String date;
  final double cost;

  Treatment({
    required this.patientName,
    required this.description,
    required this.date,
    required this.cost,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      patientName: (json['patient_name'] ?? json['patient'] ?? '') as String,
      description: (json['description'] ?? json['treatment_description'] ?? '') as String,
      date: (json['date'] ?? '') as String,
      cost: double.tryParse((json['cost'] ?? json['amount'] ?? 0).toString()) ?? 0.0,
    );
  }
}
