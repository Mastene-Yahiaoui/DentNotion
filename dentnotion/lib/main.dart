// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/patients_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/treatments_screen.dart';
import 'screens/invoices_screen.dart';
import 'screens/inventory_screen.dart';
import 'services/api_service.dart';
import 'models/appointment.dart';
import 'widgets/stat_card.dart';
import 'widgets/appointments_table.dart';
import 'theme.dart';

void main() {
  runApp(const DentFlowApp());
}

class DentFlowApp extends StatelessWidget {
  const DentFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DentFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    DashboardScreen(onNavigateToAppointments: () => setState(() => _selectedIndex = 2)),
    const PatientsScreen(),
    const AppointmentsScreen(),
    const TreatmentsScreen(),
    const InvoicesScreen(),
    const InventoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      drawer: Drawer(
        child: Container(
          color: AppColors.drawerBackground,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                color: AppColors.drawerHeaderBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 40),
                    Text(
                      '🦷 DentFlow',
                      style: TextStyle(
                        color: AppColors.textDrawer,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Dental Clinic Management',
                      style: TextStyle(
                        color: AppColors.textDrawerSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(0, '📊 Dashboard', '/dashboard'),
                    _buildMenuItem(1, '👥 Patients', '/patients'),
                    _buildMenuItem(2, '📅 Appointments', '/appointments'),
                    _buildMenuItem(3, '🦷 Treatments', '/treatments'),
                    _buildMenuItem(4, '📄 Invoices', '/invoices'),
                    _buildMenuItem(5, '📦 Inventory', '/inventory'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderLight),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '© 2025 DentFlow',
                      style: TextStyle(
                        color: AppColors.textDrawerSecondary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, String route) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.drawerHeaderBackground : Colors.transparent,
          border: isSelected
              ? const Border(
                  right: BorderSide(color: AppColors.primary, width: 4),
                )
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.textDrawer : AppColors.textDrawerSecondary,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Dashboard implementation (in-file)

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToAppointments;

  const DashboardScreen({Key? key, this.onNavigateToAppointments}) : super(key: key);

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
          .fold<double>(0, (sum, inv) => sum + double.parse(inv['amount'].toString()));
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
                              icon: '👥',
                            ),
                            StatCard(
                              title: "Today's Appointments",
                              value: _todayAppointments.toString(),
                              icon: '📅',
                            ),
                            StatCard(
                              title: 'Total Revenue',
                              value: '\$${_totalRevenue.toStringAsFixed(2)}',
                              icon: '💰',
                            ),
                            StatCard(
                              title: 'Unpaid Invoices',
                              value: _unpaidInvoices.toString(),
                              icon: '📄',
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
                                          child: Text('No recent appointments.'),
                                        ),
                                      )
                                    : AppointmentsTable(
                                        appointments: _recentAppointments,
                                        onRowSelected: (appointment) {
                                          widget.onNavigateToAppointments?.call();
                                        },
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}