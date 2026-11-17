import 'dart:math';

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
