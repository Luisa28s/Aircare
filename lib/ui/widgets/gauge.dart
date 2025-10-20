// file: lib/ui/widgets/gauge.dart
import 'package:flutter/material.dart';

class SimpleGauge extends StatelessWidget {
  final double value; // 0..500 para AQI
  final String label;
  const SimpleGauge({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final pct = (value / 500).clamp(0.0, 1.0).toDouble();
    return LayoutBuilder(
      builder: (context, c) {
        final size = c.maxWidth;
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 14,
                value: pct,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 4),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ],
        );
      },
    );
  }
}
