# aircare

A new Flutter project.
# 🌬️ AirCare

Aplicación móvil Flutter que monitorea la calidad del aire en tiempo real mediante sensores conectados a una placa ESP32.

## 🚀 Características
- Lectura en vivo de sensores de calidad del aire.
- Alertas visuales y notificaciones.
- Sistema de autenticación básico.
- Predicción a corto plazo (forecast) usando regresión lineal simple.
- Interfaz moderna con modo de recomendaciones.

## 🧠 Tecnologías utilizadas
- Flutter & Dart
- Riverpod (gestión de estado)
- HTTP para comunicación con ESP32
- Notificaciones locales
- Gráficas y percent indicators

## ⚙️ Instalación
1. Clonar el repositorio:
   ```bash
   git clone https://github.com/Luisa28s/Aircare.git

Ingresar a la carpeta:

cd Aircare


Instalar dependencias:

flutter pub get


Ejecutar la aplicación:

flutter run

📱 Credenciales de acceso

Usuario: usuario

Contraseña: labasura1*

Código para el dispositivo (ESP32 / Arduino)

Para que la aplicación reciba datos reales, carga el siguiente script en tu placa ESP32:

#include <WiFi.h>

// Pines de los LEDs
const int ledVerde = 27;
const int ledAmarillo = 14;
const int ledRojo = 12;

// Pin analógico del MQ-135
const int mqPin = 34;

// Configuración de WiFi
const char* ssid = "Superman";       // Cambia esto por tu red
const char* password = "labasura1";  // Cambia esto

// Configuración del servidor
WiFiServer server(80);

// Parámetros
float umbralLimpio = 0.7;
float umbralLeve = 1.5;
int muestras = 10;
int tiempoLectura = 300;

void setup() {
  Serial.begin(19200);

  pinMode(ledVerde, OUTPUT);
  pinMode(ledAmarillo, OUTPUT);
  pinMode(ledRojo, OUTPUT);

  Serial.println("Conectando al WiFi...");
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("Conectado al WiFi!");
  Serial.print("Dirección IP: ");
  Serial.println(WiFi.localIP());

  server.begin();
}

void loop() {
  int total = 0;
  for (int i = 0; i < muestras; i++) {
    total += analogRead(mqPin);
    delay(10);
  }

  int val = total / muestras;
  float voltage = val * (3.3 / 4095.0);

  String calidad;
  if (voltage < umbralLimpio) {
    digitalWrite(ledVerde, HIGH);
    digitalWrite(ledAmarillo, LOW);
    digitalWrite(ledRojo, LOW);
    calidad = "Limpio";
  } else if (voltage < umbralLeve) {
    digitalWrite(ledVerde, LOW);
    digitalWrite(ledAmarillo, HIGH);
    digitalWrite(ledRojo, LOW);
    calidad = "Leve";
  } else {
    digitalWrite(ledVerde, LOW);
    digitalWrite(ledAmarillo, LOW);
    digitalWrite(ledRojo, HIGH);
    calidad = "Contaminado";
  }

  // Espera por conexión de cliente (navegador / Flutter Web)
  WiFiClient client = server.available();
  if (client) {
    String request = client.readStringUntil('\r');
    client.flush();

    // 🔹 JSON de respuesta
    String json = "{";
    json += "\"ADC\": " + String(val) + ",";
    json += "\"Voltaje\": " + String(voltage, 3) + ",";
    json += "\"Calidad\": \"" + calidad + "\"";
    json += "}";

    // 🔹 Respuesta HTTP con cabeceras CORS
    client.println("HTTP/1.1 200 OK");
    client.println("Content-Type: application/json");
    client.println("Access-Control-Allow-Origin: *");
    client.println("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    client.println("Access-Control-Allow-Headers: Content-Type");
    client.println("Connection: close");
    client.println();
    client.println(json);

    delay(10);
    client.stop();
  }

  delay(tiempoLectura);
}



📍 Instrucciones:

Cambia ssid y password por tu red Wi-Fi.

Conecta el sensor MQ-135 al pin 34 (entrada analógica).

Sube el código a tu ESP32.

Abre la app y configura la IP mostrada en el monitor serial.