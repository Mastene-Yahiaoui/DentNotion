import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/treatment.dart';
import '../models/patient.dart';

class TreatmentsScreen extends StatefulWidget {
  const TreatmentsScreen({Key? key}) : super(key: key);

  @override
  State<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends State<TreatmentsScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  String? _error;
  List<Treatment> _treatments = [];
  List<Patient> _patients = [];

  @override
  void initState() {
    super.initState();
    _fetchTreatments();
  }

  Future<void> _fetchTreatments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.getTreatments(),
        _api.getPatients(),
      ]);

      setState(() {
        _treatments = (results[0]['results'] as List)
            .map((e) => Treatment.fromJson(e))
            .toList();
        _patients = (results[1]['results'] as List)
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

  void _showAddDialog() {
    print('Showing add treatment dialog');
    showDialog(
      context: context,
      builder: (context) => AddTreatmentDialog(
        patients: _patients,
        onSubmit: _createTreatment,
      ),
    );
  }

  Future<void> _createTreatment(Map<String, dynamic> data) async {
    try {
      await _api.createTreatment(data);
      _fetchTreatments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treatment created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatments', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _fetchTreatments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _treatments.length,
                    itemBuilder: (context, index) {
                      final treatment = _treatments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(treatment.patientName),
                          subtitle: Text('${treatment.description}\n${treatment.date}'),
                          isThreeLine: true,
                          trailing: Text(
                            '\$${treatment.cost.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTreatmentDialog extends StatefulWidget {
  final List<Patient> patients;
  final Function(Map<String, dynamic>) onSubmit;

  const AddTreatmentDialog({
    Key? key,
    required this.patients,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AddTreatmentDialog> createState() => _AddTreatmentDialogState();
}

class _AddTreatmentDialogState extends State<AddTreatmentDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _patientId;
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  final _costController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() ||
        _patientId == null ||
        _selectedDate == null) {
      return;
    }

    setState(() => _submitting = true);

    final data = {
      'patient_id': _patientId,
      'description': _descriptionController.text,
      'date': _selectedDate!.toIso8601String().split('T')[0],
      'cost': double.tryParse(_costController.text) ?? 0.0,
    };

    await widget.onSubmit(data);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Treatment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                value: _patientId,
                decoration: const InputDecoration(
                  labelText: 'Patient *',
                  border: OutlineInputBorder(),
                ),
                items: widget.patients
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.firstName} ${p.lastName}'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _patientId = value),
                validator: (value) =>
                    value == null ? 'Please select a patient' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? _selectedDate!.toIso8601String().split('T')[0]
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter cost';
                  if (double.tryParse(value!) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}