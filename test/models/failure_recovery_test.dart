import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
  test('rejected scaler refits preserve the last valid statistics', () {
    for (final scaler in <Transformer>[StandardScaler(), MinMaxScaler()]) {
      scaler.fit([
        [1],
        [3],
      ]);
      final before = scaler.transform([
        [2],
      ]);
      expect(
        () => scaler.fit([
          [-1e308],
          [1e308],
        ]),
        throwsArgumentError,
      );
      expect(
        scaler.transform([
          [2],
        ]),
        before,
      );
    }
  });

  test('rejected k-means initialization preserves fitted clusters', () {
    final model = KMeans(k: 2)
      ..fit([
        [0],
        [1],
        [10],
        [11],
      ]);
    final centers = model.centroids;
    final history = model.costHistory;
    expect(
      () => model.start([
        [-1e308],
        [1e308],
      ]),
      throwsArgumentError,
    );
    expect(model.centroids, centers);
    expect(model.costHistory, history);
    expect(model.step(), isFalse);
  });

  test('divergent gradient step preserves the last completed update', () {
    final model = LinearRegression(learningRate: 1e308)
      ..start(
        [
          [2],
        ],
        [2],
      );
    final before = model.predict([
      [1],
    ]);
    expect(model.step, throwsStateError);
    expect(
      model.predict([
        [1],
      ]),
      before,
    );
    expect(model.coefficients, [0]);
    expect(model.intercept, 0);
    expect(model.completedIterations, 0);
    model.start(
      [
        [0],
      ],
      [0],
    );
    expect(model.step(), isTrue);
  });

  test('failed clustering update preserves initialized centroids', () {
    final model = KMeans(k: 1)
      ..start([
        [-1e154],
        [1e154],
      ]);
    final before = model.centroids;
    expect(model.step, throwsStateError);
    expect(model.centroids, before);
    expect(model.costHistory, isEmpty);
  });

  test('a later divergent step retains completed predictions and history', () {
    final model = LinearRegression(learningRate: 1e153)
      ..start(
        [
          [1],
        ],
        [1],
      );
    expect(model.step(), isTrue);
    final before = model.predict([
      [1],
    ]);
    final history = model.costHistory;
    expect(model.step, throwsStateError);
    expect(
      model.predict([
        [1],
      ]),
      before,
    );
    expect(model.costHistory, history);
    expect(model.completedIterations, 1);
  });

  test(
    'failed pipeline refit blocks mixed-state prediction until recovery',
    () {
      final pipeline = Pipeline(StandardScaler(), LogisticRegression());
      pipeline.fit(
        [
          [-1],
          [1],
        ],
        [0, 1],
      );
      expect(
        () => pipeline.fit(
          [
            [100],
            [200],
          ],
          [0, 2],
        ),
        throwsArgumentError,
      );
      expect(
        () => pipeline.predict([
          [1],
        ]),
        throwsStateError,
      );
      expect(
        () => pipeline.transform([
          [1],
        ]),
        throwsStateError,
      );
      pipeline.fit(
        [
          [-1],
          [1],
        ],
        [0, 1],
      );
      expect(
        pipeline.predict([
          [-2],
          [2],
        ]),
        [0, 1],
      );
    },
  );
}
