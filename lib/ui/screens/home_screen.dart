import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/models.dart';
import '../../state/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(airStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AirCare - Calidad del Aire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Seguro que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sí, salir'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                ref.read(authProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Error conectando al dispositivo:\n$e'),
          ),
        ),
        data: (AirSample s) {
          String desc = s.description.toLowerCase();
          desc = desc
              .replaceAll('á', 'a')
              .replaceAll('é', 'e')
              .replaceAll('í', 'i')
              .replaceAll('ó', 'o')
              .replaceAll('ú', 'u');

          Color color;
          IconData icon;
          String mensaje;

          if (desc.contains('limpio') || desc.contains('bueno')) {
            color = Colors.green;
            icon = Icons.eco;
            mensaje =
                '🌿 Calidad del aire: Buena. El aire está limpio. Mantén ventilación normal.';
          } else if (desc.contains('leve') || desc.contains('moderado')) {
            color = Colors.orange;
            icon = Icons.warning_amber_rounded;
            mensaje =
                '⚠️ Aire dañino para personas sensibles: Calidad aceptable, pero evita exposición prolongada en interiores.Usa mascarilla o purificador si es necesario.';
          } else {
            color = Colors.red;
            icon = Icons.dangerous;
            mensaje =
                '💀 Peligro extremo: Aire tóxico. Calidad peligrosa: ventila el área y evita toda exposición; evacúa si es posible..';
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black26,
                  color: color.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: color, size: 80),
                        const SizedBox(height: 16),
                        Text(
                          s.description,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CircularPercentIndicator(
                          radius: 80.0,
                          lineWidth: 12.0,
                          percent: (s.voltage / 3.3).clamp(0.0, 1.0),
                          center: Text(
                            '${s.voltage.toStringAsFixed(2)} V',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          progressColor: color,
                          backgroundColor: Colors.grey.shade200,
                          circularStrokeCap: CircularStrokeCap.round,
                          animation: true,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ADC: ${s.adc}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Última lectura: ${s.timestamp.toLocal().toString().split(".").first}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  color: Colors.blue.shade50,
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
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mensaje,
                          style: const TextStyle(fontSize: 16),
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
    );
  }
}
