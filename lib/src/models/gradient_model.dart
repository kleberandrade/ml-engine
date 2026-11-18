import 'dart:math';
import '../data/matrix.dart';
import 'estimator.dart';

/// Shared full-batch optimizer for linear, Ridge and binary logistic models.
///
/// Starts with zero coefficients/intercept. Each successful step commits finite
/// parameters and one post-update training cost. Use concrete model classes for
/// normal application code; this base also supports custom subclasses.
abstract class GradientModel implements Estimator {
  /// Positive finite multiplier applied to each averaged gradient update.
  final double learningRate;

  /// Nonnegative finite coefficient of ||weights||²/2; the intercept is excluded.
  final double l2Penalty;

  /// Maximum number of full-batch updates after each [start]; must be positive.
  final int iterations;

  /// Whether scores use sigmoid/binary cross entropy instead of linear MSE/2.
  final bool logistic;
  Matrix? _x;
  List<double> _y = [], _weights = [];
  final List<double> _history = [];
  double _bias = 0;

  /// Number of successfully committed updates in the current run; zero before start.
  int get completedIterations => _history.length;

  /// Immutable snapshot of post-update training objectives, initially empty.
  ///
  /// Linear/Ridge uses MSE/2 plus the optional L2 penalty; logistic uses mean binary
  /// cross entropy plus any penalty. The initial zero-parameter loss is not included.
  List<double> get costHistory => List.unmodifiable(_history);

  /// Immutable snapshot of feature weights in column order; empty before [start].
  List<double> get coefficients => List.unmodifiable(_weights);

  /// Current unpenalized intercept; zero before initialization and after [start].
  double get intercept => _bias;

  /// Configures a full-batch optimizer without starting training.
  ///
  /// Throws [ArgumentError] unless [learningRate] is finite/positive, [iterations]
  /// is positive and [l2Penalty] is finite/nonnegative. [logistic] requires binary
  /// targets when [start] or [fit] is called. Concrete subclasses choose the loss.
  GradientModel({
    this.l2Penalty = 0,
    required this.logistic,
    required this.learningRate,
    required this.iterations,
  }) {
    if (!l2Penalty.isFinite || l2Penalty < 0) {
      throw ArgumentError.value(
        l2Penalty,
        'l2Penalty',
        'Must be finite and nonnegative.',
      );
    }
    if (!learningRate.isFinite || learningRate <= 0 || iterations < 1) {
      throw ArgumentError(
        'Positive finite learning rate and iterations required.',
      );
    }
  }

  /// Validates and copies [x]/[y], resetting parameters and cost history to zero.
  ///
  /// Requires nonempty finite rectangular rows and one finite target per row;
  /// logistic targets must be 0/1. Throws [ArgumentError] before replacing state on
  /// invalid input. A valid start discards the previous run. Querying predictions
  /// after start but before stepping returns the initialized model's predictions.
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

  /// Performs one full-batch gradient update, returning true when committed.
  ///
  /// Returns false after [iterations] updates. Throws [StateError] before [start]
  /// or on nonfinite score/cost arithmetic. Rejected updates preserve the last
  /// finite parameters/history, not a previous training run. Scale features or
  /// lower the rate on divergence. Yield between calls for interactive use.
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
      (j) => l2Penalty == 0
          ? _weights[j] - learningRate * gradient[j] / x.length
          : _weights[j] -
                learningRate *
                    (gradient[j] / x.length + l2Penalty * _weights[j]),
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
    if (l2Penalty > 0) {
      cost += l2Penalty * weights.fold(0.0, (sum, w) => sum + w * w) / 2;
    }
    if (!cost.isFinite) {
      throw StateError('Training diverged. Lower learning rate.');
    }
    _weights = weights;
    _bias = bias;
    _history.add(cost);
    return true;
  }

  /// Starts a new run and performs up to [iterations] updates synchronously.
  ///
  /// Invalid input is rejected before reset. If a later update diverges, throws
  /// [StateError] and retains the last complete update of this NEW run; this method
  /// does not restore the model that existed before the call. Train a separate
  /// candidate instance before replacing an application model when rollback matters.
  @override
  void fit(Matrix x, List<double> y) {
    start(x, y);
    while (step()) {}
  }

  /// Returns continuous estimates for linear models or sigmoid probabilities for logistic.
  ///
  /// Despite this method's name, logistic results are probabilities, NOT logits.
  /// Throws [StateError] before [start]/[fit], [ArgumentError] for invalid query
  /// shape/values, and [StateError] if numeric score arithmetic overflows.
  /// Returns a new list in input row order without changing training state.
  List<double> rawPredictions(Matrix x) {
    if (_x == null) throw StateError('Fit the model first.');
    validateMatrix(x, columns: _weights.length);
    return x.map((r) {
      final z = _score(r);
      return logistic ? _sigmoid(z) : z;
    }).toList();
  }

  /// Predicts continuous targets or thresholded binary labels, preserving row order.
  ///
  /// Logistic probabilities >= .5 become label 1; other probabilities become 0.
  /// Uses [rawPredictions] validation, initialization and numerical failure rules.
  @override
  List<double> predict(Matrix x) => rawPredictions(
    x,
  ).map((p) => logistic ? (p >= .5 ? 1.0 : 0.0) : p).toList();
}
