import 'dart:math';
import '../data/matrix.dart';

double _distance(List<double> a, List<double> b) {
  var sum = 0.0;
  for (var j = 0; j < a.length; j++) {
    sum += pow(a[j] - b[j], 2);
  }
  if (!sum.isFinite) {
    throw ArgumentError('Distance overflow. Scale input magnitudes.');
  }
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
    if (k < 1 || iterations < 1) {
      throw ArgumentError('Positive k and iterations required.');
    }
  }
  int _nearest(List<double> row) {
    var best = 0;
    for (var j = 1; j < _centroids.length; j++) {
      if (_distance(row, _centroids[j]) < _distance(row, _centroids[best])) {
        best = j;
      }
    }
    return best;
  }

  void start(Matrix x) {
    validateMatrix(x);
    if (x.map((r) => r.join(',')).toSet().length < k) {
      throw ArgumentError('k exceeds distinct points.');
    }
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
      if (!total.isFinite || total <= 0) {
        throw ArgumentError('Degenerate k-means++ distances.');
      }
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
