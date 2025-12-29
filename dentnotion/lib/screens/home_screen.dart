// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'patients_screen.dart';
import 'appointments_screen.dart';
import 'treatments_screen.dart';
import 'invoices_screen.dart';
import 'inventory_screen.dart';
import 'setting_screen.dart';
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
      appBar: AppBar(
        title: const Text(
          'DentNotion',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavbar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

    );
  }

  // Widget _buildMenuItem(int index, String title, String route) {
  //   final isSelected = _selectedIndex == index;
  //   return InkWell(
  //     onTap: () {
  //       setState(() {
  //         _selectedIndex = index;
  //       });
  //       Navigator.pop(context);
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  //       decoration: BoxDecoration(
  //         color: isSelected ? const Color(0xFF111827) : Colors.transparent,
  //         border: isSelected
  //             ? const Border(
  //                 right: BorderSide(color: Colors.blue, width: 4),
  //               )
  //             : null,
  //       ),
  //       child: Text(
  //         title,
  //         style: TextStyle(
  //           color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
  //           fontSize: 16,
  //           fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
