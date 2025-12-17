import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Map<String, Color>? colorMap;

  const StatusBadge({
    Key? key,
    required this.status,
    this.colorMap,
  }) : super(key: key);

  Color _getColor() {
    if (colorMap != null && colorMap!.containsKey(status)) {
      return colorMap![status]!;
    }

    // Default color mapping
    switch (status.toLowerCase()) {
      case 'paid':
      case 'confirmed':
      case 'completed':
      case 'in stock':
        return Colors.green;
      case 'pending':
      case 'low stock':
        return Colors.orange;
      case 'unpaid':
      case 'cancelled':
      case 'out of stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}