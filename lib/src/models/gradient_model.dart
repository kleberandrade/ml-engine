import 'dart:math';
import '../data/matrix.dart';
import 'estimator.dart';

abstract class GradientModel implements Estimator {
  final double learningRate;
  final int iterations;
  final bool logistic;
  Matrix? _x;
  List<double> _y = [], _weights = [];
  final List<double> _history = [];
  double _bias = 0;
  int get completedIterations => _history.length;
  List<double> get costHistory => List.unmodifiable(_history);
  List<double> get coefficients => List.unmodifiable(_weights);
  double get intercept => _bias;
  GradientModel({
    required this.logistic,
    required this.learningRate,
    required this.iterations,
  }) {
    if (!learningRate.isFinite || learningRate <= 0 || iterations < 1) {
      throw ArgumentError(
        'Positive finite learning rate and iterations required.',
      );
    }
  }
  void start(Matrix x, List<double> y) {
    validateTargets(x, y);
    if (logistic && y.any((v) => v != 0 && v != 1)) {
      throw ArgumentError('Binary labels must be 0 or 1.');
    }
    _x = x.map((r) => List<double>.of(r)).toList();
    _y = List.of(y);
    _weights = List.filled(x.first.length, 0);
    _bias = 0;
    _history.clear();
  }

  double _score(List<double> row) => _scoreWith(row, _weights, _bias);

  double _scoreWith(List<double> row, List<double> weights, double bias) {
    var value = bias;
    for (var j = 0; j < row.length; j++) {
      value += row[j] * weights[j];
    }
    if (!value.isFinite) {
      throw StateError(
        'Training diverged. Lower learning rate or scale features.',
      );
    }
    return value;
  }

  double _sigmoid(double z) =>
      z >= 0 ? 1 / (1 + exp(-z)) : exp(z) / (1 + exp(z));

  /// One full-batch update. Call between event-loop yields for interactive use.
  /// A rejected update preserves the last finite parameters and history.
  bool step() {
    final x = _x;
    if (x == null) throw StateError('Start training first.');
    if (completedIterations >= iterations) return false;
    final gradient = List.filled(_weights.length, 0.0);
    var biasGradient = 0.0;
    for (var i = 0; i < x.length; i++) {
      final z = _score(x[i]);
      final error = (logistic ? _sigmoid(z) : z) - _y[i];
      biasGradient += error;
      for (var j = 0; j < gradient.length; j++) {
        gradient[j] += error * x[i][j];
      }
    }
    final weights = List.generate(
      gradient.length,
      (j) => _weights[j] - learningRate * gradient[j] / x.length,
    );
    final bias = _bias - learningRate * biasGradient / x.length;
    var cost = 0.0;
    for (var i = 0; i < x.length; i++) {
      final z = _scoreWith(x[i], weights, bias);
      // Stable binary cross entropy on logits; linear objective is MSE/2.
      cost += logistic
          ? max(z, 0) - z * _y[i] + log(1 + exp(-z.abs()))
          : pow(z - _y[i], 2) / 2;
    }
    cost /= x.length;
    if (!cost.isFinite) {
      throw StateError('Training diverged. Lower learning rate.');
    }
    _weights = weights;
    _bias = bias;
    _history.add(cost);
    return true;
  }

  @override
  void fit(Matrix x, List<double> y) {
    start(x, y);
    while (step()) {}
  }

  List<double> rawPredictions(Matrix x) {
    if (_x == null) throw StateError('Fit the model first.');
    validateMatrix(x, columns: _weights.length);
    return x.map((r) {
      final z = _score(r);
      return logistic ? _sigmoid(z) : z;
    }).toList();
  }

  @override
  List<double> predict(Matrix x) => rawPredictions(
    x,
  ).map((p) => logistic ? (p >= .5 ? 1.0 : 0.0) : p).toList();
}
