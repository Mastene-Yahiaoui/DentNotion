import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../theme.dart';

class AppointmentsTable extends StatelessWidget {
  final List<Appointment> appointments;
  final Function(Appointment)? onRowSelected;

  const AppointmentsTable({Key? key, required this.appointments, this.onRowSelected})
      : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.statusConfirmed;
      case 'Pending':
        return AppColors.statusPending;
      case 'Completed':
        return AppColors.statusCompleted;
      case 'Cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
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
                onSelectChanged: onRowSelected != null
                    ? (selected) {
                        if (selected == true) {
                          onRowSelected!(apt);
                        }
                      }
                    : null,
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
