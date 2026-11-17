import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
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
}
