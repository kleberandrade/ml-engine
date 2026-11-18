import '../data/matrix.dart';

/// Common supervised fit/predict contract used by pipelines and validation.
///
/// Rows are samples and columns are features. Implementations define the target
/// label domain and fitting lifecycle; inspect each model for atomicity guarantees.
/// K-means is unsupervised and deliberately does not implement this interface.
abstract interface class Estimator {
  /// Learns from finite rectangular [x] and one aligned finite target in [y].
  ///
  /// Invalid shapes/labels generally throw [ArgumentError]. Fitting is synchronous;
  /// large workloads should run outside the UI isolate. Failed-fit state behavior
  /// is model-specific: this interface does not promise transactional rollback.
  void fit(Matrix x, List<double> y);

  /// Returns one prediction per row of [x], preserving input order.
  ///
  /// Regression returns numeric estimates; classification returns numeric labels,
  /// not probabilities. Requires a started/fitted model and the training feature
  /// width. Throws [StateError] before initialization and [ArgumentError] for
  /// invalid query shapes/values; numerical failures are model-specific.
  List<double> predict(Matrix x);
}
