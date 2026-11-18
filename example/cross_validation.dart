import 'package:ml_engine/ml_engine.dart';

/// Creates a fresh scaler and estimator for each held-out fold.
void main() {
  final x = List.generate(10, (i) => [i.toDouble()]);
  final y = List.generate(10, (i) => 3.0 * i + 2);
  final scores = crossValidate(
    x,
    y,
    kFold(x.length, k: 5, seed: 42),
    () => Pipeline(
      StandardScaler(),
      LinearRegression(learningRate: .05, iterations: 1000),
    ),
    rootMeanSquaredError,
  );
  if (scores.length != 5 || scores.any((v) => !v.isFinite || v > 1e-8)) {
    throw StateError('Expected five near-zero RMSE scores for y=3x+2.');
  }
  print('Five held-out RMSE scores (lower is better): $scores');
}
