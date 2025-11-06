import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Esp32Service {
  Future<String?> _getSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_ip');
  }

  Future<Map<String, dynamic>> getAirData() async {
    final ip = await _getSavedIp();

    if (ip == null || ip.isEmpty) {
      throw Exception('No se ha configurado la dirección IP del dispositivo.');
    }

    final url = 'http://$ip/';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al conectar con el ESP32: ${response.statusCode}');
    }
  }
}
