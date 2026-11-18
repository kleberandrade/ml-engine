import '../data/matrix.dart';

/// A stateful preprocessing component with separate learning and application.
///
/// Fit only on training rows; apply the same fitted instance to held-out rows.
/// Reusing fitted components across validation folds leaks information.
abstract interface class Transformer {
  /// Learns transformation statistics from finite rectangular training [x].
  ///
  /// Throws [ArgumentError] for invalid input. Concrete transformers specify
  /// whether a failed refit preserves their previous statistics.
  void fit(Matrix x);

  /// Applies learned statistics and returns a new matrix in the same row order.
  ///
  /// Does not refit statistics. Throws [StateError] before fitting and
  /// [ArgumentError] for empty, wrong-width or nonfinite input/output values.
  Matrix transform(Matrix x);
}
