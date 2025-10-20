import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/login_screen.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    return MaterialApp(
      title: 'AirCare',
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (_) => const HomeScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
