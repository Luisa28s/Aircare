// file: lib/services/mock_device_service.dart
import 'dart:async';
import 'dart:math';
import '../core/models.dart';
import 'device_service.dart';

class MockDeviceService implements DeviceService {
  final _rng = Random();

  @override
  Future<AirSample> getCurrentSample() async {
    final adc = 400 + _rng.nextInt(200);
    final volt = adc / 1024 * 3.3;
    final desc = volt < 0.6
        ? 'Ambiente limpio - LED verde encendido'
        : volt < 1.5
            ? 'Calidad media - LED amarillo'
            : 'Contaminación detectada - LED rojo';

    return AirSample(
      adc: adc,
      voltage: volt,
      description: desc,
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<AirSample> samplesStream(
      {Duration interval = const Duration(seconds: 5)}) async* {
    while (true) {
      yield await getCurrentSample();
      await Future.delayed(interval);
    }
  }
}
