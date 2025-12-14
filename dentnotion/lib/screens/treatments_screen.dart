import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/treatment.dart';

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
      final data = await _api.getTreatments();
      setState(() {
        _treatments = (data['results'] as List)
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
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}