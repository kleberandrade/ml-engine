import 'dart:math';

import '../data/dataset.dart';
import '../data/matrix.dart';
import 'decision_tree.dart';
import 'estimator.dart';

/// First-order binary logistic gradient boosting with numeric regression trees.
///
/// F0=log(p/(1-p)), where the training positive fraction is clipped to
/// `[1e-12, 1-1e-12]`. Each stage fits y-sigmoid(F), then F += learningRate*tree.
/// All rows/features are used, without bootstrap, Newton leaf updates or line
/// search. These explicit conventions differ from many TreeBoost libraries.
/// Probabilities are sigmoid scores, not independently calibrated estimates.
/// Labels must be 0/1; probability >= .5 predicts 1. Not an XGBoost binding.
class GradientBoostingClassifier extends GradientBoostingModel {
  /// Creates an unfitted first-order boosting model.
  ///
  /// [nEstimators]/[minSamplesLeaf] must be positive, [maxDepth] nonnegative and
  /// [learningRate] finite in (0,1]; invalid settings throw [ArgumentError].
  /// No data-dependent work occurs until [start] or [fit].
  GradientBoostingClassifier({
    super.nEstimators = 100,
    super.maxDepth = 3,
    super.minSamplesLeaf = 1,
    super.learningRate = .1,
  }) : super._(true);

  /// Returns sigmoid class-1 scores for each query, without thresholding.
  ///
  /// Unlike [rawPredictions], these values are probabilities rather than logits.
  /// They are not independently calibrated and may saturate to 0 or 1. Uses
  /// [rawPredictions] initialization, matrix validation and overflow exceptions.
  List<double> probabilities(Matrix x) =>
      rawPredictions(x).map(_sigmoid).toList();
}

/// Squared-error gradient boosting: F0=mean(y); residual=y-F; F += rate*tree.
///
/// lossHistory contains the initial loss followed by one value per fitted tree:
/// MSE/2 for regression, mean binary cross entropy for classification. start/step
/// support bounded stagewise training; step returns true when a tree is added,
/// false only when the requested count is reached. No early stopping is implied.
/// Every step commits atomically; fit commits only the entire completed model.
/// Failed starts/refits preserve the prior model; failed steps preserve the last
/// successful stage. Trees and history are immutable snapshots. Training data is
/// copied and retained for stepping: O(n*d) plus tree storage. Fits sort features
/// at each node and run synchronously; large fits require an isolate/worker.
/// Prediction costs O(nEstimators*depth) per row. There is no subsampling,
/// missing/categorical routing, feature importance, pruning or histogram fitting.
class GradientBoostingRegressor extends GradientBoostingModel {
  /// Creates an unfitted first-order boosting model.
  ///
  /// [nEstimators]/[minSamplesLeaf] must be positive, [maxDepth] nonnegative and
  /// [learningRate] finite in (0,1]; invalid settings throw [ArgumentError].
  /// No data-dependent work occurs until [start] or [fit].
  GradientBoostingRegressor({
    super.nEstimators = 100,
    super.maxDepth = 3,
    super.minSamplesLeaf = 1,
    super.learningRate = .1,
  }) : super._(false);
}

double _sigmoid(double z) => z >= 0 ? 1 / (1 + exp(-z)) : exp(z) / (1 + exp(z));

/// Shared stagewise lifecycle for the two gradient boosting estimators.
abstract class GradientBoostingModel implements Estimator {
  /// Positive stage budget; each successful step adds one residual tree.
  final int nEstimators;

  /// Maximum residual-tree depth in edges; zero gives a constant correction.
  final int maxDepth;

  /// Minimum rows in each proposed tree split child; an unsplit root may be smaller.
  final int minSamplesLeaf;

  /// Finite shrinkage in (0,1], multiplying every residual-tree prediction.
  final double learningRate;
  final bool _classification;
  Dataset? _data;
  List<DecisionTreeNode> _trees = const [];
  List<double> _scores = const [], _history = const [];
  double? _initial;
  GradientBoostingModel._(
    this._classification, {
    required this.nEstimators,
    required this.maxDepth,
    required this.minSamplesLeaf,
    required this.learningRate,
  }) {
    if (nEstimators < 1 ||
        maxDepth < 0 ||
        minSamplesLeaf < 1 ||
        !learningRate.isFinite ||
        learningRate <= 0 ||
        learningRate > 1) {
      throw ArgumentError(
        'Require trees/leaf size >= 1, depth >= 0, rate in (0,1].',
      );
    }
  }
  Dataset get _training =>
      _data ?? (throw StateError('Start or fit the model first.'));

  /// Immutable snapshot of residual trees in stage order.
  ///
  /// Empty immediately after [start]; throws [StateError] before initialization.
  /// Trees predict numeric residuals even in the classifier, never class votes.
  List<DecisionTreeNode> get trees {
    _training;
    return _trees;
  }

  /// Immutable snapshot of training loss, including the initial loss at index zero.
  ///
  /// After t successful stages, length is t+1. Regression uses MSE/2;
  /// classification uses mean binary cross entropy. Throws [StateError] before
  /// initialization. Previously returned snapshots do not change after stepping.
  List<double> get lossHistory {
    _training;
    return _history;
  }

  /// Initial mean target for regression or clipped prior log odds for classification.
  ///
  /// Does not change during stepping. Throws [StateError] before initialization.
  /// For classification, the training positive fraction is clipped to
  /// `[1e-12, 1-1e-12]` before applying natural-log odds.
  double get initialPrediction {
    _training;
    return _initial!;
  }

  /// Largest current residual-tree depth, zero with no trees; requires initialization.
  int get depth => trees.fold(0, (d, t) => max(d, t.depth));

  /// Total current residual-tree leaves, zero with no trees; requires initialization.
  int get leafCount => trees.fold(0, (n, t) => n + t.leafCount);

  /// Owns validated [x]/[y] and initializes a constant model and baseline loss.
  ///
  /// Requires a finite nonempty rectangular matrix and one finite target per row;
  /// classification additionally requires 0/1 targets. Throws [ArgumentError] on
  /// invalid input or nonfinite initialization/loss arithmetic, preserving the
  /// old model. Success clears trees and retains copied data for later steps.
  /// Predictions and history are immediately available before the first tree.
  void start(Matrix x, List<double> y) {
    final data = Dataset(x, y);
    if (_classification && data.y.any((v) => v != 0 && v != 1)) {
      throw ArgumentError(
        'Gradient boosting classification requires labels 0/1.',
      );
    }
    final mean = data.y.fold(0.0, (s, v) => s + v / data.y.length);
    final p = mean.clamp(1e-12, 1 - 1e-12);
    final initial = _classification ? log(p / (1 - p)) : mean;
    if (!initial.isFinite) {
      throw ArgumentError('Initial prediction overflow. Rescale targets.');
    }
    final scores = List<double>.filled(data.y.length, initial);
    final loss = _loss(scores, data.y);
    _data = data;
    _initial = initial;
    _scores = scores;
    _trees = const [];
    _history = List.unmodifiable([loss]);
  }

  double _loss(List<double> scores, List<double> y) {
    var total = 0.0;
    for (var i = 0; i < y.length; i++) {
      final z = scores[i], error = z - y[i];
      final loss = _classification
          ? max(z, 0) - z * y[i] + log(1 + exp(-z.abs()))
          : (error / 2) * error;
      total += loss / y.length;
    }
    if (!total.isFinite) {
      throw ArgumentError('Boosting loss overflow. Rescale targets.');
    }
    return total;
  }

  /// Fits one residual regression tree and commits a finite new score/loss state.
  ///
  /// Returns true after adding a tree, false when [nEstimators] is reached. Throws
  /// [StateError] before [start]/[fit] and [ArgumentError] for invalid/nonfinite
  /// residual-tree or score/loss arithmetic. Failure preserves the previous stage.
  /// Uses all training rows/features with fixed shrinkage; no early stopping or
  /// Newton leaf correction is performed, including when a correction is zero.
  bool step() {
    final data = _training;
    if (_trees.length >= nEstimators) return false;
    final residuals = List.generate(
      data.y.length,
      (i) => data.y[i] - (_classification ? _sigmoid(_scores[i]) : _scores[i]),
    );
    final tree = DecisionTreeRegressor(
      maxDepth: maxDepth,
      minSamplesLeaf: minSamplesLeaf,
    )..fit(data.x, residuals);
    final correction = tree.predict(data.x);
    final scores = List.generate(
      _scores.length,
      (i) => _scores[i] + learningRate * correction[i],
    );
    if (scores.any((v) => !v.isFinite)) {
      throw ArgumentError('Boosting score overflow. Rescale targets.');
    }
    final loss = _loss(scores, data.y);
    _scores = scores;
    _trees = List.unmodifiable([..._trees, tree.root]);
    _history = List.unmodifiable([..._history, loss]);
    return true;
  }

  /// Fits a separate complete candidate, then atomically replaces this model.
  ///
  /// Uses [start] and [step] validation and exceptions. Any rejected fit preserves
  /// the previously fitted model, unlike the partial-new-run behavior of the linear
  /// optimizer. A successful fit has nEstimators trees and nEstimators+1 losses.
  /// Synchronous: use a worker/isolate for large workloads.
  @override
  void fit(Matrix x, List<double> y) {
    final GradientBoostingModel candidate = _classification
        ? GradientBoostingClassifier(
            nEstimators: nEstimators,
            maxDepth: maxDepth,
            minSamplesLeaf: minSamplesLeaf,
            learningRate: learningRate,
          )
        : GradientBoostingRegressor(
            nEstimators: nEstimators,
            maxDepth: maxDepth,
            minSamplesLeaf: minSamplesLeaf,
            learningRate: learningRate,
          );
    candidate.start(x, y);
    while (candidate.step()) {}
    _data = candidate._data;
    _initial = candidate._initial;
    _scores = candidate._scores;
    _trees = candidate._trees;
    _history = candidate._history;
  }

  /// Returns additive target estimates for regression or logits for classification.
  ///
  /// Computes initialPrediction + learningRate * sum(tree outputs) without
  /// thresholding. Throws [StateError] before initialization and [ArgumentError]
  /// for invalid/wrong-width query rows or nonfinite additive score arithmetic.
  /// Use `GradientBoostingClassifier.probabilities` to convert logits to sigmoid
  /// scores. This differs from `GradientModel.rawPredictions`, whose logistic
  /// output is already a probability. Returns a new list in query row order.
  List<double> rawPredictions(Matrix x) {
    final data = _training;
    validateMatrix(x, columns: data.x.first.length);
    return x.map((row) {
      var score = _initial!;
      for (final tree in _trees) {
        var node = tree;
        while (!node.isLeaf) {
          node = row[node.featureIndex!] <= node.threshold!
              ? node.left!
              : node.right!;
        }
        score += learningRate * node.prediction;
      }
      if (!score.isFinite) {
        throw ArgumentError('Boosting prediction overflow. Rescale targets.');
      }
      return score;
    }).toList();
  }

  /// Returns target estimates or binary labels in query row order.
  ///
  /// The classifier thresholds sigmoid probabilities at .5 (ties become 1).
  /// Uses [rawPredictions] input, lifecycle and overflow rules; queries do not
  /// advance training or modify fitted state.
  @override
  List<double> predict(Matrix x) => rawPredictions(
    x,
  ).map((v) => _classification ? (_sigmoid(v) >= .5 ? 1.0 : 0.0) : v).toList();
}
