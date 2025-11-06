import 'dart:async';
import 'package:aircare/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models.dart';
import '../../state/providers.dart';
import '../../state/history_notifier.dart';
import '../../utils/forecast.dart';
import 'ip_setup_screen.dart'; // ✅ Para redirigir al cambio de IP

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  Color _startColor = const Color(0xFF007AFF);
  Color _endColor = const Color(0xFF00C6FF);
  String? _deviceIp;

  @override
  void initState() {
    super.initState();
    _loadDeviceIp();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      ref.invalidate(airStreamProvider);
    });
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  // ✅ Cargar la IP guardada del dispositivo y actualizar provider
  Future<void> _loadDeviceIp() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('device_ip');

    if (savedIp == null || savedIp.isEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const IpSetupScreen()),
        );
      }
      return;
    }

    // ✅ Actualizar el provider global con la IP guardada
    ref.read(baseUrlProvider.notifier).state = 'http://$savedIp';
    debugPrint('✅ Usando IP del dispositivo: http://$savedIp');

    setState(() {
      _deviceIp = savedIp;
    });
  }

  // ✅ Cambiar IP manualmente (botón en AppBar)
  Future<void> _changeIp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('device_ip');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const IpSetupScreen()),
      );
    }
  }

  // ✅ Transición suave del fondo
  void _updateBackground(Color mainColor) {
    setState(() {
      _startColor = mainColor.withOpacity(0.8);
      _endColor = mainColor.withOpacity(0.4);
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(airStreamProvider);
    final history = ref.watch(historyProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 39, 67, 189),
                Color.fromARGB(255, 29, 31, 184)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AirCare',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        tooltip: 'Configurar IP',
                        onPressed: _changeIp,
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.help_outline, color: Colors.white),
                        tooltip: 'Glosario',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('📘 Glosario de términos'),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '🔹 V (Voltaje): Valor del voltaje medido por el sensor. Indica la intensidad eléctrica asociada a partículas o gases en el aire.'),
                                  SizedBox(height: 6),
                                  Text(
                                      '🔹 ADC (Conversión Analógica-Digital): Valor numérico que representa la señal analógica del sensor. '
                                      'Un valor ADC alto puede indicar mayor concentración de contaminantes.'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Cerrar sesión',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Cerrar sesión'),
                              content: const Text(
                                  '¿Seguro que deseas salir de AirCare?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent),
                                  child: const Text('Salir'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            // 🔹 Cierra sesión
                            ref.read(authProvider.notifier).logout();
                            // 🔹 Borra IP guardada (opcional)
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('device_ip');
                            // 🔹 Redirige al login
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ======== BODY ========
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_startColor, _endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (e, _) => Center(
            child: Text('Error conectando al dispositivo:\n$e',
                style: const TextStyle(color: Colors.white)),
          ),
          data: (AirSample s) {
            // ===== NIVEL ACTUAL =====
            String desc = s.description.toLowerCase();
            Color color;
            IconData icon;
            List<String> recomendaciones;

            if (desc.contains('limpio') || desc.contains('bueno')) {
              color = Colors.green.shade600;
              icon = Icons.eco_rounded;
              recomendaciones = [
                '🌿 Excelente momento para ventilar tu espacio.',
                'Realiza caminatas o ejercicio al aire libre.',
                'No se requieren medidas especiales.',
              ];
            } else if (desc.contains('moderado') || desc.contains('leve')) {
              color = Colors.orange.shade700;
              icon = Icons.warning_amber_rounded;
              recomendaciones = [
                '⚠️ Evita actividades físicas intensas al aire libre.',
                'Si tienes alergias o asma, mantente en interiores.',
                'Ventila por períodos cortos.',
              ];
            } else {
              color = Colors.red.shade700;
              icon = Icons.dangerous_rounded;
              recomendaciones = [
                '💀 Evita salir de casa o exponerte al exterior.',
                'Usa purificadores o mascarilla N95.',
                'Mantén puertas y ventanas cerradas.',
              ];
            }

            _updateBackground(color);

            // ===== PREDICCIÓN IA =====
            double? forecast;
            String estado = '';
            String explicacion = '';
            IconData trendIcon = Icons.trending_flat;

            if (history.samples.length >= 3) {
              final voltages = history.samples.map((h) => h.voltage).toList();
              forecast = predictNextValue(voltages);
              if (forecast < 1.0) {
                estado = 'buena';
                explicacion =
                    '💨 Se espera una mejora en la calidad del aire en la próxima hora.';
                trendIcon = Icons.trending_down;
              } else if (forecast < 2.0) {
                estado = 'moderada';
                explicacion =
                    '🌤 La calidad del aire se mantendrá estable durante la próxima hora.';
                trendIcon = Icons.trending_up;
              } else {
                estado = 'mala';
                explicacion =
                    '🚨 Se prevé un deterioro en la calidad del aire durante la próxima hora.';
                trendIcon = Icons.trending_up;
              }
            }

            return FadeTransition(
              opacity: _fade,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                children: [
                  // CARD PRINCIPAL
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularPercentIndicator(
                          radius: 90,
                          lineWidth: 12,
                          percent: (s.voltage / 3.3).clamp(0.0, 1.0),
                          center: Text(
                            '${s.voltage.toStringAsFixed(2)} V',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          progressColor: color,
                          backgroundColor: Colors.white24,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        const SizedBox(height: 16),
                        Icon(icon, color: color, size: 70),
                        const SizedBox(height: 12),
                        Text(
                          'Calidad actual: ${s.description}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Última lectura: ${s.timestamp.toLocal().toString().split(".").first}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CARD PREDICCIÓN
                  if (forecast != null)
                    Card(
                      color: Colors.white.withOpacity(0.15),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(trendIcon, color: Colors.white, size: 50),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Predicción IA (Próxima hora)',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Calidad del aire: $estado',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  Text(
                                    explicacion,
                                    style: const TextStyle(
                                        fontSize: 15, color: Colors.white70),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Voltaje estimado: ${forecast.toStringAsFixed(2)} V',
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // CARD RECOMENDACIONES
                  Card(
                    color: color.withOpacity(0.25),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recomendaciones',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          ...recomendaciones.map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle,
                                      size: 8, color: Colors.white70),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      r,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
