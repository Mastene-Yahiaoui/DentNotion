import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentsTable extends StatelessWidget {
  final List<Appointment> appointments;

  const AppointmentsTable({Key? key, required this.appointments})
      : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Reason')),
        ],
        rows: appointments
            .map(
              (apt) => DataRow(
                cells: [
                  DataCell(Text(apt.patientName)),
                  DataCell(Text(apt.date)),
                  DataCell(Text(apt.time)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(apt.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        apt.status,
                        style: TextStyle(
                          color: _getStatusColor(apt.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(apt.reason)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
