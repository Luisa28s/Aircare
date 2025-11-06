import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class IpSetupScreen extends StatefulWidget {
  const IpSetupScreen({super.key});

  @override
  State<IpSetupScreen> createState() => _IpSetupScreenState();
}

class _IpSetupScreenState extends State<IpSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  /// 🔹 Si ya hay una IP guardada, pasa directo al Home
  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('device_ip');

    print('🌐 IP guardada previamente: $savedIp');

    if (savedIp != null && savedIp.isNotEmpty) {
      // Navega directo al Home si ya está guardada
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  /// 🔹 Guarda la IP en SharedPreferences
  Future<void> _saveIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_ip', ip);
    print('✅ IP guardada correctamente: $ip');
  }

  /// 🔹 Valida y continúa al HomeScreen
  void _validateAndContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      // 🔸 Limpia espacios y guarda la IP tal cual (sin http://)
      String ip = _ipController.text.trim();

      await _saveIp(ip);

      // Espera un momento antes de navegar
      await Future.delayed(const Duration(milliseconds: 400));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3C72),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: Colors.white.withOpacity(0.95),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🔗 Conexión al dispositivo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ingresa la dirección IP local del ESP32.\n'
                      'Ejemplo: 192.168.1.10',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    const SizedBox(height: 24),

                    // Campo IP
                    TextFormField(
                      controller: _ipController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Dirección IP',
                        prefixIcon: const Icon(Icons.router),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la IP';
                        }
                        final regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
                        if (!regex.hasMatch(value)) {
                          return 'Formato de IP inválido';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: _validateAndContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E64FE),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text(
                              'Conectar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
