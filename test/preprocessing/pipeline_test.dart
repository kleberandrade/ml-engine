import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
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
}
