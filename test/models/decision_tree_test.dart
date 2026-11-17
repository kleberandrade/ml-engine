import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'classification finds the hand-computed Gini split and threshold routing',
    () {
      final tree = DecisionTreeClassifier(maxDepth: 1)
        ..fit(
          [
            [0],
            [1],
            [2],
            [3],
          ],
          [0, 0, 1, 1],
        );
      expect(tree.root.featureIndex, 0);
      expect(tree.root.threshold, 1.5);
      expect(tree.root.impurity, .5);
      expect(tree.root.left!.impurity, 0);
      expect(tree.root.right!.impurity, 0);
      expect(
        tree.predict([
          [-100],
          [1.5],
          [1.5001],
          [100],
        ]),
        [0, 0, 1, 1],
      );
      expect(tree.depth, 1);
      expect(tree.leafCount, 2);
    },
  );
  test(
    'regression minimizes weighted squared error with mean-valued leaves',
    () {
      final tree = DecisionTreeRegressor(maxDepth: 1)
        ..fit(
          [
            [0],
            [1],
            [2],
            [3],
          ],
          [0, 2, 10, 12],
        );
      // Parent mean=6, MSE=26; split at 1.5 gives means 1,11 and MSE=1.
      expect(tree.root.threshold, 1.5);
      expect(tree.root.prediction, 6);
      expect(tree.root.impurity, closeTo(26, 1e-12));
      expect(
        tree.predict([
          [.2],
          [2.8],
        ]),
        [1, 11],
      );
      expect(tree.root.left!.impurity, closeTo(1, 1e-12));
    },
  );
  test('depth zero is a single leaf; deeper trees capture a step sequence', () {
    final x = <List<double>>[
          [0],
          [1],
          [2],
          [3],
        ],
        y = <double>[0, 0, 1, 2];
    final zero = DecisionTreeRegressor(maxDepth: 0)..fit(x, y);
    expect(
      zero.predict([
        [100],
      ]),
      [.75],
    );
    expect(zero.depth, 0);
    expect(zero.leafCount, 1);
    final deep = DecisionTreeRegressor(maxDepth: 2)..fit(x, y);
    expect(deep.predict(x), y);
    expect(deep.depth, 2);
  });
  test(
    'minimum leaf size prevents singleton splits and is enforced recursively',
    () {
      final t = DecisionTreeRegressor(maxDepth: 8, minSamplesLeaf: 2)
        ..fit(
          [
            [0],
            [1],
            [2],
            [3],
            [4],
          ],
          [0, 0, 0, 0, 100],
        );
      void check(DecisionTreeNode n) {
        if (n.isLeaf) {
          expect(n.sampleCount, greaterThanOrEqualTo(2));
        } else {
          check(n.left!);
          check(n.right!);
        }
      }

      check(t.root);
      expect(
        t.predict([
          [4],
        ]).single,
        lessThan(100),
      );
      final small = DecisionTreeClassifier(minSamplesLeaf: 5)
        ..fit(
          [
            [0],
            [1],
          ],
          [1, 2],
        );
      expect(small.root.isLeaf, isTrue);
    },
  );
  test(
    'constant features, pure targets and multiclass vote ties stop safely',
    () {
      final t = DecisionTreeClassifier()
        ..fit(
          [
            [2],
            [2],
            [2],
            [2],
          ],
          [3, 2, 3, 2],
        );
      expect(
        t.predict([
          [9],
        ]),
        [2],
      );
      expect(t.root.isLeaf, isTrue);
      final pure = DecisionTreeClassifier()
        ..fit(
          [
            [0],
            [1],
            [2],
          ],
          [7, 7, 7],
        );
      expect(pure.depth, 0);
      final reg = DecisionTreeRegressor()
        ..fit(
          [
            [0],
            [1],
          ],
          [1e308, 1e308],
        );
      expect(
        reg.predict([
          [2],
        ]),
        [1e308],
      );
    },
  );
  test(
    'equal gains prefer feature index then lowest threshold deterministically',
    () {
      final x = <List<double>>[
            [0, 0],
            [1, 1],
            [2, 2],
            [3, 3],
          ],
          y = <double>[0, 1, 1, 0];
      final a = DecisionTreeClassifier(maxDepth: 1)..fit(x, y);
      final b = DecisionTreeClassifier(maxDepth: 1)..fit(x, y);
      expect(a.root.featureIndex, 0);
      expect(a.root.threshold, .5);
      expect(a.predict(x), b.predict(x));
      expect(a.root.threshold, b.root.threshold);
    },
  );
  test(
    'a greedy tree rejects zero-gain XOR splits rather than claiming global optimization',
    () {
      final tree = DecisionTreeClassifier(maxDepth: 4)
        ..fit(
          [
            [0, 0],
            [0, 1],
            [1, 0],
            [1, 1],
          ],
          [0, 1, 1, 0],
        );
      expect(tree.depth, 0);
      expect(
        tree.predict([
          [1, 0],
        ]),
        [0],
      );
    },
  );
  test(
    'fit owns its immutable tree and rejected refits preserve the previous root',
    () {
      final x = <List<double>>[
            [0],
            [1],
            [2],
          ],
          y = <double>[0, 0, 1];
      final t = DecisionTreeClassifier()..fit(x, y);
      final root = t.root;
      x[0][0] = 999;
      y[0] = 9;
      expect(
        t.predict([
          [0],
        ]),
        [0],
      );
      expect(
        () => t.fit(
          [
            [0],
          ],
          [double.nan],
        ),
        throwsArgumentError,
      );
      expect(t.root, same(root));
      final r = DecisionTreeRegressor()
        ..fit(
          [
            [0],
            [1],
          ],
          [0, 2],
        );
      final old = r.root;
      expect(
        () => r.fit(
          [
            [0],
            [1],
          ],
          [-1e308, 1e308],
        ),
        throwsArgumentError,
      );
      expect(r.root, same(old));
    },
  );
  test(
    'invalid parameters, unfitted prediction and malformed input are rejected',
    () {
      expect(() => DecisionTreeClassifier(maxDepth: -1), throwsArgumentError);
      expect(
        () => DecisionTreeRegressor(minSamplesLeaf: 0),
        throwsArgumentError,
      );
      for (final model in <Estimator>[
        DecisionTreeClassifier(),
        DecisionTreeRegressor(),
      ]) {
        expect(
          () => model.predict([
            [0],
          ]),
          throwsStateError,
        );
        expect(() => model.fit([], []), throwsArgumentError);
        expect(
          () => model.fit(
            [
              [0],
              [1, 2],
            ],
            [0, 1],
          ),
          throwsArgumentError,
        );
        model.fit(
          [
            [0],
            [1],
          ],
          [0, 1],
        );
        expect(
          () => model.predict([
            [0, 1],
          ]),
          throwsArgumentError,
        );
        expect(
          () => model.predict([
            [double.infinity],
          ]),
          throwsArgumentError,
        );
      }
    },
  );
  test(
    'midpoints handle extreme features; trees compose with train-fitted pipelines/CV',
    () {
      final t = DecisionTreeClassifier(maxDepth: 1)
        ..fit(
          [
            [-1e308],
            [1e308],
          ],
          [0, 1],
        );
      expect(t.root.threshold, 0);
      expect(
        t.predict([
          [-1],
          [1],
        ]),
        [0, 1],
      );
      final low = 1.0000000000000002, high = 1.0000000000000004;
      final adjacent = DecisionTreeClassifier(maxDepth: 1)
        ..fit(
          [
            [low],
            [high],
          ],
          [0, 1],
        );
      expect(
        adjacent.root.threshold,
        low,
      ); // Midpoint rounds upward: use lower endpoint.
      expect(
        adjacent.predict([
          [low],
          [high],
        ]),
        [0, 1],
      );
      final scores = crossValidate(
        [
          [0],
          [1],
          [2],
          [3],
        ],
        [0, 0, 1, 1],
        kFold(4, k: 2),
        () => Pipeline(StandardScaler(), DecisionTreeClassifier(maxDepth: 2)),
        (a, b) => classificationMetrics(a, b).accuracy,
      );
      expect(scores, hasLength(2));
      expect(scores.every((s) => s.isFinite && s >= 0 && s <= 1), isTrue);
    },
  );
}
