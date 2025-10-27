// 📁 file: lib/state/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/air_repository.dart';
import '../services/device_service.dart';
import '../services/http_device_service.dart';
import '../services/mock_device_service.dart';
import '../services/notification_service.dart';
import '../alerts/alert_manager.dart';
import 'history_notifier.dart';

/// 🔹 Configuración de entorno
final useMockProvider = StateProvider<bool>((ref) => false);
final baseUrlProvider = StateProvider<String>((ref) => 'http://192.168.1.9');

/// 🔹 Servicio de comunicación con el dispositivo (HTTP o Mock)
final deviceServiceProvider = Provider<DeviceService>((ref) {
  final useMock = ref.watch(useMockProvider);
  if (useMock) return MockDeviceService();

  final baseUrl = ref.watch(baseUrlProvider);
  return HttpDeviceService(baseUrl);
});

/// 🔹 Repositorio de datos del aire
final airRepoProvider = Provider<AirRepository>(
  (ref) => AirRepository(ref.watch(deviceServiceProvider)),
);

/// 🔹 Servicios auxiliares
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final alertManagerProvider = Provider<AlertManager>(
  (ref) => AlertManager(ref.watch(notificationServiceProvider)),
);

/// 🔹 Stream principal de lecturas del aire + alertas automáticas
final airStreamProvider = StreamProvider.autoDispose((ref) async* {
  final repo = ref.watch(airRepoProvider);
  final alerts = ref.watch(alertManagerProvider);
  final notificationService = ref.watch(notificationServiceProvider);

  // Inicializa las notificaciones solo una vez
  await notificationService.init();

  await for (final s in repo.streamSamples(every: const Duration(seconds: 4))) {
    alerts.handleSample(s); // Manejo de alertas sin bloquear la UI
    ref.read(historyProvider.notifier).addSample(s); // Guarda histórico
    yield s;
  }
});

/// 🔹 Historial de mediciones (para predicción)
final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>(
  (ref) => HistoryNotifier(capacity: 40),
);

/// 🔹 Estado de autenticación simple (login/logout)
final authProvider =
    StateNotifierProvider<AuthNotifier, bool>((ref) => AuthNotifier());

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  /// Inicia sesión si las credenciales son correctas
  void login(String username, String password) {
    const validUser = 'usuario';
    const validPass = 'labasura1*';

    if (username == validUser && password == validPass) {
      state = true;
      print('✅ Usuario autenticado correctamente');
    } else {
      state = false;
      print('❌ Credenciales incorrectas');
    }
  }

  /// Cierra sesión
  void logout() {
    state = false;
    print('🔒 Sesión cerrada');
  }
}
