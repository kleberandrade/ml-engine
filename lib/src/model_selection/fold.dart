import 'dart:math';

/// Immutable row-index lists defining one training/held-out partition.
class Fold {
  /// Indices used to fit preprocessing and the estimator.
  final List<int> train;

  /// Held-out indices passed only to prediction and scoring.
  final List<int> test;

  /// Copies [train] and [test] into unmodifiable lists.
  ///
  /// Does not validate indices or disjointness. `crossValidate` checks nonempty,
  /// unique, disjoint, in-range rows when using a fold.
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

/// Creates [k] seeded shuffled folds over row indices 0..[n]-1.
///
/// Each row is held out exactly once; held-out sizes differ by at most one and
/// training is the complement. Throws [ArgumentError] unless 2 <= [k] <= [n].
/// This assumes independent rows, not temporal/grouped data. Seed reproduction is
/// within the same Dart SDK, not a cross-version random-algorithm guarantee.
List<Fold> kFold(int n, {int k = 5, int seed = 42}) {
  if (k < 2 || n < k) throw ArgumentError('Require 2 <= k <= rows.');
  final indices = List.generate(n, (i) => i)..shuffle(Random(seed));
  final buckets = List.generate(k, (_) => <int>[]);
  for (var i = 0; i < n; i++) {
    buckets[i % k].add(indices[i]);
  }
  return _folds(buckets, n);
}

/// Creates [k] seeded folds preserving per-class proportions where possible.
///
/// [labels] contains one integer class identifier per source row; arbitrary
/// integer classes are supported. Every row is held out once and training is
/// the complement. Throws [ArgumentError] if [k] < 2, there are fewer than [k]
/// rows, or any class has fewer than [k] examples. Seed reproduction assumes
/// the same label order and Dart SDK. Does not handle grouped/time-series data.
List<Fold> stratifiedKFold(List<int> labels, {int k = 5, int seed = 42}) {
  if (k < 2 || labels.length < k) throw ArgumentError('Invalid k.');
  final groups = <int, List<int>>{};
  for (var i = 0; i < labels.length; i++) {
    (groups[labels[i]] ??= []).add(i);
  }
  if (groups.values.any((g) => g.length < k)) {
    throw ArgumentError('Each class needs at least k rows.');
  }
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
