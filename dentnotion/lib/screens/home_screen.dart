// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'patients_screen.dart';
import 'appointments_screen.dart';
import 'treatments_screen.dart';
import 'invoices_screen.dart';
import 'inventory_screen.dart';
import '../widgets/bottom_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
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
      bottomNavigationBar: BottomNavbar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF1F2937),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                color: const Color(0xFF111827),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 40),
                    Text(
                      '🦷 DentFlow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Dental Clinic Management',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
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
                    top: BorderSide(color: Color(0xFF374151)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '© 2025 DentFlow',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
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
          color: isSelected ? const Color(0xFF111827) : Colors.transparent,
          border: isSelected
              ? const Border(
                  right: BorderSide(color: Colors.blue, width: 4),
                )
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
