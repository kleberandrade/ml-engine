import 'dart:math';

import '../data/dataset.dart';
import '../data/matrix.dart';
import 'estimator.dart';

/// An immutable fitted tree node. Split routing is x[featureIndex] <= threshold.
/// Impurity is Gini for classification and mean squared error for regression.
final class DecisionTreeNode {
  final double prediction, impurity;
  final int sampleCount;
  final int? featureIndex;
  final double? threshold;
  final DecisionTreeNode? left, right;
  const DecisionTreeNode._leaf(this.prediction, this.sampleCount, this.impurity)
    : featureIndex = null,
      threshold = null,
      left = null,
      right = null;
  const DecisionTreeNode._split(
    this.prediction,
    this.sampleCount,
    this.impurity,
    this.featureIndex,
    this.threshold,
    this.left,
    this.right,
  );
  bool get isLeaf => featureIndex == null;
  int get depth => isLeaf ? 0 : 1 + max(left!.depth, right!.depth);
  int get leafCount => isLeaf ? 1 : left!.leafCount + right!.leafCount;
}

/// Greedy binary numeric-feature classifier using weighted Gini reduction.
///
/// Finite numeric class labels are supported; tied leaf votes choose the smallest
/// label. Root depth is zero, so maxDepth=0 yields one constant leaf. Splits must
/// improve impurity by more than 1e-12 of the parent's impurity. Equal gains within
/// that tolerance favor the lowest feature index, then the lowest threshold.
/// With maxFeatures=null (default), all features are considered. An explicit
/// positive maxFeatures draws a fresh seeded subset at each eligible node; only
/// that subset is searched, with no fallback if it cannot improve impurity.
/// No missing values, categorical splits, pruning or probabilities are provided.
class DecisionTreeClassifier extends _DecisionTree {
  DecisionTreeClassifier({
    super.maxDepth = 5,
    super.minSamplesLeaf = 1,
    super.maxFeatures,
    super.seed = 42,
  }) : super(true);
}

/// Greedy binary regressor with weighted squared-error reduction and leaf means.
///
/// Shares the depth, minimum-leaf and deterministic split rules of
/// [DecisionTreeClassifier]. Thresholds are midpoints of adjacent distinct values;
/// if rounding reaches the upper value, the lower value is used instead.
/// Fit commits only a fully built tree; rejected fits preserve the previous root.
/// Fitting sorts each feature at each node; large/deep fits are synchronous and
/// need a worker/isolate. Prediction takes O(depth) time per row. No optimization
/// epochs or extrapolation trend are learned. Scaling is not required.
class DecisionTreeRegressor extends _DecisionTree {
  DecisionTreeRegressor({
    super.maxDepth = 5,
    super.minSamplesLeaf = 1,
    super.maxFeatures,
    super.seed = 42,
  }) : super(false);
}

abstract class _DecisionTree implements Estimator {
  final int maxDepth, minSamplesLeaf, seed;
  final int? maxFeatures;
  final bool _classification;
  DecisionTreeNode? _root;
  int? _columns;
  _DecisionTree(
    this._classification, {
    required this.maxDepth,
    required this.minSamplesLeaf,
    required this.maxFeatures,
    required this.seed,
  }) {
    if (maxDepth < 0 ||
        minSamplesLeaf < 1 ||
        (maxFeatures != null && maxFeatures! < 1)) {
      throw ArgumentError(
        'Require maxDepth >= 0, minSamplesLeaf >= 1 and positive maxFeatures.',
      );
    }
  }
  DecisionTreeNode get root =>
      _root ?? (throw StateError('Fit the model first.'));
  int get depth => root.depth;
  int get leafCount => root.leafCount;

  @override
  void fit(Matrix x, List<double> y) {
    final data = Dataset(x, y);
    if (maxFeatures != null && maxFeatures! > data.x.first.length) {
      throw ArgumentError('maxFeatures exceeds feature count.');
    }
    final candidate = _build(
      data,
      List.generate(x.length, (i) => i),
      0,
      Random(seed),
    );
    _root = candidate;
    _columns = x.first.length;
  }

  double _prediction(List<double> targets) {
    if (!_classification) {
      final mean = targets.fold(0.0, (s, v) => s + v / targets.length);
      if (!mean.isFinite) {
        throw ArgumentError('Tree mean overflow. Rescale targets.');
      }
      return mean;
    }
    final counts = <double, int>{};
    for (final v in targets) {
      counts.update(v, (n) => n + 1, ifAbsent: () => 1);
    }
    return counts.keys.reduce(
      (a, b) =>
          counts[a]! > counts[b]! || (counts[a] == counts[b] && a < b) ? a : b,
    );
  }

  // Prefix/suffix total losses allow O(n) candidate scoring after feature sort.
  // Regression uses Welford moments, avoiding E[y²]-E[y]² cancellation.
  List<double> _losses(List<int> rows, List<double> y, {bool reverse = false}) {
    final result = List.filled(rows.length + 1, 0.0), counts = <double, int>{};
    var squaredCounts = 0.0, mean = 0.0, m2 = 0.0;
    for (var i = 0; i < rows.length; i++) {
      final count = i + 1,
          at = reverse ? rows.length - 1 - i : i,
          v = y[rows[at]];
      double loss;
      if (_classification) {
        final old = counts[v] ?? 0;
        counts[v] = old + 1;
        squaredCounts += 2 * old + 1;
        loss = count - squaredCounts / count;
      } else {
        final delta = v - mean;
        mean += delta / count;
        m2 += delta * (v - mean);
        loss = m2;
      }
      if (!loss.isFinite || !mean.isFinite) {
        throw ArgumentError('Tree impurity overflow. Rescale targets.');
      }
      result[reverse ? at : count] = max(0.0, loss);
    }
    return result;
  }

  DecisionTreeNode _build(
    Dataset data,
    List<int> rows,
    int level,
    Random random,
  ) {
    final n = rows.length,
        prediction = _prediction(rows.map((i) => data.y[i]).toList());
    final impurity = _losses(rows, data.y).last / n;
    if (level >= maxDepth || n < 2 * minSamplesLeaf || impurity == 0) {
      return DecisionTreeNode._leaf(prediction, n, impurity);
    }
    var best = impurity;
    final tolerance = impurity * 1e-12;
    int? feature;
    double? threshold;
    var features = List.generate(data.x.first.length, (i) => i);
    if (maxFeatures != null && maxFeatures! < features.length) {
      features.shuffle(random);
      features = features.take(maxFeatures!).toList()..sort();
    }
    for (final j in features) {
      final sorted = List<int>.of(rows)
        ..sort((a, b) {
          final order = data.x[a][j].compareTo(data.x[b][j]);
          return order == 0 ? a.compareTo(b) : order;
        });
      final prefix = _losses(sorted, data.y),
          suffix = _losses(sorted, data.y, reverse: true);
      for (var cut = minSamplesLeaf; cut <= n - minSamplesLeaf; cut++) {
        final low = data.x[sorted[cut - 1]][j], high = data.x[sorted[cut]][j];
        if (low == high) continue;
        final score = (prefix[cut] + suffix[cut]) / n;
        if (score < best - tolerance) {
          best = score;
          feature = j;
          final midpoint = low / 2 + high / 2;
          threshold = midpoint >= high || midpoint < low ? low : midpoint;
        }
      }
    }
    if (feature == null) return DecisionTreeNode._leaf(prediction, n, impurity);
    final left = rows.where((i) => data.x[i][feature!] <= threshold!).toList();
    final right = rows.where((i) => data.x[i][feature!] > threshold!).toList();
    return DecisionTreeNode._split(
      prediction,
      n,
      impurity,
      feature,
      threshold,
      _build(data, left, level + 1, random),
      _build(data, right, level + 1, random),
    );
  }

  @override
  List<double> predict(Matrix x) {
    final tree = root;
    validateMatrix(x, columns: _columns);
    return x.map((row) {
      var node = tree;
      while (!node.isLeaf) {
        node = row[node.featureIndex!] <= node.threshold!
            ? node.left!
            : node.right!;
      }
      return node.prediction;
    }).toList();
  }
}
