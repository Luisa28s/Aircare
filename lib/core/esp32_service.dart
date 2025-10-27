import 'dart:convert';
import 'package:http/http.dart' as http;

class Esp32Service {
  // Reemplazar esta IP por la que tu ESP32 muestra en el monitor serie
  final String baseUrl = 'http://192.168.1.9/';

  Future<Map<String, dynamic>> getAirData() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al conectar con el ESP32: ${response.statusCode}');
    }
  }
}
