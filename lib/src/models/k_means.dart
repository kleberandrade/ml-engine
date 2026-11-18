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

/// Euclidean K-means++ initialization followed by Lloyd centroid updates.
///
/// Cluster identifiers are zero-based centroid indices, not semantic labels.
/// Fit accepts features only; use scaling when feature magnitudes differ.
/// Empty clusters retain their old centers. Initialization is seeded within the
/// same Dart SDK. Fitting is synchronous; [start]/[step] expose bounded updates.
class KMeans {
  /// Requested positive cluster count; cannot exceed distinct training locations.
  final int k;

  /// Pseudorandom initialization seed; not a cross-SDK reproducibility promise.
  final int seed;

  /// Maximum positive Lloyd-update budget; fitting may converge earlier.
  final int iterations;
  Matrix? _x;
  Matrix _centroids = [];
  final List<double> _history = [];
  bool _done = false;

  /// Deeply immutable snapshot of current centers; empty before [start].
  Matrix get centroids =>
      List.unmodifiable(_centroids.map((r) => List<double>.unmodifiable(r)));

  /// Immutable snapshot of post-update training inertia; empty until the first step.
  List<double> get costHistory => List.unmodifiable(_history);

  /// Sum of squared distances to the closest current center after the latest step.
  ///
  /// Throws [StateError] until at least one update completes, including immediately
  /// after [start]. This is total training inertia, not mean held-out distance.
  double get inertia {
    if (_history.isEmpty) throw StateError('Fit first.');
    return _history.last;
  }

  /// Creates an unfitted clustering model.
  ///
  /// Throws [ArgumentError] when [k] or [iterations] is not positive. Distinct-row
  /// and numeric magnitude restrictions are checked by [start], not construction.
  KMeans({this.k = 3, this.seed = 42, this.iterations = 100}) {
    if (k < 1 || iterations < 1) {
      throw ArgumentError('Positive k and iterations required.');
    }
  }
  int _nearest(List<double> row) => _nearestIn(row, _centroids);

  int _nearestIn(List<double> row, Matrix centers) {
    var best = 0;
    for (var j = 1; j < centers.length; j++) {
      if (_distance(row, centers[j]) < _distance(row, centers[best])) {
        best = j;
      }
    }
    return best;
  }

  /// Copies training [x] and initializes [k] centers with K-means++.
  ///
  /// Requires finite nonempty rectangular rows and at least [k] distinct points.
  /// Throws [ArgumentError] on invalid input or degenerate/overflowing distances.
  /// Rejection preserves the previous run; success replaces centers and clears
  /// history. First center is uniform; later centers use squared-distance weights.
  void start(Matrix x) {
    validateMatrix(x);
    if (x.map((r) => r.join(',')).toSet().length < k) {
      throw ArgumentError('k exceeds distinct points.');
    }
    final random = Random(seed);
    final centers = <List<double>>[List.of(x[random.nextInt(x.length)])];
    while (centers.length < k) {
      final weights = x
          .map((r) => centers.map((c) => _distance(r, c)).reduce(min))
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
      centers.add(List.of(x[selected]));
    }
    _x = x.map((r) => List<double>.of(r)).toList();
    _centroids = centers;
    _history.clear();
    _done = false;
  }

  /// Performs one Lloyd assignment/centroid update; returns true on commit.
  ///
  /// Returns false after the budget or convergence (maximum squared center
  /// movement <= 1e-16). Throws [StateError] before [start] or for nonfinite
  /// total cost; distance overflow throws [ArgumentError]. A rejected update
  /// preserves the previous centers/history. Empty clusters keep their centers.
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
    final cost = x.fold(
      0.0,
      (s, r) => s + _distance(r, next[_nearestIn(r, next)]),
    );
    if (!cost.isFinite) throw StateError('Clustering overflow.');
    _centroids = next;
    _history.add(cost);
    _done = shift <= 1e-16;
    return true;
  }

  /// Initializes and runs Lloyd updates until convergence or the iteration limit.
  ///
  /// Exceptions from [start]/[step] propagate. A valid start resets the old run;
  /// if a later step fails, initialized/last-complete NEW state remains rather than
  /// rolling back the previous fit. Use a separate candidate for transactional replacement.
  void fit(Matrix x) {
    start(x);
    while (step()) {}
  }

  /// Assigns each finite query row to its nearest center, returning indices 0..k-1.
  ///
  /// Works immediately after [start]; no update is required. Equal distances prefer
  /// the lower centroid index. Throws [StateError] before initialization and
  /// [ArgumentError] for invalid feature shape/values or squared-distance overflow.
  /// Does not update centroids or history.
  List<int> predict(Matrix x) {
    if (_x == null) throw StateError('Fit first.');
    validateMatrix(x, columns: _centroids.first.length);
    return x.map(_nearest).toList();
  }
}
