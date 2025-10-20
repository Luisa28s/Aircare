import 'dart:convert';

/// Representa una muestra de calidad del aire proveniente del ESP32.
/// Solo usa valores del MQ-135 (ADC, voltaje, descripción).
class AirSample {
  final DateTime timestamp;
  final int adc; // Valor ADC leído (0–4095)
  final double voltage; // Voltaje en V
  final String description; // Descripción del estado (ej. “Ambiente limpio”)

  const AirSample({
    required this.timestamp,
    required this.adc,
    required this.voltage,
    required this.description,
  });

  factory AirSample.fromJson(Map<String, dynamic> j) => AirSample(
        timestamp: DateTime.tryParse(j['timestamp']?.toString() ?? '') ??
            DateTime.now(),
        adc: (j['adc'] ?? 0).toInt(),
        voltage: (j['voltage'] ?? 0).toDouble(),
        description: j['description']?.toString() ?? 'Sin datos',
      );

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'adc': adc,
        'voltage': voltage,
        'description': description,
      };

  String encode() => jsonEncode(toJson());
}

/// Niveles cualitativos de calidad del aire.
enum AirLevel {
  good,
  moderate,
  unhealthySensitive,
  unhealthy,
  veryUnhealthy,
  hazardous,
}

/// Evaluación del aire con índice y recomendaciones.
class AirAssessment {
  final double aqi; // índice simplificado 0–300
  final AirLevel level;
  final List<String> messages; // mensajes de salud o recomendaciones

  const AirAssessment({
    required this.aqi,
    required this.level,
    required this.messages,
  });
}
