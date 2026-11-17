import 'package:ml_engine/ml_engine.dart';
import 'package:test/test.dart';

void main() {
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
  test('CSV requires exact header, finite numeric rows and bounded size', () {
    expect(parseCsv('x1,x2,y\n1,2,0\n3,4,1').x.length, 2);
    expect(() => parseCsv('x,y\n1,2'), throwsFormatException);
    expect(() => parseCsv('x1,x2,y\nNaN,2,0'), throwsFormatException);
  });
  test('CSV failures expose language-neutral row metadata', () {
    try {
      parseCsv('x1,x2,y\nNaN,0,1\n2,0,3');
      fail('Invalid rows must fail.');
    } on CsvFormatException catch (e) {
      expect(e.code, CsvError.invalidRow);
      expect(e.row, 2);
    }
  });
}
