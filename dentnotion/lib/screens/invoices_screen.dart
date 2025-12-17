import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/invoice.dart';
import '../widgets/status_badge.dart';

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
      final data = await _api.getInvoices();
      setState(() {
        _invoices = (data['results'] as List)
            .map((e) => Invoice.fromJson(e))
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
        onPressed: () {},
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
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}