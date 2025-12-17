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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
