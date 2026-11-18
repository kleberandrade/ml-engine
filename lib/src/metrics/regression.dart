import 'dart:math';
import 'validation.dart';

/// Mean squared prediction error for actual [y] and [predicted] values.
///
/// Lower is better; units are squared target units. Throws [ArgumentError] for
/// empty, mismatched or nonfinite input vectors. Finite extreme inputs can still
/// overflow the arithmetic and produce infinity; rescale magnitudes if needed.
double meanSquaredError(List<double> y, List<double> predicted) {
  validateMetricVectors(y, predicted);
  return List.generate(
        y.length,
        (i) => pow(y[i] - predicted[i], 2).toDouble(),
      ).reduce((a, b) => a + b) /
      y.length;
}

/// Square root of [meanSquaredError], in the original target units.
///
/// Uses the same vector validation and overflow behavior as [meanSquaredError].
/// Lower is better; zero means every prediction matches its target.
double rootMeanSquaredError(List<double> y, List<double> predicted) =>
    sqrt(meanSquaredError(y, predicted));

/// Mean absolute difference between actual [y] and [predicted] values.
///
/// Throws [ArgumentError] for empty, mismatched or nonfinite vectors. Lower is
/// better; extreme finite inputs can overflow differences or their sum.
double meanAbsoluteError(List<double> y, List<double> predicted) {
  validateMetricVectors(y, predicted);
  return List.generate(
        y.length,
        (i) => (y[i] - predicted[i]).abs(),
      ).reduce((a, b) => a + b) /
      y.length;
}

/// Coefficient of determination, 1 - residual sum / centered target sum.
///
/// A perfect fit scores 1; scores may be negative. For constant [y], returns 1
/// for exact predictions and 0 otherwise. Throws [ArgumentError] for empty,
/// mismatched or nonfinite vectors. Extreme finite arithmetic can yield NaN or
/// infinity; no finite-output guarantee is made for unscaled extreme values.
double rSquared(List<double> y, List<double> predicted) {
  validateMetricVectors(y, predicted);
  final mean = y.reduce((a, b) => a + b) / y.length;
  final variance = y.fold(0.0, (s, v) => s + pow(v - mean, 2));
  final residual = meanSquaredError(y, predicted) * y.length;
  return variance == 0 ? (residual == 0 ? 1 : 0) : 1 - residual / variance;
}
