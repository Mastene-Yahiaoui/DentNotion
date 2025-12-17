import 'dart:async';

class ApiService {
  // Mock/dummy data for development — replace with real HTTP calls later
  Future<Map<String, dynamic>> getPatients() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final results = [
      {'id': 1, 'first_name': 'Alice', 'last_name': 'Johnson', 'email': 'alice@example.com', 'phone': '+123456789'},
      {'id': 2, 'first_name': 'Bob', 'last_name': 'Smith', 'email': 'bob@example.com', 'phone': '+198765432'},
      {'id': 3, 'first_name': 'Carmen', 'last_name': 'Lee', 'email': 'carmen@example.com', 'phone': '+1122334455'},
    ];
    return {'count': results.length, 'results': results};
  }

  Future<Map<String, dynamic>> getAppointments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final results = [
      {'patient_name': 'Alice Johnson', 'date': '2025-12-14', 'time': '09:00', 'status': 'Confirmed', 'reason': 'Checkup'},
      {'patient_name': 'Bob Smith', 'date': '2025-12-14', 'time': '10:30', 'status': 'Pending', 'reason': 'Filling'},
      {'patient_name': 'Carmen Lee', 'date': '2025-12-13', 'time': '11:00', 'status': 'Completed', 'reason': 'Cleaning'},
      {'patient_name': 'David Park', 'date': '2025-12-12', 'time': '14:00', 'status': 'Cancelled', 'reason': 'Extraction'},
    ];
    return {'results': results};
  }

  Future<Map<String, dynamic>> getInvoices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final results = [
      {'id': 'INV-001', 'patient_name': 'Alice Johnson', 'treatment_description': 'Cleaning', 'amount': 120.0, 'status': 'Paid'},
      {'id': 'INV-002', 'patient_name': 'Bob Smith', 'treatment_description': 'Root Canal', 'amount': 250.0, 'status': 'Unpaid'},
      {'id': 'INV-003', 'patient_name': 'Carmen Lee', 'treatment_description': 'Filling', 'amount': 75.0, 'status': 'Paid'},
    ];
    return {'results': results};
  }

  Future<Map<String, dynamic>> getInventory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final results = [
      {'item': 'Gloves - Small', 'quantity': 120, 'status': 'in stock'},
      {'item': 'Anesthetic', 'quantity': 25, 'status': 'low stock'},
      {'item': 'Filling Material', 'quantity': 12, 'status': 'low stock'},
      {'item': 'Disposable Bibs', 'quantity': 300, 'status': 'in stock'},
    ];
    return {'results': results};
  }

  Future<Map<String, dynamic>> getTreatments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final results = [
      {'patient_name': 'Alice Johnson', 'treatment_description': 'Cleaning', 'date': '2025-12-01', 'cost': 120.0},
      {'patient_name': 'Bob Smith', 'treatment_description': 'Filling', 'date': '2025-11-28', 'cost': 75.0},
      {'patient_name': 'Carmen Lee', 'treatment_description': 'Root Canal', 'date': '2025-11-20', 'cost': 250.0},
    ];
    return {'results': results};
  }

  Future<void> createAppointment(Map<String, dynamic> payload) async {
    // Simulate create delay; replace with POST to backend when ready
    await Future.delayed(const Duration(milliseconds: 300));
    return;
  }
}
