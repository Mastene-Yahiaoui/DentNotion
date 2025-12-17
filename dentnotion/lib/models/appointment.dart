class Appointment {
  final String patientName;
  final String date;
  final String time;
  final String status;
  final String reason;

  Appointment({
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
    required this.reason,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      patientName: (json['patient_name'] ?? json['patient'] ?? json['patientName'] ?? '') as String,
      date: (json['date'] ?? '') as String,
      time: (json['time'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      reason: (json['reason'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'patient_name': patientName,
        'date': date,
        'time': time,
        'status': status,
        'reason': reason,
      };
}
