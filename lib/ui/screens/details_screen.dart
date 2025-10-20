// file: lib/ui/screens/details_screen.dart
import 'package:flutter/material.dart';
import '../../core/models.dart';

class DetailsScreen extends StatelessWidget {
  final AirSample sample;
  const DetailsScreen({super.key, required this.sample});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de medición')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(sample.toJson().toString()),
      ),
    );
  }
}
