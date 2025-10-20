// file: lib/data/air_repository.dart
import '../core/models.dart';
import '../services/device_service.dart';

class AirRepository {
  final DeviceService device;
  AirRepository(this.device);

  Future<AirSample> getNow() => device.getCurrentSample();
  Stream<AirSample> streamSamples({Duration every = const Duration(seconds: 5)}) =>
      device.samplesStream(interval: every);
}
