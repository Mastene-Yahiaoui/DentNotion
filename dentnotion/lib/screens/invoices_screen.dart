import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/invoice.dart';
import '../widgets/status_badge.dart';
import '../models/patient.dart';
import '../models/treatment.dart';
import '../theme.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({Key? key}) : super(key: key);

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  String? _error;
  List<Invoice> _invoices = [];
  String _filterStatus = 'all';
  List<Patient> _patients = [];
  List<Treatment> _treatments = [];

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.getInvoices(),
        _api.getPatients(),
        _api.getTreatments(),
      ]);

      setState(() {
        _invoices = (results[0]['results'] as List)
            .map((e) => Invoice.fromJson(e))
            .toList();
        _patients = (results[1]['results'] as List)
            .map((e) => Patient.fromJson(e))
            .toList();
        _treatments = (results[2]['results'] as List)
            .map((e) => Treatment.fromJson(e))
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

  List<Invoice> get _filteredInvoices {
    if (_filterStatus == 'all') return _invoices;
    return _invoices.where((inv) => inv.status == _filterStatus).toList();
  }

  void _showAddDialog() {
    print('Showing add invoice dialog');
    showDialog(
      context: context,
      builder: (context) => AddInvoiceDialog(
        patients: _patients,
        treatments: _treatments,
        onSubmit: _createInvoice,
      ),
    );
  }

  Future<void> _createInvoice(Map<String, dynamic> data) async {
    try {
      await _api.createInvoice(data);
      _fetchInvoices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice created successfully')),
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
        title: const Text('Invoices', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _buildFilterChip('all', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('Paid', 'Paid'),
                const SizedBox(width: 8),
                _buildFilterChip('Unpaid', 'Unpaid'),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _fetchInvoices,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = _filteredInvoices[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text('Invoice #${invoice.id}'),
                          subtitle: Text(
                            '${invoice.patientName}\n${invoice.treatmentDescription}',
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${invoice.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              StatusBadge(status: invoice.status),
                            ],
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

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }
}

class AddInvoiceDialog extends StatefulWidget {
  final List<Patient> patients;
  final List<Treatment> treatments;
  final Function(Map<String, dynamic>) onSubmit;

  const AddInvoiceDialog({
    Key? key,
    required this.patients,
    required this.treatments,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends State<AddInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _patientId;
  int? _treatmentId;
  final _amountController = TextEditingController();
  String _status = 'Unpaid';
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() ||
        _patientId == null ||
        _treatmentId == null) {
      return;
    }

    setState(() => _submitting = true);

    final data = {
      'patient_id': _patientId,
      'treatment_id': _treatmentId,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'status': _status,
    };

    await widget.onSubmit(data);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Invoice'),
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
              DropdownButtonFormField<int>(
                value: _treatmentId,
                decoration: const InputDecoration(
                  labelText: 'Treatment *',
                  border: OutlineInputBorder(),
                ),
                items: widget.treatments
                    .map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text('${t.patientName}: ${t.description}'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _treatmentId = value),
                validator: (value) =>
                    value == null ? 'Please select a treatment' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter amount';
                  if (double.tryParse(value!) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                  DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                ],
                onChanged: (value) => setState(() => _status = value!),
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