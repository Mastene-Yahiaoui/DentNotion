import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/inventory_item.dart';
import '../widgets/status_badge.dart';
import '../theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  String? _error;
  List<InventoryItem> _inventory = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _api.getInventory();
      setState(() {
        _inventory = (data['results'] as List)
            .map((e) => InventoryItem.fromJson(e))
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
    print('Showing add inventory dialog');
    showDialog(
      context: context,
      builder: (context) => AddInventoryDialog(
        onSubmit: _createInventoryItem,
      ),
    );
  }

  Future<void> _createInventoryItem(Map<String, dynamic> data) async {
    try {
      await _api.createInventoryItem(data);
      _fetchInventory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory item created successfully')),
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

  List<InventoryItem> get _filteredInventory {
    if (_searchTerm.isEmpty) return _inventory;
    return _inventory
        .where((item) =>
            item.item.toLowerCase().contains(_searchTerm.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
              ),
              onChanged: (value) {
                setState(() => _searchTerm = value);
              },
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _fetchInventory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredInventory.length,
                    itemBuilder: (context, index) {
                      final item = _filteredInventory[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(item.item),
                          subtitle: Text('Quantity: ${item.quantity}'),
                          trailing: StatusBadge(status: item.status),
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

class AddInventoryDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddInventoryDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AddInventoryDialog> createState() => _AddInventoryDialogState();
}

class _AddInventoryDialogState extends State<AddInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();
  String _status = 'In Stock';
  bool _submitting = false;

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);

    final data = {
      'item': _itemController.text,
      'quantity': int.tryParse(_quantityController.text) ?? 0,
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
      title: const Text('Add New Inventory Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter item name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter quantity';
                  if (int.tryParse(value!) == null) return 'Please enter a valid number';
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
                  DropdownMenuItem(value: 'In Stock', child: Text('In Stock')),
                  DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock')),
                  DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock')),
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