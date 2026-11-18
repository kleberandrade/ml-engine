import 'matrix.dart';

/// An owned, deeply immutable feature matrix and aligned target vector.
///
/// Feature count is unrestricted; the Flutter lab's two-feature limit is not a
/// core constraint. Numeric class labels and continuous targets use doubles.
class Dataset {
  /// Sample rows in original order; each row has the same positive width.
  final Matrix x;

  /// One finite target for each corresponding row of [x].
  final List<double> y;

  /// Copies [x] and [y], then validates their finite rectangular shape.
  ///
  /// Throws [ArgumentError] when either input violates [validateTargets]. Subsequent
  /// mutations of the caller's lists cannot change this dataset; writes through
  /// [x] or [y] throw [UnsupportedError].
  Dataset(Matrix x, List<double> y)
    : x = List.unmodifiable(x.map((r) => List<double>.unmodifiable(r))),
      y = List.unmodifiable(y) {
    validateTargets(x, y);
  }
}
