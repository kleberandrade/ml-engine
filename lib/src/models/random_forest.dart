import 'dart:math';

import '../data/dataset.dart';
import '../data/matrix.dart';
import 'decision_tree.dart';
import 'estimator.dart';

/// Seeded bootstrap forest with uniform hard votes over numeric class labels.
///
/// Each tree draws n training rows with replacement and samples maxFeatures
/// variables WITHOUT replacement at each eligible node. Null maxFeatures uses
/// max(1,floor(sqrt(featureCount))) for both forest tasks. Class-vote ties choose
/// the smallest label. This is hard voting, not averaged leaf probabilities.
/// Duplicate bootstrap entries each count toward minSamplesLeaf. No OOB score,
/// feature importance, pruning, missing/categorical handling or probabilities.
class RandomForestClassifier extends _RandomForest {
  /// Creates an unfitted bootstrap forest.
  ///
  /// [nEstimators] and [minSamplesLeaf] must be positive, [maxDepth] nonnegative,
  /// and an explicit [maxFeatures] positive; invalid settings throw [ArgumentError].
  /// [fit] checks maxFeatures <= feature width. Null uses max(1,floor(sqrt(width)))
  /// for both tasks. [seed] controls bootstrap bags and per-tree feature seeds.
  RandomForestClassifier({
    super.nEstimators = 100,
    super.maxDepth = 5,
    super.minSamplesLeaf = 1,
    super.maxFeatures,
    super.seed = 42,
  }) : super(true);
}

/// Seeded bootstrap forest averaging the predictions of its regression trees.
///
/// Shares sampling/stopping rules with [RandomForestClassifier]. Immutable fitted
/// roots, bootstrapIndices and treeSeeds are available for inspection. Indices
/// retain O(n*nEstimators) integers, but raw input rows are not retained. Fit is
/// synchronous and commits only a complete forest; failures preserve old state.
/// Prediction costs O(nEstimators*depth) per row. No parallel fitting or automatic
/// hyperparameter selection is performed. Seeds reproduce within the same SDK;
/// the Dart Random algorithm is not promised to remain fixed across versions.
class RandomForestRegressor extends _RandomForest {
  /// Creates an unfitted bootstrap forest.
  ///
  /// [nEstimators] and [minSamplesLeaf] must be positive, [maxDepth] nonnegative,
  /// and an explicit [maxFeatures] positive; invalid settings throw [ArgumentError].
  /// [fit] checks maxFeatures <= feature width. Null uses max(1,floor(sqrt(width)))
  /// for both tasks. [seed] controls bootstrap bags and per-tree feature seeds.
  RandomForestRegressor({
    super.nEstimators = 100,
    super.maxDepth = 5,
    super.minSamplesLeaf = 1,
    super.maxFeatures,
    super.seed = 42,
  }) : super(false);
}

abstract class _RandomForest implements Estimator {
  /// Positive number of independently bootstrapped trees to build on each fit.
  final int nEstimators;

  /// Maximum root-to-leaf edges per tree; zero creates constant trees.
  final int maxDepth;

  /// Minimum bootstrap entries in each split child; duplicates count separately.
  /// An unsplit root with fewer rows is still allowed.
  final int minSamplesLeaf;

  /// Seed for bootstrap draws and per-tree feature-subset seeds.
  final int seed;

  /// Per-split feature count; null resolves to max(1,floor(sqrt(fitted width))).
  final int? maxFeatures;
  final bool _classification;
  List<DecisionTreeNode>? _trees;
  List<List<int>> _bootstrapIndices = const [];
  List<int> _treeSeeds = const [];
  int? _columns, _featuresPerSplit;
  _RandomForest(
    this._classification, {
    required this.nEstimators,
    required this.maxDepth,
    required this.minSamplesLeaf,
    required this.maxFeatures,
    required this.seed,
  }) {
    if (nEstimators < 1 ||
        maxDepth < 0 ||
        minSamplesLeaf < 1 ||
        (maxFeatures != null && maxFeatures! < 1)) {
      throw ArgumentError(
        'Require positive tree/leaf/feature counts and nonnegative depth.',
      );
    }
  }

  /// Immutable fitted roots in construction order; throws [StateError] before fit.
  List<DecisionTreeNode> get trees =>
      _trees ?? (throw StateError('Fit the forest first.'));

  /// Deeply immutable bootstrap source-row indices for each fitted tree.
  ///
  /// Each inner list has training-row-count entries, with replacement. Indices
  /// refer to the rows passed to the most recent successful fit. Retaining these
  /// indices costs O(n*nEstimators) integers. Throws [StateError] before fit.
  List<List<int>> get bootstrapIndices {
    trees;
    return _bootstrapIndices;
  }

  /// Immutable per-tree feature-sampling seeds aligned with [trees].
  ///
  /// Together with [bootstrapIndices] and the original training data, these permit
  /// reconstructing a tree within the same SDK. Throws [StateError] before fit.
  List<int> get treeSeeds {
    trees;
    return _treeSeeds;
  }

  /// Resolved feature subset size of the fitted forest; throws [StateError] before fit.
  int get featuresPerSplit {
    trees;
    return _featuresPerSplit!;
  }

  /// Largest actual depth among fitted trees; throws [StateError] before fit.
  int get depth => trees.map((t) => t.depth).reduce(max);

  /// Sum of terminal leaf counts across fitted trees; throws [StateError] before fit.
  int get leafCount => trees.fold(0, (sum, t) => sum + t.leafCount);

  /// Builds all bootstrap trees before committing roots and sampling metadata.
  ///
  /// Requires finite nonempty rectangular [x], aligned finite [y], and any explicit
  /// maxFeatures <= width. Throws [ArgumentError] for invalid data or overflowing
  /// tree arithmetic. Class labels may be any finite numeric value. Rejected fits
  /// preserve every previously fitted field. Raw rows are not retained afterward;
  /// roots, bag indices and seeds are retained. This operation is synchronous.
  @override
  void fit(Matrix x, List<double> y) {
    final data = Dataset(x, y), width = x.first.length;
    final m = maxFeatures ?? max(1, sqrt(width).floor());
    if (m > width) throw ArgumentError('maxFeatures exceeds feature count.');
    final random = Random(seed),
        roots = <DecisionTreeNode>[],
        bags = <List<int>>[],
        seeds = <int>[];
    for (var i = 0; i < nEstimators; i++) {
      final indices = List.generate(
        data.x.length,
        (_) => random.nextInt(data.x.length),
      );
      final treeSeed = random.nextInt(0x7fffffff);
      final rows = indices.map((i) => data.x[i]).toList(),
          targets = indices.map((i) => data.y[i]).toList();
      final DecisionTreeNode root;
      if (_classification) {
        root = (DecisionTreeClassifier(
          maxDepth: maxDepth,
          minSamplesLeaf: minSamplesLeaf,
          maxFeatures: m,
          seed: treeSeed,
        )..fit(rows, targets)).root;
      } else {
        root = (DecisionTreeRegressor(
          maxDepth: maxDepth,
          minSamplesLeaf: minSamplesLeaf,
          maxFeatures: m,
          seed: treeSeed,
        )..fit(rows, targets)).root;
      }
      roots.add(root);
      bags.add(List<int>.unmodifiable(indices));
      seeds.add(treeSeed);
    }
    // Install all fitted state together; nothing is committed on a partial failure.
    _trees = List.unmodifiable(roots);
    _bootstrapIndices = List.unmodifiable(bags);
    _treeSeeds = List.unmodifiable(seeds);
    _columns = width;
    _featuresPerSplit = m;
  }

  /// Aggregates fitted tree predictions in input row order.
  ///
  /// Classification uses equal hard votes with smallest-numeric-label ties;
  /// regression uses the simple mean. Throws [StateError] before fit or if the
  /// regression mean overflows, and [ArgumentError] for invalid query shape/values.
  /// Returns a new list without modifying fitted trees. Votes are not probabilities.
  @override
  List<double> predict(Matrix x) {
    final roots = trees;
    validateMatrix(x, columns: _columns);
    return x.map((row) {
      final values = roots.map((tree) {
        var node = tree;
        while (!node.isLeaf) {
          node = row[node.featureIndex!] <= node.threshold!
              ? node.left!
              : node.right!;
        }
        return node.prediction;
      }).toList();
      if (!_classification) {
        final mean = values.fold(0.0, (sum, v) => sum + v / values.length);
        if (!mean.isFinite) {
          throw StateError('Forest prediction overflow. Rescale targets.');
        }
        return mean;
      }
      final counts = <double, int>{};
      for (final v in values) {
        counts.update(v, (n) => n + 1, ifAbsent: () => 1);
      }
      return counts.keys.reduce(
        (a, b) => counts[a]! > counts[b]! || (counts[a] == counts[b] && a < b)
            ? a
            : b,
      );
    }).toList();
  }
}
