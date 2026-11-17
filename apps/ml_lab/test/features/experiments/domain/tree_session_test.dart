import 'package:flutter_test/flutter_test.dart';
import 'package:ml_engine/ml_engine.dart';
import 'package:ml_lab/features/experiments/application/lab_view_model.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';
import 'package:ml_lab/features/experiments/domain/experiment_session.dart';
import 'package:ml_lab/features/experiments/domain/lab_failure.dart';

void main() {
  test('tree sessions learn only training rows and fit directly without cost histories', () {
    final split = trainValidationTestSplit(20);
    for (final task in [
      Experiment.treeClassification,
      Experiment.treeRegression,
    ]) {
      final y = List.generate(20, (i) => split.train.contains(i) ? 0.0 : 1.0);
      final data = Dataset(List.generate(20, (_) => [0.0, 0.0]), y);
      final session = ExperimentSession(
        data,
        ExperimentSettings(experiment: task),
      )..start();
      expect(
        session.predict([
          [0, 0],
        ]),
        [0],
      );
      expect(session.treeRoot()!.sampleCount, split.train.length);
      expect(session.treeRoot()!.depth, 0);
      expect(session.treeRoot()!.leafCount, 1);
      expect(session.history, isEmpty);
      expect(session.step(), isFalse);
    }
  });
  test(
    'depth one comparison matches exactly for both tasks with bounded leaves',
    () {
      for (final task in [
        Experiment.treeClassification,
        Experiment.treeRegression,
      ]) {
        final c = LabViewModel()
          ..select(task)
          ..configure(maxDepth: 1)
          ..start();
        expect(c.status, RunStatus.complete);
        expect(
          c.score(c.split.validation)!.value,
          c.score(c.split.validation, alternate: true)!.value,
        );
        expect(c.treeRoot()!.depth, lessThanOrEqualTo(1));
        void check(DecisionTreeNode n) {
          if (n.isLeaf) {
            expect(n.sampleCount, greaterThanOrEqualTo(2));
          } else {
            check(n.left!);
            check(n.right!);
          }
        }

        check(c.treeRoot()!);
        c.dispose();
      }
    },
  );
  test('depth changes invalidate sampled predictions and preserve old immutable trees', () {
    final c = LabViewModel()
      ..select(Experiment.treeRegression)
      ..start();
    addTearDown(c.dispose);
    final tree = c.treeRoot()!,
        plot = c.plot,
        predictions = List<double>.of(c.plot.samples!.a);
    expect(c.plot, same(plot));
    c.configure(maxDepth: 6);
    expect(c.status, RunStatus.ready);
    expect(c.plot.samples, isNull);
    c.start();
    expect(c.treeRoot()!.depth, lessThanOrEqualTo(6));
    expect(c.treeRoot(), isNot(same(tree)));
    expect(plot.samples!.a, predictions);
    expect(() => plot.samples!.a[0] = 9, throwsUnsupportedError);
  });
  test(
    'lab depth bounds and binary CSV are checked before replacing results',
    () {
      for (final d in [0, 7]) {
        expect(() => ExperimentSettings(maxDepth: d), throwsArgumentError);
      }
      final c = LabViewModel()
        ..select(Experiment.treeClassification)
        ..start();
      addTearDown(c.dispose);
      final old = c.data;
      expect(
        () => c.importCsv(
          'x1,x2,y\n${List.generate(20, (i) => '$i,0,2').join('\n')}',
        ),
        throwsA(
          isA<LabDataException>().having(
            (e) => e.code,
            'code',
            LabDataError.binaryLabels,
          ),
        ),
      );
      expect(c.data, same(old));
      expect(c.status, RunStatus.complete);
      c.select(Experiment.treeRegression);
      c.importCsv(
        'x1,x2,y\n${List.generate(20, (i) => '$i,0,${i * 2 + .5}').join('\n')}',
      );
      c.start();
      expect(c.score(c.split.validation)!.metric, ScoreMetric.rmse);
    },
  );
}
