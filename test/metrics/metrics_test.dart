import 'dart:math';
import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
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
}
