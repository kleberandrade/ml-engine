void validateMetricVectors(List<double> y, List<double> predicted) {
  if (y.isEmpty ||
      y.length != predicted.length ||
      [...y, ...predicted].any((v) => !v.isFinite)) {
    throw ArgumentError('Expected matching nonempty finite vectors.');
  }
}
