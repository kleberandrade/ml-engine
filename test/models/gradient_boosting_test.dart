import 'dart:math';
import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
  final x = <List<double>>[
    [0],
    [1],
    [2],
    [3],
  ];
  test(
    'regression starts at mean and adds independently derived residual trees',
    () {
      final m = GradientBoostingRegressor(
        nEstimators: 2,
        maxDepth: 1,
        learningRate: .5,
      )..start(x, [0, 2, 10, 12]);
      expect(m.initialPrediction, 6);
      expect(m.predict(x), [6, 6, 6, 6]);
      expect(m.lossHistory, [13]);
      expect(m.step(), isTrue);
      expect(m.predict(x), [3.5, 3.5, 8.5, 8.5]);
      expect(m.lossHistory, [13, 3.625]);
      expect(m.step(), isTrue);
      expect(m.predict(x), [2.25, 2.25, 9.75, 9.75]);
      expect(m.lossHistory.last, 1.28125);
      expect(m.step(), isFalse);
      expect(m.trees, hasLength(2));
    },
  );
  test(
    'binary logistic boosting uses y minus sigmoid, not class-voting trees',
    () {
      final m = GradientBoostingClassifier(
        nEstimators: 2,
        maxDepth: 1,
        learningRate: .5,
      )..start(x, [0, 0, 1, 1]);
      expect(m.initialPrediction, 0);
      expect(m.probabilities(x), [.5, .5, .5, .5]);
      expect(m.predict(x), [1, 1, 1, 1]);
      m.step();
      expect(m.rawPredictions(x), [-.25, -.25, .25, .25]);
      expect(m.probabilities(x).last, closeTo(1 / (1 + exp(-.25)), 1e-14));
      expect(m.lossHistory.last, closeTo(log(1 + exp(-.25)), 1e-14));
      m.step();
      expect(
        m.rawPredictions(x).last,
        closeTo(.25 + .5 / (1 + exp(.25)), 1e-14),
      );
      expect(m.predict(x), [0, 0, 1, 1]);
    },
  );
  test('class prior log odds and pure-label clipping remain finite', () {
    final m = GradientBoostingClassifier(nEstimators: 2, maxDepth: 0)
      ..start(x, [0, 1, 1, 1]);
    expect(m.initialPrediction, closeTo(log(3), 1e-14));
    expect(m.probabilities(x).first, closeTo(.75, 1e-14));
    for (final label in [0.0, 1.0]) {
      m.fit(x, List.filled(4, label));
      expect(m.initialPrediction.isFinite, isTrue);
      expect(m.lossHistory.every((v) => v.isFinite && v >= 0), isTrue);
      expect(m.predict(x), List.filled(4, label));
    }
  });
  test(
    'fit and resumed stages agree; trees and histories are immutable snapshots',
    () {
      final a = GradientBoostingRegressor(nEstimators: 4, learningRate: .3)
        ..start(x, [0, 2, 10, 12]);
      a.step();
      final trees = a.trees, losses = a.lossHistory;
      while (a.step()) {}
      final b = GradientBoostingRegressor(nEstimators: 4, learningRate: .3)
        ..fit(x, [0, 2, 10, 12]);
      expect(a.predict(x), b.predict(x));
      expect(a.lossHistory, b.lossHistory);
      expect(trees, hasLength(1));
      expect(losses, hasLength(2));
      expect(() => trees.clear(), throwsUnsupportedError);
      expect(() => losses[0] = 7, throwsUnsupportedError);
    },
  );
  test(
    'rate, count and depth change the additive model with bounded leaves',
    () {
      final m = GradientBoostingRegressor(
        nEstimators: 3,
        learningRate: 1,
        maxDepth: 0,
      )..fit(x, [0, 2, 10, 12]);
      expect(m.predict(x), [6, 6, 6, 6]);
      final deep = GradientBoostingRegressor(
        nEstimators: 1,
        learningRate: 1,
        maxDepth: 2,
      )..fit(x, [0, 2, 10, 12]);
      expect(deep.predict(x), [0, 2, 10, 12]);
      final bounded = GradientBoostingRegressor(
        nEstimators: 4,
        maxDepth: 3,
        minSamplesLeaf: 2,
      )..fit(x, [0, 2, 10, 12]);
      void check(DecisionTreeNode t) {
        if (t.isLeaf) {
          expect(t.sampleCount, greaterThanOrEqualTo(2));
        } else {
          check(t.left!);
          check(t.right!);
        }
      }

      for (final t in bounded.trees) {
        expect(t.depth, lessThanOrEqualTo(3));
        check(t);
      }
    },
  );
  test('failed refits and failed stages preserve complete previous state', () {
    final m = GradientBoostingRegressor(nEstimators: 2)..fit(x, [1, 1, 1, 1]);
    final old = m.trees, history = m.lossHistory;
    expect(
      () => m.fit(
        [
          [0],
          [1],
        ],
        [-1e154, 1e154],
      ),
      throwsArgumentError,
    );
    expect(m.trees, same(old));
    expect(m.lossHistory, same(history));
    expect(
      m.predict([
        [0],
      ]).single,
      closeTo(1, 1e-12),
    );
    m.start(
      [
        [0],
        [1],
      ],
      [-1e154, 1e154],
    );
    final initial = m.lossHistory;
    expect(() => m.step(), throwsArgumentError);
    expect(m.trees, isEmpty);
    expect(m.lossHistory, same(initial));
    expect(
      m.predict([
        [0],
      ]),
      [0],
    );
  });
  test(
    'invalid parameters, binary labels, dimensions and nonfinite values fail at boundaries',
    () {
      expect(
        () => GradientBoostingRegressor(nEstimators: 0),
        throwsArgumentError,
      );
      expect(
        () => GradientBoostingClassifier(maxDepth: -1),
        throwsArgumentError,
      );
      expect(
        () => GradientBoostingRegressor(minSamplesLeaf: 0),
        throwsArgumentError,
      );
      for (final rate in [0.0, -1.0, 1.01, double.nan, double.infinity]) {
        expect(
          () => GradientBoostingClassifier(learningRate: rate),
          throwsArgumentError,
        );
      }
      final m = GradientBoostingClassifier(nEstimators: 1);
      expect(() => m.step(), throwsStateError);
      expect(() => m.probabilities(x), throwsStateError);
      expect(() => m.fit(x, [0, 1, 2, 1]), throwsArgumentError);
      m.fit(x, [0, 0, 1, 1]);
      final trees = m.trees;
      expect(() => m.start(x, [0, double.nan, 1, 1]), throwsArgumentError);
      expect(m.trees, same(trees));
      expect(
        () => m.predict([
          [0, 1],
        ]),
        throwsArgumentError,
      );
      expect(
        () => m.predict([
          [double.infinity],
        ]),
        throwsArgumentError,
      );
      expect(() => m.fit([], []), throwsArgumentError);
    },
  );
  test('fit owns inputs and repeated deterministic fits reset stages', () {
    final rows = <List<double>>[
          [0],
          [1],
          [2],
          [3],
        ],
        y = <double>[0, 0, 1, 1];
    final m = GradientBoostingClassifier(nEstimators: 3)..start(rows, y);
    rows[0][0] = 999;
    y[0] = 1;
    while (m.step()) {}
    final expected = GradientBoostingClassifier(nEstimators: 3)
      ..fit(x, [0, 0, 1, 1]);
    expect(m.probabilities(x), expected.probabilities(x));
    m.fit(x, [0, 0, 1, 1]);
    expect(m.trees, hasLength(3));
    expect(m.probabilities(x), expected.probabilities(x));
  });
  test(
    'gradient boosting composes with fresh train-fitted pipelines in CV',
    () {
      final scores = crossValidate(
        x,
        [0, 0, 1, 1],
        kFold(4, k: 2),
        () => Pipeline(
          StandardScaler(),
          GradientBoostingClassifier(nEstimators: 3),
        ),
        (a, b) => classificationMetrics(a, b).accuracy,
      );
      expect(scores, hasLength(2));
      expect(scores.every((s) => s.isFinite), isTrue);
    },
  );
}
