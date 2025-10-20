import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/models.dart';
import 'device_service.dart';

class HttpDeviceService implements DeviceService {
  final String baseUrl;
  HttpDeviceService(this.baseUrl);

  @override
  Future<AirSample> getCurrentSample() async {
    try {
      final uri = Uri.parse(baseUrl);
      final res = await http.get(uri).timeout(const Duration(seconds: 4));

      if (res.statusCode != 200) {
        throw Exception('Dispositivo no responde (${res.statusCode})');
      }

      final data = jsonDecode(res.body);

      final int adc = data['ADC'] ?? 0;
      final double voltage = (data['Voltaje'] ?? 0).toDouble();
      final String desc = data['Calidad'] ?? 'Sin datos';

      return AirSample(
        adc: adc,
        voltage: voltage,
        description: desc,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error obteniendo datos del ESP32: $e');
    }
  }

  @override
  Stream<AirSample> samplesStream({
    Duration interval = const Duration(seconds: 5),
  }) async* {
    while (true) {
      try {
        yield await getCurrentSample();
      } catch (e) {
        // Si hay error, simplemente seguimos el stream sin detenerlo
      }
      await Future.delayed(interval);
    }
  }
}
