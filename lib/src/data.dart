import 'dart:math';

typedef Matrix = List<List<double>>;

int validateMatrix(Matrix x, {int? columns}) {
  if (x.isEmpty || x.first.isEmpty)
    throw ArgumentError('Expected a nonempty matrix.');
  final width = columns ?? x.first.length;
  if (x.any((r) => r.length != width || r.any((v) => !v.isFinite))) {
    throw ArgumentError('Rows must have $width finite values.');
  }
  return width;
}

void validateTargets(Matrix x, List<double> y) {
  validateMatrix(x);
  if (x.length != y.length || y.any((v) => !v.isFinite)) {
    throw ArgumentError('Expected one finite target per row.');
  }
}

class Dataset {
  final Matrix x;
  final List<double> y;
  Dataset(Matrix x, List<double> y)
    : x = List.unmodifiable(x.map((r) => List<double>.unmodifiable(r))),
      y = List.unmodifiable(y) {
    validateTargets(x, y);
  }
}

/// Strict numeric CSV: no quoted fields; header x1,x2,y, 2..500 rows.
Dataset parseCsv(String input, {int maxRows = 500}) {
  final lines = input.trim().split(RegExp(r'\r?\n'));
  if (lines.first.trim() != 'x1,x2,y' ||
      lines.length < 3 ||
      lines.length > maxRows + 1) {
    throw const FormatException('Use header x1,x2,y and 2–500 numeric rows.');
  }
  final x = <List<double>>[];
  final y = <double>[];
  for (var i = 1; i < lines.length; i++) {
    final values = lines[i]
        .split(',')
        .map((s) => double.tryParse(s.trim()))
        .toList();
    if (values.length != 3 || values.any((v) => v == null || !v.isFinite)) {
      throw FormatException('Row ${i + 1}: expected three finite numbers.');
    }
    x.add([values[0]!, values[1]!]);
    y.add(values[2]!);
  }
  return Dataset(x, y);
}

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
  if (nt == 0 || nv == 0 || nt + nv >= n)
    throw ArgumentError('Split leaves an empty partition.');
  final indices = List.generate(n, (i) => i)..shuffle(Random(seed));
  return DataSplit(
    indices.sublist(0, nt),
    indices.sublist(nt, nt + nv),
    indices.sublist(nt + nv),
  );
}

class Fold {
  final List<int> train, test;
  Fold(List<int> train, List<int> test)
    : train = List.unmodifiable(train),
      test = List.unmodifiable(test);
}

List<Fold> _folds(List<List<int>> buckets, int n) => buckets.map((test) {
  final held = test.toSet();
  return Fold(
    List.generate(n, (i) => i).where((i) => !held.contains(i)).toList(),
    test,
  );
}).toList();

List<Fold> kFold(int n, {int k = 5, int seed = 42}) {
  if (k < 2 || n < k) throw ArgumentError('Require 2 <= k <= rows.');
  final indices = List.generate(n, (i) => i)..shuffle(Random(seed));
  final buckets = List.generate(k, (_) => <int>[]);
  for (var i = 0; i < n; i++) {
    buckets[i % k].add(indices[i]);
  }
  return _folds(buckets, n);
}

/// Every class must have at least k examples; no silent invalid folds.
List<Fold> stratifiedKFold(List<int> labels, {int k = 5, int seed = 42}) {
  if (k < 2 || labels.length < k) throw ArgumentError('Invalid k.');
  final groups = <int, List<int>>{};
  for (var i = 0; i < labels.length; i++) {
    (groups[labels[i]] ??= []).add(i);
  }
  if (groups.values.any((g) => g.length < k))
    throw ArgumentError('Each class needs at least k rows.');
  final buckets = List.generate(k, (_) => <int>[]), random = Random(seed);
  var offset = 0;
  for (final group in groups.values) {
    group.shuffle(random);
    for (var i = 0; i < group.length; i++) {
      buckets[(i + offset) % k].add(group[i]);
    }
    offset = (offset + group.length) % k;
  }
  return _folds(buckets, labels.length);
}
