import 'dart:math';

/// Immutable row-index lists for train, validation and final-test partitions.
class DataSplit {
  /// Indices used to fit preprocessing and model parameters.
  final List<int> train;

  /// Indices reserved for selecting models and hyperparameters.
  final List<int> validation;

  /// Indices reserved for final evaluation after model selection.
  final List<int> test;

  /// Copies the three index lists without validating them.
  ///
  /// Use [trainValidationTestSplit] for nonempty, disjoint, exhaustive partitions.
  /// Lists supplied directly may contain invalid or overlapping indices.
  DataSplit(List<int> train, List<int> validation, List<int> test)
    : train = List.unmodifiable(train),
      validation = List.unmodifiable(validation),
      test = List.unmodifiable(test);
}

/// Shuffles [n] row indices with [seed] and partitions train/validation/test.
///
/// Train and validation sizes are floor(n * their fraction); test gets the
/// remainder. Defaults are .6/.2/.2. Throws [ArgumentError] for n < 3, nonfinite or
/// nonpositive fractions, a train+validation sum >= 1, or any empty partition.
/// Returns copied immutable lists. This is not stratified or group/time aware;
/// seed reproduction assumes the same SDK and input row order.
DataSplit trainValidationTestSplit(
  int n, {
  double trainFraction = .6,
  double validationFraction = .2,
  int seed = 42,
}) {
  if (n < 3 ||
      !trainFraction.isFinite ||
      !validationFraction.isFinite ||
      trainFraction <= 0 ||
      validationFraction <= 0 ||
      trainFraction + validationFraction >= 1) {
    throw ArgumentError(
      'Require >=3 rows and positive train/validation/test fractions.',
    );
  }
  final nt = (n * trainFraction).floor(), nv = (n * validationFraction).floor();
  if (nt == 0 || nv == 0 || nt + nv >= n) {
    throw ArgumentError('Split leaves an empty partition.');
  }
  final indices = List.generate(n, (i) => i)..shuffle(Random(seed));
  return DataSplit(
    indices.sublist(0, nt),
    indices.sublist(nt, nt + nv),
    indices.sublist(nt + nv),
  );
}
