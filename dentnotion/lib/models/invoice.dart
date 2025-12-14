class Invoice {
  final dynamic id;
  final String patientName;
  final String treatmentDescription;
  final double amount;
  final String status;

  Invoice({
    required this.id,
    required this.patientName,
    required this.treatmentDescription,
    required this.amount,
    required this.status,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? json['invoice_id'] ?? json['number'],
      patientName: (json['patient_name'] ?? '') as String,
      treatmentDescription: (json['treatment_description'] ?? json['description'] ?? '') as String,
      amount: double.tryParse((json['amount'] ?? 0).toString()) ?? 0.0,
      status: (json['status'] ?? '') as String,
    );
  }
}
