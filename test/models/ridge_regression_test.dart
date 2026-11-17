import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
  final x = <List<double>>[
    [-1, -1],
    [-1, 1],
    [1, -1],
    [1, 1],
  ];
  final y = <double>[2, -4, 6, 0]; // b=1, w=(2,-3), X'X/n=I.

  test('ridge matches a hand-solved regularized orthogonal system', () {
    final model = RidgeRegression(lambda: 1, learningRate: .1, iterations: 500)
      ..fit(x, y);
    // (I + lambda I) w = (2,-3); the intercept is not penalized.
    expect(model.coefficients[0], closeTo(1, 1e-12));
    expect(model.coefficients[1], closeTo(-1.5, 1e-12));
    expect(model.intercept, closeTo(1, 1e-12));
    expect(model.costHistory.last, closeTo(3.25, 1e-12));
  });

  test('lambda zero is exactly the existing linear optimizer', () {
    final linear = LinearRegression(learningRate: .1, iterations: 80)
      ..fit(x, y);
    final ridge = RidgeRegression(lambda: 0, learningRate: .1, iterations: 80)
      ..fit(x, y);
    expect(ridge.coefficients, linear.coefficients);
    expect(ridge.intercept, linear.intercept);
    expect(ridge.costHistory, linear.costHistory);
    expect(ridge.predict(x), linear.predict(x));
  });

  test('mean-loss convention is invariant to duplicating training rows', () {
    final a = RidgeRegression(lambda: 2, learningRate: .1)..fit(x, y);
    final b = RidgeRegression(lambda: 2, learningRate: .1)
      ..fit([...x, ...x], [...y, ...y]);
    for (var j = 0; j < 2; j++) {
      expect(a.coefficients[j], closeTo(b.coefficients[j], 1e-12));
    }
    expect(a.coefficients[0], closeTo(2 / 3, 1e-12));
    expect(a.coefficients[1], closeTo(-1, 1e-12));
  });

  test('step objective includes L2 and gradient uses lambda times weights', () {
    final model = RidgeRegression(lambda: 2, learningRate: .1)
      ..start(
        [
          [-1],
          [1],
        ],
        [-1, 1],
      );
    model.step(); // w=.1; MSE/2=.405; penalty=.01.
    expect(model.costHistory.single, closeTo(.415, 1e-14));
    model.step(); // gradient=(w-1)+2w=-.7; w=.17.
    expect(model.coefficients.single, closeTo(.17, 1e-14));
    expect(model.costHistory.last, closeTo(.37335, 1e-14));
  });

  test(
    'constant targets keep an unpenalized intercept and zero coefficients',
    () {
      final model =
          RidgeRegression(lambda: 20, learningRate: .01, iterations: 4000)..fit(
            [
              [0],
              [0],
            ],
            [7, 7],
          );
      expect(model.intercept, closeTo(7, 1e-12));
      expect(model.coefficients, [0]);
    },
  );

  test('ridge handles collinear columns and shrinks coefficient norm', () {
    final data = <List<double>>[
      [-2, -2],
      [-1, -1],
      [1, 1],
      [2, 2],
    ];
    final targets = <double>[-5, -2, 4, 7];
    final linear = LinearRegression()..fit(data, targets);
    final ridge = RidgeRegression(lambda: 1)..fit(data, targets);
    expect(ridge.coefficients[0], closeTo(1.25, 1e-10));
    expect(ridge.coefficients[1], closeTo(1.25, 1e-10));
    expect(ridge.coefficients[0].abs(), lessThan(linear.coefficients[0].abs()));
    expect(ridge.intercept, closeTo(1, 1e-10));
  });

  test('invalid lambda, inputs and divergent updates are rejected safely', () {
    for (final lambda in [-1.0, double.nan, double.infinity]) {
      expect(() => RidgeRegression(lambda: lambda), throwsArgumentError);
    }
    final model = RidgeRegression(lambda: 1e308, learningRate: 1)
      ..start(
        [
          [1],
        ],
        [2],
      );
    expect(model.step, throwsStateError); // finite score but infinite penalty
    expect(model.coefficients, [0]);
    expect(model.costHistory, isEmpty);
    expect(
      () => model.start(
        [
          [1],
        ],
        [double.nan],
      ),
      throwsArgumentError,
    );
    expect(
      () => model.predict([
        [1, 2],
      ]),
      throwsArgumentError,
    );
  });

  test('ridge composes with train-fitted scalers and fresh CV pipelines', () {
    final scores = crossValidate(
      [
        [-2],
        [-1],
        [0],
        [1],
        [2],
        [3],
      ],
      [-3, -1, 1, 3, 5, 7],
      kFold(6, k: 3),
      () => Pipeline(StandardScaler(), RidgeRegression(lambda: .1)),
      meanSquaredError,
    );
    expect(scores.length, 3);
    expect(scores.every((s) => s.isFinite && s >= 0), isTrue);
  });
}
