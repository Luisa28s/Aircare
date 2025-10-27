// file: lib/ui/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useMock = ref.watch(useMockProvider);
    final url = ref.watch(baseUrlProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Usar simulador (sin dispositivo físico)'),
            value: useMock,
            onChanged: (v) => ref.read(useMockProvider.notifier).state = v,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'URL del dispositivo (HTTP)',
              hintText: 'http://192.168.1.9',
              prefixIcon: Icon(Icons.link),
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: url),
            onSubmitted: (v) =>
                ref.read(baseUrlProvider.notifier).state = v.trim(),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.medical_information_outlined),
            title: const Text('Descargo de responsabilidad'),
            subtitle: const Text(
                'Esta app no sustituye consejo médico. Úsala como apoyo preventivo.'),
          ),
        ],
      ),
    );
  }
}
