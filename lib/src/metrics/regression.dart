import 'dart:math';
import 'validation.dart';

double meanSquaredError(List<double> y, List<double> predicted) {
  validateMetricVectors(y, predicted);
  return List.generate(
        y.length,
        (i) => pow(y[i] - predicted[i], 2).toDouble(),
      ).reduce((a, b) => a + b) /
      y.length;
}

double rootMeanSquaredError(List<double> y, List<double> predicted) =>
    sqrt(meanSquaredError(y, predicted));
double meanAbsoluteError(List<double> y, List<double> predicted) {
  validateMetricVectors(y, predicted);
  return List.generate(
        y.length,
        (i) => (y[i] - predicted[i]).abs(),
      ).reduce((a, b) => a + b) /
      y.length;
}

/// Constant targets: 1 for perfect predictions, 0 otherwise.
double rSquared(List<double> y, List<double> predicted) {
  validateMetricVectors(y, predicted);
  final mean = y.reduce((a, b) => a + b) / y.length;
  final variance = y.fold(0.0, (s, v) => s + pow(v - mean, 2));
  final residual = meanSquaredError(y, predicted) * y.length;
  return variance == 0 ? (residual == 0 ? 1 : 0) : 1 - residual / variance;
}
