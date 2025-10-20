// file: lib/ui/widgets/metric_chip.dart
import 'package:flutter/material.dart';

class MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const MetricChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  // Mapa de colores por métrica
  Color _backgroundColor(String label, BuildContext context) {
    switch (label.toLowerCase()) {
      case 'pm2.5':
      case 'pm10':
        return Colors.orange.shade100;
      case 'co₂':
        return Colors.purple.shade100;
      case 'tvoc':
        return Colors.amber.shade100;
      case 'temp':
        return Colors.red.shade100;
      case 'humedad':
        return Colors.blue.shade100;
      default:
        return Theme.of(context).colorScheme.surfaceVariant;
    }
  }

  Color _iconColor(String label) {
    switch (label.toLowerCase()) {
      case 'pm2.5':
      case 'pm10':
        return Colors.deepOrange;
      case 'co₂':
        return Colors.purple;
      case 'tvoc':
        return Colors.amber.shade800;
      case 'temp':
        return Colors.redAccent;
      case 'humedad':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _backgroundColor(label, context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: _iconColor(label)),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
