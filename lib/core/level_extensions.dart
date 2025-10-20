import 'package:flutter/material.dart';
import 'models.dart';

/// Extensión para calcular nivel, color y etiquetas de calidad del aire
/// basadas en el voltaje leído desde el MQ135 (ESP32).
extension AirQualityExtensions on AirSample {
  /// Devuelve una etiqueta textual según el voltaje medido
  String get qualityLabel {
    if (voltage < 0.6) return "Bueno";
    if (voltage < 1.2) return "Moderado";
    if (voltage < 2.0) return "Dañino";
    return "Peligroso";
  }

  /// Devuelve un color representativo según el nivel de contaminación
  Color get qualityColor {
    if (voltage < 0.6) return Colors.green;
    if (voltage < 1.2) return Colors.yellow;
    if (voltage < 2.0) return Colors.orange;
    return Colors.red;
  }

  /// Devuelve un ícono para mostrar junto al estado
  IconData get qualityIcon {
    if (voltage < 0.6) return Icons.sentiment_very_satisfied;
    if (voltage < 1.2) return Icons.sentiment_neutral;
    if (voltage < 2.0) return Icons.sentiment_dissatisfied;
    return Icons.dangerous;
  }

  /// Texto descriptivo adicional (por ejemplo para tarjetas)
  String get statusMessage {
    switch (qualityLabel) {
      case "Bueno":
        return "El aire está limpio y seguro 😊";
      case "Moderado":
        return "Calidad del aire aceptable 😐";
      case "Dañino":
        return "Evita exposición prolongada 😷";
      case "Peligroso":
        return "Nivel alto de contaminación ⚠️";
      default:
        return "Sin datos disponibles";
    }
  }
}
