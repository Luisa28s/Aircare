import '../core/models.dart';

abstract class DeviceService {
  Future<AirSample> getCurrentSample();
  Stream<AirSample> samplesStream(
      {Duration interval = const Duration(seconds: 5)});
}
