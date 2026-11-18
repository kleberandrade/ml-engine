/// Requires nonempty, equal-length finite target and prediction vectors.
///
/// Throws [ArgumentError] on violation. This helper neither thresholds values nor
/// checks binary labels; callers impose metric-specific restrictions.
void validateMetricVectors(List<double> y, List<double> predicted) {
  if (y.isEmpty ||
      y.length != predicted.length ||
      [...y, ...predicted].any((v) => !v.isFinite)) {
    throw ArgumentError('Expected matching nonempty finite vectors.');
  }
}
