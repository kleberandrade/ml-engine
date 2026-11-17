import 'dart:math';
import 'data.dart';

abstract interface class Estimator {
  void fit(Matrix x, List<double> y);
  List<double> predict(Matrix x);
}

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
    if (!learningRate.isFinite || learningRate <= 0 || iterations < 1)
      throw ArgumentError(
        'Positive finite learning rate and iterations required.',
      );
  }
  void start(Matrix x, List<double> y) {
    validateTargets(x, y);
    if (logistic && y.any((v) => v != 0 && v != 1))
      throw ArgumentError('Binary labels must be 0 or 1.');
    _x = x.map((r) => List<double>.of(r)).toList();
    _y = List.of(y);
    _weights = List.filled(x.first.length, 0);
    _bias = 0;
    _history.clear();
  }

  double _score(List<double> row) {
    var value = _bias;
    for (var j = 0; j < row.length; j++) {
      value += row[j] * _weights[j];
    }
    if (!value.isFinite)
      throw StateError(
        'Training diverged. Lower learning rate or scale features.',
      );
    return value;
  }

  double _sigmoid(double z) =>
      z >= 0 ? 1 / (1 + exp(-z)) : exp(z) / (1 + exp(z));

  /// One full-batch update. Call between event-loop yields for interactive use.
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
    for (var j = 0; j < gradient.length; j++) {
      _weights[j] -= learningRate * gradient[j] / x.length;
    }
    _bias -= learningRate * biasGradient / x.length;
    var cost = 0.0;
    for (var i = 0; i < x.length; i++) {
      final z = _score(x[i]);
      // Stable binary cross entropy on logits; linear objective is MSE/2.
      cost += logistic
          ? max(z, 0) - z * _y[i] + log(1 + exp(-z.abs()))
          : pow(z - _y[i], 2) / 2;
    }
    cost /= x.length;
    if (!cost.isFinite)
      throw StateError('Training diverged. Lower learning rate.');
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

class LinearRegression extends GradientModel {
  LinearRegression({double learningRate = .05, int iterations = 1000})
    : super(
        logistic: false,
        learningRate: learningRate,
        iterations: iterations,
      );
}

class LogisticRegression extends GradientModel {
  LogisticRegression({double learningRate = .1, int iterations = 1000})
    : super(logistic: true, learningRate: learningRate, iterations: iterations);
  List<double> probabilities(Matrix x) => rawPredictions(x);
}

double _distance(List<double> a, List<double> b) {
  var sum = 0.0;
  for (var j = 0; j < a.length; j++) {
    sum += pow(a[j] - b[j], 2);
  }
  if (!sum.isFinite)
    throw ArgumentError('Distance overflow. Scale input magnitudes.');
  return sum;
}

class KMeans {
  final int k, seed, iterations;
  Matrix? _x;
  Matrix _centroids = [];
  final List<double> _history = [];
  bool _done = false;
  Matrix get centroids =>
      List.unmodifiable(_centroids.map((r) => List<double>.unmodifiable(r)));
  List<double> get costHistory => List.unmodifiable(_history);
  double get inertia {
    if (_history.isEmpty) throw StateError('Fit first.');
    return _history.last;
  }

  KMeans({this.k = 3, this.seed = 42, this.iterations = 100}) {
    if (k < 1 || iterations < 1)
      throw ArgumentError('Positive k and iterations required.');
  }
  int _nearest(List<double> row) {
    var best = 0;
    for (var j = 1; j < _centroids.length; j++) {
      if (_distance(row, _centroids[j]) < _distance(row, _centroids[best]))
        best = j;
    }
    return best;
  }

  void start(Matrix x) {
    validateMatrix(x);
    if (x.map((r) => r.join(',')).toSet().length < k)
      throw ArgumentError('k exceeds distinct points.');
    _x = x.map((r) => List<double>.of(r)).toList();
    _history.clear();
    _done = false;
    final random = Random(seed);
    _centroids = [List.of(x[random.nextInt(x.length)])];
    while (_centroids.length < k) {
      final weights = x
          .map((r) => _centroids.map((c) => _distance(r, c)).reduce(min))
          .toList();
      final total = weights.reduce((a, b) => a + b);
      if (!total.isFinite || total <= 0)
        throw ArgumentError('Degenerate k-means++ distances.');
      var threshold = random.nextDouble() * total;
      var selected = weights.lastIndexWhere((w) => w > 0);
      for (var i = 0; i < x.length; i++) {
        threshold -= weights[i];
        if (weights[i] > 0 && threshold < 0) {
          selected = i;
          break;
        }
      }
      _centroids.add(List.of(x[selected]));
    }
  }

  bool step() {
    final x = _x;
    if (x == null) throw StateError('Start first.');
    if (_done || _history.length >= iterations) return false;
    final sums = List.generate(k, (_) => List.filled(x.first.length, 0.0));
    final counts = List.filled(k, 0);
    for (final row in x) {
      final c = _nearest(row);
      counts[c]++;
      for (var j = 0; j < row.length; j++) {
        sums[c][j] += row[j];
      }
    }
    final next = List.generate(
      k,
      (c) => counts[c] == 0
          ? List<double>.of(_centroids[c])
          : sums[c].map((v) => v / counts[c]).toList(),
    );
    final shift = List.generate(
      k,
      (c) => _distance(next[c], _centroids[c]),
    ).reduce(max);
    _centroids = next;
    final cost = x.fold(
      0.0,
      (s, r) => s + _distance(r, _centroids[_nearest(r)]),
    );
    if (!cost.isFinite) throw StateError('Clustering overflow.');
    _history.add(cost);
    _done = shift <= 1e-16;
    return true;
  }

  void fit(Matrix x) {
    start(x);
    while (step()) {}
  }

  List<int> predict(Matrix x) {
    if (_x == null) throw StateError('Fit first.');
    validateMatrix(x, columns: _centroids.first.length);
    return x.map(_nearest).toList();
  }
}
