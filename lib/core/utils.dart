import 'package:flutter/material.dart';
import 'models.dart';

extension LevelX on AirLevel {
  /// Nombre legible del nivel de calidad del aire.
  String label() {
    switch (this) {
      case AirLevel.good:
        return 'Bueno';
      case AirLevel.moderate:
        return 'Moderado';
      case AirLevel.unhealthySensitive:
        return 'Dañino para sensibles';
      case AirLevel.unhealthy:
        return 'Dañino';
      case AirLevel.veryUnhealthy:
        return 'Muy dañino';
      case AirLevel.hazardous:
        return 'Peligroso';
    }
  }

  /// Color representativo del nivel (para UI).
  Color color() {
    switch (this) {
      case AirLevel.good:
        return Colors.green;
      case AirLevel.moderate:
        return Colors.yellow;
      case AirLevel.unhealthySensitive:
        return Colors.deepOrangeAccent;
      case AirLevel.unhealthy:
        return Colors.orange;
      case AirLevel.veryUnhealthy:
        return Colors.redAccent;
      case AirLevel.hazardous:
        return Colors.purple;
    }
  }
}
