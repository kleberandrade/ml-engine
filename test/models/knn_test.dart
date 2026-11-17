import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'classification uses Euclidean neighbors and a uniform majority vote',
    () {
      final model = KNNClassifier(k: 1)
        ..fit(
          [
            [3, 0],
            [2, 2],
          ],
          [9, 2],
        );
      expect(
        model.predict([
          [0, 0],
        ]),
        [2],
      ); // sqrt(8) < 3; Manhattan would disagree.
      final vote = KNNClassifier(k: 3)
        ..fit(
          [
            [0],
            [1],
            [2],
            [10],
          ],
          [4, 7, 7, 4],
        );
      expect(
        vote.predict([
          [1.1],
        ]),
        [7],
      );
    },
  );
  test('regression averages exactly k targets, with k=1 and k=n supported', () {
    final model = KNNRegressor(k: 2)
      ..fit(
        [
          [0],
          [2],
          [8],
        ],
        [0, 10, 30],
      );
    expect(
      model.predict([
        [3],
      ]),
      [5],
    );
    expect(
      (KNNRegressor(k: 1)..fit(
            [
              [0],
              [2],
            ],
            [4, 8],
          ))
          .predict([
            [1.9],
          ]),
      [8],
    );
    expect(
      (KNNRegressor(k: 3)..fit(
            [
              [0],
              [2],
              [8],
            ],
            [0, 10, 20],
          ))
          .predict([
            [100],
          ]),
      [10],
    );
  });
  test(
    'distance-boundary ties use training order; class-vote ties use smallest label',
    () {
      final nearest = KNNClassifier(k: 1)
        ..fit(
          [
            [-1],
            [1],
          ],
          [7, 2],
        );
      expect(
        nearest.predict([
          [0],
        ]),
        [7],
      );
      final vote = KNNClassifier(k: 4)
        ..fit(
          [
            [0],
            [1],
            [2],
            [3],
          ],
          [3, 2, 3, 2],
        );
      expect(
        vote.predict([
          [1.5],
        ]),
        [2],
      );
      final reg = KNNRegressor(k: 2)
        ..fit(
          [
            [0],
            [2],
            [4],
          ],
          [10, 20, 90],
        );
      expect(
        reg.predict([
          [2],
        ]),
        [15],
      ); // Row 0 beats row 2 at tied distance 2.
    },
  );
  test(
    'duplicate points are separate equally weighted rows, including exact matches',
    () {
      final x = <List<double>>[
        [1],
        [1],
        [1],
      ];
      expect(
        (KNNClassifier(k: 3)..fit(x, [2, 8, 8])).predict([
          [1],
        ]),
        [8],
      );
      expect(
        (KNNClassifier(k: 1)..fit(x, [2, 8, 8])).predict([
          [1],
        ]),
        [2],
      );
      expect(
        (KNNRegressor(k: 3)..fit(x, [2, 8, 8])).predict([
          [1],
        ]).single,
        closeTo(6, 1e-14),
      );
    },
  );
  test(
    'fit owns data and rejected refits preserve the usable previous model',
    () {
      final x = <List<double>>[
            [0],
            [1],
          ],
          y = <double>[2, 4];
      for (final model in <Estimator>[
        KNNClassifier(k: 2),
        KNNRegressor(k: 2),
      ]) {
        model.fit(x, y);
        final expected = model.predict([
          [.2],
        ]);
        expect(
          () => model.fit(
            [
              [9],
            ],
            [9],
          ),
          throwsArgumentError,
        );
        expect(
          model.predict([
            [.2],
          ]),
          expected,
        );
      }
      final model = KNNRegressor(k: 1)..fit(x, y);
      x[0][0] = 100;
      y[0] = -100;
      expect(
        model.predict([
          [0],
        ]),
        [2],
      );
      model.fit(
        [
          [3],
        ],
        [9],
      );
      expect(
        model.predict([
          [3],
        ]),
        [9],
      );
    },
  );
  test('invalid k, shapes, labels and unfitted calls are rejected', () {
    for (final k in [0, -1]) {
      expect(() => KNNClassifier(k: k), throwsArgumentError);
      expect(() => KNNRegressor(k: k), throwsArgumentError);
    }
    for (final model in <Estimator>[KNNClassifier(k: 1), KNNRegressor(k: 1)]) {
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
          ],
          [double.nan],
        ),
        throwsArgumentError,
      );
      expect(
        () => model.fit(
          [
            [0],
            [0, 1],
          ],
          [0, 1],
        ),
        throwsArgumentError,
      );
      model.fit(
        [
          [0],
        ],
        [1],
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
      expect(() => model.predict([]), throwsArgumentError);
    }
  });
  test(
    'distance overflow is explicit and regression avoids avoidable sum overflow',
    () {
      final model = KNNRegressor(k: 1)
        ..fit(
          [
            [-1e308],
          ],
          [1],
        );
      expect(
        () => model.predict([
          [1e308],
        ]),
        throwsArgumentError,
      );
      final large = KNNRegressor(k: 2)
        ..fit(
          [
            [0],
            [1],
          ],
          [1e308, 1e308],
        );
      expect(
        large.predict([
          [0],
        ]),
        [1e308],
      );
    },
  );
  test(
    'KNN composes with train-fitted pipelines and fresh cross validation',
    () {
      final p = Pipeline(StandardScaler(), KNNClassifier(k: 1))
        ..fit(
          [
            [0, 0],
            [10, 1000],
          ],
          [0, 1],
        );
      expect(
        p.predict([
          [1, 100],
        ]),
        [0],
      );
      final scores = crossValidate(
        [
          [0],
          [1],
          [2],
          [3],
        ],
        [0, 2, 4, 6],
        kFold(4, k: 2),
        () => Pipeline(StandardScaler(), KNNRegressor(k: 1)),
        meanSquaredError,
      );
      expect(scores, hasLength(2));
      expect(scores.every((v) => v.isFinite && v >= 0), isTrue);
    },
  );
}
