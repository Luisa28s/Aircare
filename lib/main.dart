import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/ip_setup_screen.dart';
import 'ui/theme.dart';
import 'services/notification_service.dart';
import 'state/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el servicio de notificaciones
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const ProviderScope(child: AirCareApp()));
}

class AirCareApp extends ConsumerWidget {
  const AirCareApp({super.key});

  /// 🔹 Determina la pantalla inicial:
  /// - LoginScreen si no ha iniciado sesión
  /// - IpSetupScreen si no hay IP guardada
  /// - HomeScreen si ya todo está listo
  Future<Widget> _determineStartScreen(bool isLoggedIn) async {
    if (!isLoggedIn) {
      return const LoginScreen();
    }

    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('device_ip');
    debugPrint('🌐 IP guardada: $savedIp');

    if (savedIp == null || savedIp.isEmpty) {
      return const IpSetupScreen();
    }

    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    return FutureBuilder<Widget>(
      future: _determineStartScreen(isLoggedIn),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              backgroundColor: Color(0xFF1E3C72),
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'AirCare',
          theme: appTheme(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/home': (_) => const HomeScreen(),
            '/settings': (_) => const SettingsScreen(),
            '/ipsetup': (_) => const IpSetupScreen(),
          },
          home: snapshot.data!,
        );
      },
    );
  }
}
