// file: lib/utils/forecast.dart
import 'dart:math';
import '../core/models.dart';

class ForecastResult {
  final double predictedVoltage;
  final double slopePerSecond; // pendiente en V/segundo
  final bool worsening; // si la tendencia empeora
  final double intercept;

  ForecastResult({
    required this.predictedVoltage,
    required this.slopePerSecond,
    required this.worsening,
    required this.intercept,
  });
}

/// Predicción por regresión lineal usando timestamps.
/// samples: lista ordenada por timestamp ascendente (más antiguo -> más reciente)
/// stepsAheadSeconds: cuántos segundos en el futuro predecir (p.ej. 300 = 5 min)
class AirForecast {
  static ForecastResult predictVoltage(
    List<AirSample> samples, {
    int stepsAheadSeconds = 300,
  }) {
    if (samples.isEmpty) {
      return ForecastResult(
        predictedVoltage: 0.0,
        slopePerSecond: 0.0,
        worsening: false,
        intercept: 0.0,
      );
    }

    if (samples.length == 1) {
      return ForecastResult(
        predictedVoltage: samples
            .last.voltage, // sin información de tendencia, devolvemos actual
        slopePerSecond: 0.0,
        worsening: false,
        intercept: samples.last.voltage,
      );
    }

    // Transformar timestamps a segundos relativos (x) y voltajes (y)
    final base = samples.first.timestamp.millisecondsSinceEpoch / 1000.0;
    final xs = <double>[];
    final ys = <double>[];
    for (var s in samples) {
      xs.add(s.timestamp.millisecondsSinceEpoch / 1000.0 - base);
      ys.add(s.voltage);
    }

    final n = xs.length;
    final meanX = xs.reduce((a, b) => a + b) / n;
    final meanY = ys.reduce((a, b) => a + b) / n;

    double num = 0.0;
    double den = 0.0;
    for (var i = 0; i < n; i++) {
      final dx = xs[i] - meanX;
      num += dx * (ys[i] - meanY);
      den += dx * dx;
    }

    // si den == 0 (todos los timestamps iguales por algún error), manejamos
    final slope = den == 0.0 ? 0.0 : num / den; // V por segundo
    final intercept = meanY - slope * meanX;

    // Predicción stepsAheadSeconds en segundos desde ahora
    final lastX = xs.last;
    final futureX = lastX + stepsAheadSeconds;
    final predicted = intercept + slope * futureX;

    // definimos empeoramiento si la pendiente es mayor que un umbral simple
    // umbral en V/segundo; ajústalo si es necesario.
    final double slopeThreshold = 0.0005; // ejemplo: 0.0005 V/s -> 0.03 V/min
    final worsening = slope > slopeThreshold;

    return ForecastResult(
      predictedVoltage: predicted,
      slopePerSecond: slope,
      worsening: worsening,
      intercept: intercept,
    );
  }
}

double predictNextValue(List<double> voltages) {
  if (voltages.isEmpty) return 0.0;
  if (voltages.length == 1) return voltages.first;
  final n = voltages.length;
  final x = List.generate(n, (i) => i.toDouble());
  final meanX = x.reduce((a, b) => a + b) / n;
  final meanY = voltages.reduce((a, b) => a + b) / n;
  double num = 0.0, den = 0.0;
  for (int i = 0; i < n; i++) {
    num += (x[i] - meanX) * (voltages[i] - meanY);
    den += (x[i] - meanX) * (x[i] - meanX);
  }
  final slope = num / den;
  final intercept = meanY - slope * meanX;
  return intercept + slope * n; // próxima predicción
}
