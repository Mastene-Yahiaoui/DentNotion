import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/inventory_item.dart';
import '../widgets/status_badge.dart';

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
                fillColor: Colors.white,
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
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}