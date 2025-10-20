// file: lib/alerts/alert_manager.dart
import '../core/models.dart';
import '../core/thresholds.dart';
import '../services/notification_service.dart';

class AlertManager {
  final NotificationService _notifier;

  AlertManager(this._notifier);

  AirLevel? _lastLevel;

  /// Se llama cada vez que llega una nueva lectura del aire
  void handleSample(AirSample sample) {
    // Evaluamos la calidad del aire con las reglas de thresholds.dart
    final assessment = AirThresholds.assess(sample);

    // Solo notificamos si cambió el nivel
    if (_lastLevel != assessment.level) {
      _lastLevel = assessment.level;

      switch (assessment.level) {
        case AirLevel.good:
          _notifier.showNotification(
            title: '🌿 Calidad del aire: Buena',
            body: 'El aire está limpio y saludable.',
          );
          break;

        case AirLevel.moderate:
          _notifier.showNotification(
            title: '🌤️ Calidad del aire: Moderada',
            body:
                'Leve contaminación. Evita exposición prolongada si eres sensible.',
          );
          break;

        case AirLevel.unhealthySensitive:
          _notifier.showNotification(
            title: '⚠️ Aire dañino para personas sensibles',
            body: 'Usa mascarilla o purificador si es necesario.',
          );
          break;

        case AirLevel.unhealthy:
          _notifier.showNotification(
            title: '🚨 Aire perjudicial',
            body: 'Limita actividad física y ventila el espacio.',
          );
          break;

        case AirLevel.veryUnhealthy:
          _notifier.showNotification(
            title: '☣️ Aire muy dañino',
            body: 'Permanece en interiores y usa purificador.',
          );
          break;

        case AirLevel.hazardous:
          _notifier.showNotification(
            title: '💀 Peligro extremo: Aire tóxico',
            body: 'Evita toda exposición; evacúa si es posible.',
          );
          break;
      }
    }
  }
}
