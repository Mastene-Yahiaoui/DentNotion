// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/appointments_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  String? _error;

  int _totalPatients = 0;
  int _todayAppointments = 0;
  double _totalRevenue = 0;
  int _unpaidInvoices = 0;
  List<Appointment> _recentAppointments = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.getPatients(),
        _api.getAppointments(),
        _api.getInvoices(),
      ]);

      final today = DateTime.now().toIso8601String().split('T')[0];
      final appointments = (results[1]['results'] as List)
          .map((e) => Appointment.fromJson(e))
          .toList();
      final todayAppts = appointments.where((apt) => apt.date == today).length;

      final invoices = results[2]['results'] as List;
      final revenue = invoices
          .where((inv) => inv['status'] == 'Paid')
          .fold<double>(
              0, (sum, inv) => sum + double.parse(inv['amount'].toString()));
      final unpaid = invoices.where((inv) => inv['status'] == 'Unpaid').length;

      setState(() {
        _totalPatients = results[0]['count'] ?? 0;
        _todayAppointments = todayAppts;
        _totalRevenue = revenue;
        _unpaidInvoices = unpaid;
        _recentAppointments = appointments.take(5).toList();
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
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _formatDate(DateTime.now()),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            StatCard(
                              title: 'Total Patients',
                              value: _totalPatients.toString(),
                            ),
                            StatCard(
                              title: "Today's Appointments",
                              value: _todayAppointments.toString(),
                            ),
                            StatCard(
                              title: 'Total Revenue',
                              value: '\$${_totalRevenue.toStringAsFixed(2)}',
                            ),
                            StatCard(
                              title: 'Unpaid Invoices',
                              value: _unpaidInvoices.toString(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recent Appointments',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _recentAppointments.isEmpty
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child:
                                              Text('No recent appointments.'),
                                        ),
                                      )
                                    : AppointmentsTable(
                                        appointments: _recentAppointments,
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading dashboard data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
