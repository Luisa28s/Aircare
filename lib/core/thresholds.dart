import 'models.dart';

/// Umbrales de calidad del aire basados en el voltaje del MQ-135.
/// Estos valores son orientativos: ajústalos según tus mediciones reales.
class AirThresholds {
  static const double goodLimit = 0.6;
  static const double moderateLimit = 1.2;
  static const double unhealthySensitiveLimit = 1.6;
  static const double unhealthyLimit = 2.0;
  static const double veryUnhealthyLimit = 2.5;

  static AirAssessment assess(AirSample s) {
    final double v = s.voltage;
    double aqi;
    AirLevel level;

    if (v < goodLimit) {
      aqi = _interp(v, 0.0, goodLimit, 0, 50);
      level = AirLevel.good;
    } else if (v < moderateLimit) {
      aqi = _interp(v, goodLimit, moderateLimit, 51, 100);
      level = AirLevel.moderate;
    } else if (v < unhealthySensitiveLimit) {
      aqi = _interp(v, moderateLimit, unhealthySensitiveLimit, 101, 130);
      level = AirLevel.unhealthySensitive;
    } else if (v < unhealthyLimit) {
      aqi = _interp(v, unhealthySensitiveLimit, unhealthyLimit, 131, 170);
      level = AirLevel.unhealthy;
    } else if (v < veryUnhealthyLimit) {
      aqi = _interp(v, unhealthyLimit, veryUnhealthyLimit, 171, 220);
      level = AirLevel.veryUnhealthy;
    } else {
      aqi = _interp(v, veryUnhealthyLimit, 3.3, 221, 300);
      level = AirLevel.hazardous;
    }

    final messages = <String>[];

    switch (level) {
      case AirLevel.good:
        messages.add('El aire está limpio y seguro 😊');
        break;
      case AirLevel.moderate:
        messages.add('Calidad del aire aceptable 😐');
        break;
      case AirLevel.unhealthySensitive:
        messages.add('Personas sensibles deben tener precaución 😷');
        break;
      case AirLevel.unhealthy:
        messages.add('Evita exposición prolongada 🫤');
        break;
      case AirLevel.veryUnhealthy:
        messages.add('Muy dañino: quédate en interiores 🚫');
        break;
      case AirLevel.hazardous:
        messages.add('Peligroso: evita toda exposición ⚠️');
        break;
    }

    return AirAssessment(aqi: aqi, level: level, messages: messages);
  }

  static double _interp(double x, double x1, double x2, double y1, double y2) {
    return y1 + (x - x1) * (y2 - y1) / (x2 - x1);
  }
}
