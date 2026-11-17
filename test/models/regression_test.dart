import 'dart:math';
import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
  test('linear regression recovers an independent analytical fixture', () {
    final x = [
      [-2.0],
      [-1.0],
      [0.0],
      [1.0],
      [2.0],
    ];
    // Exact least squares solution for y = 3x + 2; tolerance is GD error.
    final model = LinearRegression(learningRate: 0.1, iterations: 500);
    model.fit(x, [-4, -1, 2, 5, 8]);
    expect(
      model.predict([
        [3],
      ]).single,
      closeTo(11, 1e-7),
    );
    expect(model.costHistory.last, lessThan(model.costHistory.first));
  });
  test('logistic regression separates a known threshold', () {
    final model = LogisticRegression(learningRate: 0.2, iterations: 1000);
    model.fit(
      [
        [-2],
        [-1],
        [1],
        [2],
      ],
      [0, 0, 1, 1],
    );
    expect(
      model.predict([
        [-3],
        [3],
      ]),
      [0, 1],
    );
    expect(
      model
          .probabilities([
            [10000],
          ])
          .single
          .isFinite,
      isTrue,
    );
    expect(model.costHistory.last, lessThan(0.02));
  });
  test('boundaries reject invalid shapes, NaN, labels and parameters', () {
    for (final x in <List<List<double>>>[
      [],
      [[]],
      [
        [1],
        [1, 2],
      ],
      [
        [double.nan],
      ],
    ]) {
      expect(
        () => LinearRegression().fit(x, List.filled(x.length, 1)),
        throwsArgumentError,
      );
    }
    expect(
      () => LinearRegression().fit([
        [1],
      ], []),
      throwsArgumentError,
    );
    expect(
      () => LogisticRegression().fit(
        [
          [1],
        ],
        [2],
      ),
      throwsArgumentError,
    );
    expect(() => LinearRegression(learningRate: -1), throwsArgumentError);
    expect(() => meanSquaredError([], []), throwsArgumentError);
    expect(
      () => StandardScaler().transform([
        [1],
      ]),
      throwsStateError,
    );
  });
  test('multi-feature regression matches a hand-solved orthogonal system', () {
    final x = [
      [-1.0, -1.0],
      [-1.0, 1.0],
      [1.0, -1.0],
      [1.0, 1.0],
    ];
    final model = LinearRegression(learningRate: .1, iterations: 400)
      ..fit(x, [2, -4, 6, 0]);
    // Orthogonal design: intercept=1, coefficient x1=2, x2=-3.
    expect(model.intercept, closeTo(1, 1e-12));
    expect(model.coefficients[0], closeTo(2, 1e-12));
    expect(model.coefficients[1], closeTo(-3, 1e-12));
  });
  test('logistic first update matches independently computed likelihood', () {
    final m = LogisticRegression(learningRate: .2, iterations: 1)
      ..fit(
        [
          [-1],
          [1],
        ],
        [0, 1],
      );
    // Initial p=.5; dL/dw=-.5, so w=.1, b=0.
    expect(m.coefficients.single, closeTo(.1, 1e-14));
    expect(m.costHistory.single, closeTo(log(1 + exp(-.1)), 1e-14));
  });
  test('step training resumes without changing deterministic results', () {
    final a = LinearRegression(iterations: 30)
      ..fit(
        [
          [1],
          [2],
        ],
        [3, 5],
      );
    final b = LinearRegression(iterations: 30)
      ..start(
        [
          [1],
          [2],
        ],
        [3, 5],
      );
    for (var i = 0; i < 30; i++) {
      b.step();
    }
    expect(
      a.predict([
        [3],
      ]),
      b.predict([
        [3],
      ]),
    );
    expect(a.costHistory, b.costHistory);
  });
}
