// file: lib/state/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/air_repository.dart';
import '../services/device_service.dart';
import '../services/http_device_service.dart';
import '../services/mock_device_service.dart';
import '../services/notification_service.dart';
import '../alerts/alert_manager.dart';

// 🔹 Configuración de entorno y modo mock
final useMockProvider = StateProvider<bool>((ref) => false);
final baseUrlProvider = StateProvider<String>((ref) => 'http://192.168.1.24');

// 🔹 Servicio de comunicación con el dispositivo
final deviceServiceProvider = Provider<DeviceService>((ref) {
  final useMock = ref.watch(useMockProvider);
  if (useMock) return MockDeviceService();
  final baseUrl = ref.watch(baseUrlProvider);
  return HttpDeviceService(baseUrl);
});

// 🔹 Repositorio de datos del aire
final airRepoProvider = Provider<AirRepository>(
  (ref) => AirRepository(ref.watch(deviceServiceProvider)),
);

// 🔹 Servicios auxiliares
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final alertManagerProvider = Provider<AlertManager>(
  (ref) => AlertManager(ref.watch(notificationServiceProvider)),
);

// 🔹 Stream de mediciones + alertas automáticas
final airStreamProvider = StreamProvider.autoDispose((ref) async* {
  final repo = ref.watch(airRepoProvider);
  final alerts = ref.watch(alertManagerProvider);
  await ref.watch(notificationServiceProvider).init();

  await for (final s in repo.streamSamples(every: const Duration(seconds: 4))) {
    // Dispara alertas sin bloquear la UI
    alerts.handleSample(s);
    yield s;
  }
});

// 🔹 Estado de autenticación simple (login quemado)
final authProvider =
    StateNotifierProvider<AuthNotifier, bool>((ref) => AuthNotifier());

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  void login() => state = true;
  void logout() => state = false;
}
