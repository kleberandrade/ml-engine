import 'dart:math';

class DataSplit {
  final List<int> train, validation, test;
  DataSplit(List<int> train, List<int> validation, List<int> test)
    : train = List.unmodifiable(train),
      validation = List.unmodifiable(validation),
      test = List.unmodifiable(test);
}

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
