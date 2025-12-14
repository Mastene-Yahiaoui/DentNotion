class Patient {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  String get fullName => '$firstName $lastName';

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: (json['id'] ?? json['patient_id'] ?? 0) is int ? (json['id'] ?? json['patient_id']) as int : int.tryParse((json['id'] ?? json['patient_id']).toString()) ?? 0,
      firstName: (json['first_name'] ?? json['firstName'] ?? '') as String,
      lastName: (json['last_name'] ?? json['lastName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
      };
}
