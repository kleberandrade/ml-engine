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
  test('scalers handle constant columns and never learn test statistics', () {
    final scaler = StandardScaler()
      ..fit([
        [1, 5],
        [3, 5],
      ]);
    expect(
      scaler.transform([
        [5, 5],
      ]).single,
      [3, 0],
    );
    final minMax = MinMaxScaler()
      ..fit([
        [1, 5],
        [3, 5],
      ]);
    expect(
      minMax.transform([
        [2, 5],
      ]).single,
      [0.5, 0],
    );
    expect(
      () => scaler.transform([
        [1],
      ]),
      throwsArgumentError,
    );
  });
  test('pipeline owns preprocessing and fits only its training rows', () {
    final pipeline = Pipeline(
      StandardScaler(),
      LinearRegression(iterations: 1000),
    );
    pipeline.fit(
      [
        [1],
        [2],
        [3],
      ],
      [3, 5, 7],
    );
    expect(
      pipeline.predict([
        [100],
      ]).single,
      closeTo(201, 1e-4),
    );
  });
  test('k-means++ finds separated centroids reproducibly', () {
    final x = [
      [0.0, 0.0],
      [0.0, 2.0],
      [10.0, 10.0],
      [10.0, 12.0],
    ];
    final a = KMeans(k: 2, seed: 7)..fit(x);
    final b = KMeans(k: 2, seed: 7)..fit(x);
    expect(a.centroids, b.centroids);
    expect(a.inertia, closeTo(4, 1e-10));
    expect(a.predict(x)[0], a.predict(x)[1]);
    expect(a.predict(x)[0], isNot(a.predict(x)[2]));
    expect(
      () => KMeans(k: 3).fit([
        [1],
        [1],
        [2],
      ]),
      throwsArgumentError,
    );
  });
  test('splits are seeded, disjoint, exhaustive and stratified', () {
    final split = trainValidationTestSplit(20, seed: 3);
    expect({...split.train, ...split.validation, ...split.test}.length, 20);
    expect(split.train, trainValidationTestSplit(20, seed: 3).train);
    final labels = List.generate(20, (i) => i % 2);
    final folds = stratifiedKFold(labels, k: 5, seed: 4);
    expect(folds.expand((f) => f.test).toSet().length, 20);
    for (final f in folds) {
      expect(f.test.map((i) => labels[i]).where((y) => y == 0).length, 2);
      expect(f.train.toSet().intersection(f.test.toSet()), isEmpty);
    }
    expect(() => stratifiedKFold([0, 0, 1], k: 2), throwsArgumentError);
  });
  test('cross validation creates a fresh pipeline and scaler per fold', () {
    final seen = <Pipeline>[];
    final scores = crossValidate(
      [
        [0],
        [1],
        [2],
        [3],
        [4],
        [5],
      ],
      [1, 3, 5, 7, 9, 11],
      kFold(6, k: 3),
      () {
        final p = Pipeline(
          StandardScaler(),
          LinearRegression(iterations: 1500),
        );
        seen.add(p);
        return p;
      },
      meanSquaredError,
    );
    expect(scores.every((s) => s < 1e-8), isTrue);
    expect(seen.toSet().length, 3);
  });
  test('metrics match manually calculated fixtures', () {
    expect(meanSquaredError([1, 2, 3], [2, 2, 1]), closeTo(5 / 3, 1e-12));
    expect(meanAbsoluteError([1, 2, 3], [2, 2, 1]), 1);
    expect(
      rootMeanSquaredError([1, 2, 3], [2, 2, 1]),
      closeTo(sqrt(5 / 3), 1e-12),
    );
    final m = classificationMetrics([0, 0, 1, 1], [0, 1, 1, 1]);
    expect(m.accuracy, .75);
    expect(m.precision, closeTo(2 / 3, 1e-12));
    expect(m.recall, 1);
    expect(m.f1, .8);
    expect(rSquared([2, 2], [2, 2]), 1);
    expect(rSquared([2, 2], [1, 1]), 0);
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
  test('CSV requires exact header, finite numeric rows and bounded size', () {
    expect(parseCsv('x1,x2,y\n1,2,0\n3,4,1').x.length, 2);
    expect(() => parseCsv('x,y\n1,2'), throwsFormatException);
    expect(() => parseCsv('x1,x2,y\nNaN,2,0'), throwsFormatException);
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
  test('pipeline exposes the exact train-fitted transformation', () {
    final p = Pipeline(StandardScaler(), LinearRegression());
    p.fit(
      [
        [1],
        [3],
      ],
      [1, 3],
    );
    expect(
      p.transform([
        [5],
      ]),
      [
        [3],
      ],
    );
  });
  test('cross validation rejects reused components and overlapping folds', () {
    final scaler = StandardScaler();
    expect(
      () => crossValidate(
        [
          [1],
          [2],
          [3],
          [4],
        ],
        [1, 2, 3, 4],
        kFold(4, k: 2),
        () => Pipeline(scaler, LinearRegression()),
        meanSquaredError,
      ),
      throwsArgumentError,
    );
    expect(
      () => crossValidate(
        [
          [1],
          [2],
        ],
        [1, 2],
        [
          Fold([0], [0]),
        ],
        () => Pipeline(StandardScaler(), LinearRegression()),
        meanSquaredError,
      ),
      throwsArgumentError,
    );
  });
  test('k-means handles all-identical data with k=1 and immutable results', () {
    final m = KMeans(k: 1)
      ..fit([
        [2, 2],
        [2, 2],
      ]);
    expect(m.inertia, 0);
    expect(
      m.predict([
        [3, 3],
      ]),
      [0],
    );
    expect(() => m.centroids[0][0] = 9, throwsUnsupportedError);
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
