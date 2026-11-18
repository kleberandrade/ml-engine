import 'package:ml_engine/ml_engine.dart';

/// Fits one-feature y=3x+2 and predicts held-out values through the same scaler.
void main() {
  final trainX = <List<double>>[
    [0],
    [1],
    [2],
    [3],
  ];
  final trainY = <double>[2, 5, 8, 11];
  final pipeline = Pipeline(
    StandardScaler(),
    LinearRegression(learningRate: .05, iterations: 1000),
  )..fit(trainX, trainY);
  final predictions = pipeline.predict([
    [4],
    [5],
  ]);
  final rmse = rootMeanSquaredError([14, 17], predictions);
  if (rmse > 1e-8) {
    throw StateError('Expected y=3x+2 predictions near [14,17].');
  }
  print('Predictions: $predictions; held-out RMSE: $rmse');
}
