import 'dart:math';
import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'bootstrap draws are reproducible, with replacement, and independently seeded per tree',
    () {
      final x = List.generate(12, (i) => [i.toDouble(), (i % 3).toDouble()]),
          y = List.generate(12, (i) => (i % 2).toDouble());
      final a = RandomForestClassifier(nEstimators: 9, seed: 7)..fit(x, y);
      final b = RandomForestClassifier(nEstimators: 9, seed: 7)..fit(x, y);
      expect(a.bootstrapIndices, b.bootstrapIndices);
      expect(a.treeSeeds, b.treeSeeds);
      expect(a.predict(x), b.predict(x));
      expect(a.trees, hasLength(9));
      expect(a.featuresPerSplit, 1);
      expect(
        a.bootstrapIndices.every(
          (bag) => bag.length == 12 && bag.every((i) => i >= 0 && i < 12),
        ),
        isTrue,
      );
      expect(a.bootstrapIndices.any((bag) => bag.toSet().length < 12), isTrue);
      expect(
        a.bootstrapIndices.map((bag) => bag.join(',')).toSet().length,
        greaterThan(1),
      );
      final c = RandomForestClassifier(nEstimators: 9, seed: 8)..fit(x, y);
      expect(c.bootstrapIndices, isNot(a.bootstrapIndices));
    },
  );
  test(
    'depth-zero regression equals the analytical mean of bootstrap target means',
    () {
      final x = <List<double>>[
            [0],
            [1],
            [2],
            [3],
          ],
          y = <double>[2, 4, 8, 10];
      final f = RandomForestRegressor(nEstimators: 7, maxDepth: 0, seed: 42)
        ..fit(x, y);
      final means = f.bootstrapIndices
          .map(
            (bag) => bag.map((i) => y[i]).reduce((a, b) => a + b) / bag.length,
          )
          .toList();
      for (var i = 0; i < means.length; i++) {
        expect(f.trees[i].prediction, closeTo(means[i], 1e-12));
      }
      final expected = means.reduce((a, b) => a + b) / means.length;
      expect(
        f.predict([
          [99],
        ]).single,
        closeTo(expected, 1e-12),
      );
      expect(f.depth, 0);
      expect(f.leafCount, 7);
    },
  );
  test(
    'classification votes on tree classes; multiclass vote ties choose the smallest label',
    () {
      final x = <List<double>>[
            [0],
            [1],
            [2],
            [3],
          ],
          y = <double>[0, 0, 1, 1];
      var foundTie = false;
      for (var seed = 0; seed < 30 && !foundTie; seed++) {
        final f = RandomForestClassifier(
          nEstimators: 2,
          maxDepth: 0,
          seed: seed,
        )..fit(x, y);
        final labels = f.trees.map((t) => t.prediction).toList();
        if (labels[0] != labels[1]) {
          expect(
            f.predict([
              [100],
            ]),
            [min(labels[0], labels[1])],
          );
          foundTie = true;
        }
      }
      expect(foundTie, isTrue);
      final pure = RandomForestClassifier(nEstimators: 3)
        ..fit(
          [
            [0],
            [1],
          ],
          [7, 7],
        );
      expect(
        pure.predict([
          [9],
        ]),
        [7],
      );
    },
  );
  test(
    'one estimator reconstructs its recorded bootstrap and feature seed, not an unbagged tree',
    () {
      final x = <List<double>>[
            [0, 0],
            [1, 2],
            [2, 1],
            [3, 3],
            [4, 2],
          ],
          y = <double>[0, 0, 1, 1, 2];
      final f = RandomForestClassifier(
        nEstimators: 1,
        maxDepth: 3,
        maxFeatures: 1,
        seed: 3,
      )..fit(x, y);
      final bag = f.bootstrapIndices.single;
      final t = DecisionTreeClassifier(
        maxDepth: 3,
        maxFeatures: 1,
        seed: f.treeSeeds.single,
      )..fit(bag.map((i) => x[i]).toList(), bag.map((i) => y[i]).toList());
      expect(f.predict(x), t.predict(x));
    },
  );
  test(
    'growing the forest preserves earlier bootstrap/tree seeds and immutable roots',
    () {
      final x = List.generate(12, (i) => [i.toDouble()]),
          y = List.generate(12, (i) => i.toDouble());
      final a = RandomForestRegressor(nEstimators: 3, seed: 17)..fit(x, y);
      final b = RandomForestRegressor(nEstimators: 5, seed: 17)..fit(x, y);
      expect(b.bootstrapIndices.take(3).toList(), a.bootstrapIndices);
      expect(b.treeSeeds.take(3).toList(), a.treeSeeds);
      expect(() => a.trees.clear(), throwsUnsupportedError);
      expect(() => a.bootstrapIndices[0][0] = 999, throwsUnsupportedError);
      expect(() => a.treeSeeds[0] = 999, throwsUnsupportedError);
    },
  );
  test(
    'depth and minimum leaves bound every tree, including duplicate bootstrap observations',
    () {
      final x = List.generate(20, (i) => [i.toDouble(), (i % 3).toDouble()]),
          y = List.generate(20, (i) => (i % 4).toDouble());
      final f = RandomForestRegressor(
        nEstimators: 5,
        maxDepth: 3,
        minSamplesLeaf: 2,
      )..fit(x, y);
      void check(DecisionTreeNode n) {
        if (n.isLeaf) {
          expect(n.sampleCount, greaterThanOrEqualTo(2));
        } else {
          check(n.left!);
          check(n.right!);
        }
      }

      for (final t in f.trees) {
        expect(t.depth, lessThanOrEqualTo(3));
        check(t);
      }
    },
  );
  test(
    'rejected fits preserve the complete forest and fitting owns source values',
    () {
      final x = <List<double>>[
            [0],
            [1],
            [2],
          ],
          y = <double>[1, 1, 1];
      final f = RandomForestRegressor(nEstimators: 3)..fit(x, y);
      final trees = f.trees, bags = f.bootstrapIndices;
      x[0][0] = 999;
      y[0] = 999;
      expect(
        f.predict([
          [0],
        ]),
        [1],
      );
      expect(
        () => f.fit(
          [
            [0],
          ],
          [double.nan],
        ),
        throwsArgumentError,
      );
      expect(f.trees, same(trees));
      expect(f.bootstrapIndices, same(bags));
      expect(
        f.predict([
          [0],
        ]),
        [1],
      );
    },
  );
  test(
    'invalid parameters, feature limits and prediction shapes fail at boundaries',
    () {
      expect(() => RandomForestClassifier(nEstimators: 0), throwsArgumentError);
      expect(() => RandomForestRegressor(maxDepth: -1), throwsArgumentError);
      expect(
        () => RandomForestRegressor(minSamplesLeaf: 0),
        throwsArgumentError,
      );
      expect(() => RandomForestClassifier(maxFeatures: 0), throwsArgumentError);
      final f = RandomForestClassifier(nEstimators: 2, maxFeatures: 2);
      expect(
        () => f.predict([
          [0, 0],
        ]),
        throwsStateError,
      );
      expect(
        () => f.fit(
          [
            [0],
          ],
          [1],
        ),
        throwsArgumentError,
      );
      f.fit(
        [
          [0, 0],
          [1, 1],
        ],
        [0, 1],
      );
      expect(
        () => f.predict([
          [0],
        ]),
        throwsArgumentError,
      );
      expect(
        () => f.predict([
          [double.infinity, 0],
        ]),
        throwsArgumentError,
      );
    },
  );
  test(
    'random feature subsets are redrawn per node, while default trees retain all-feature behavior',
    () {
      final x = <List<double>>[
            [0, 0],
            [0, 1],
            [1, 0],
            [1, 1],
          ],
          y = <double>[0, 0, 0, 1];
      final all = DecisionTreeClassifier(maxDepth: 2)..fit(x, y);
      expect(all.predict(x), y);
      var recovered = false;
      for (var seed = 0; seed < 30; seed++) {
        final t = DecisionTreeClassifier(
          maxDepth: 2,
          maxFeatures: 1,
          seed: seed,
        )..fit(x, y);
        if (t.depth == 2) {
          recovered = true;
        }
        final repeat = DecisionTreeClassifier(
          maxDepth: 2,
          maxFeatures: 1,
          seed: seed,
        )..fit(x, y);
        expect(t.predict(x), repeat.predict(x));
      }
      expect(
        recovered,
        isTrue,
      ); // Requires a different feature at the impure child.
      expect(() => DecisionTreeClassifier(maxFeatures: 0), throwsArgumentError);
      expect(
        () => DecisionTreeRegressor(maxFeatures: 2).fit(
          [
            [0],
          ],
          [1],
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'numerical failure after one candidate tree preserves every fitted field',
    () {
      int? selected;
      for (var seed = 0; seed < 100 && selected == null; seed++) {
        final random = Random(seed);
        final pure = <bool>[];
        for (var t = 0; t < 5; t++) {
          pure.add(random.nextInt(2) == random.nextInt(2));
          random.nextInt(0x7fffffff);
        }
        if (pure.first && pure.contains(false)) selected = seed;
      }
      expect(selected, isNotNull);
      final f = RandomForestRegressor(nEstimators: 5, seed: selected!)
        ..fit(
          [
            [0],
            [1],
          ],
          [1, 1],
        );
      final roots = f.trees, bags = f.bootstrapIndices, seeds = f.treeSeeds;
      expect(
        () => f.fit(
          [
            [0],
            [1],
          ],
          [-1e308, 1e308],
        ),
        throwsArgumentError,
      );
      expect(f.trees, same(roots));
      expect(f.bootstrapIndices, same(bags));
      expect(f.treeSeeds, same(seeds));
      expect(f.featuresPerSplit, 1);
      expect(
        f.predict([
          [0],
        ]).single,
        closeTo(1, 1e-12),
      );
    },
  );
  test('forests integrate with train-fitted pipelines and fresh CV', () {
    final scores = crossValidate(
      [
        [0],
        [1],
        [2],
        [3],
        [4],
        [5],
      ],
      [0, 0, 0, 1, 1, 1],
      kFold(6, k: 3),
      () => Pipeline(
        StandardScaler(),
        RandomForestClassifier(nEstimators: 5, maxDepth: 2, seed: 4),
      ),
      (a, b) => classificationMetrics(a, b).accuracy,
    );
    expect(scores, hasLength(3));
    expect(scores.every((s) => s.isFinite && s >= 0 && s <= 1), isTrue);
  });
}
