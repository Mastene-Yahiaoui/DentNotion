import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/patient.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({Key? key}) : super(key: key);

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  String? _error;
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _api.getPatients();
      setState(() {
        _patients = (data['results'] as List)
            .map((e) => Patient.fromJson(e))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _fetchPatients,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _patients.length,
                    itemBuilder: (context, index) {
                      final patient = _patients[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(patient.firstName[0]),
                          ),
                          title: Text(patient.fullName),
                          subtitle: Text('${patient.email}\n${patient.phone}'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}