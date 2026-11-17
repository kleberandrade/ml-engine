import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
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
}
