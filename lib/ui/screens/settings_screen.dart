// 📁 file: lib/ui/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../state/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    final currentUrl = ref.read(baseUrlProvider);
    _urlController = TextEditingController(text: currentUrl);
  }

  Future<void> _saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('esp32_base_url', url.trim());
    ref.read(baseUrlProvider.notifier).state = url.trim();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Dirección del dispositivo actualizada: $url'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final useMock = ref.watch(useMockProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes del Sistema'),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 Simulador ON/OFF
          SwitchListTile(
            title: const Text('Usar simulador (sin dispositivo físico)'),
            subtitle: const Text(
                'Activa esta opción si no tienes conectado el ESP32.'),
            value: useMock,
            onChanged: (v) {
              ref.read(useMockProvider.notifier).state = v;
            },
          ),

          const Divider(height: 32),

          // 🔹 IP o URL del dispositivo
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Dirección del dispositivo (HTTP)',
              hintText: 'http://192.168.1.9',
              prefixIcon: Icon(Icons.link),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => _saveBaseUrl(v),
          ),
          const SizedBox(height: 12),

          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Guardar dirección'),
            onPressed: () => _saveBaseUrl(_urlController.text),
          ),

          const SizedBox(height: 32),

          // 🔹 Información adicional
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Descargo de responsabilidad'),
            subtitle: const Text(
              'Esta app es una herramienta educativa y preventiva. '
              'No reemplaza la orientación médica profesional.',
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
