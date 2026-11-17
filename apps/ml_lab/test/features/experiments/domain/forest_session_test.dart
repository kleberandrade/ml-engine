import 'package:flutter_test/flutter_test.dart';
import 'package:ml_engine/ml_engine.dart';
import 'package:ml_lab/features/experiments/application/lab_view_model.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';
import 'package:ml_lab/features/experiments/domain/experiment_session.dart';
import 'package:ml_lab/features/experiments/domain/lab_failure.dart';

void main() {
  test('forest learns only training targets, with no fake epochs and aggregate metadata', () {
    final split = trainValidationTestSplit(20);
    for (final task in [
      Experiment.forestClassification,
      Experiment.forestRegression,
    ]) {
      final data = Dataset(
        List.generate(20, (_) => [0.0, 0.0]),
        List.generate(20, (i) => split.train.contains(i) ? 0.0 : 1.0),
      );
      final s = ExperimentSession(
        data,
        ExperimentSettings(experiment: task, nEstimators: 5),
      )..start();
      expect(
        s.predict([
          [0, 0],
        ]),
        [0],
      );
      expect(s.forestSummary!.trees, 5);
      expect(s.forestSummary!.samplesPerTree, split.train.length);
      expect(s.forestSummary!.featuresPerSplit, 1);
      expect(s.forestSummary!.depth, 0);
      expect(s.forestSummary!.leaves, 5);
      expect(s.treeRoot(), isNull);
      expect(s.treeRoot(alternate: true)!.sampleCount, split.train.length);
      expect(s.step(), isFalse);
      expect(s.history, isEmpty);
      expect(s.comparisonHistory, isEmpty);
    }
  });
  test('one forest tree differs from the full-training all-feature comparison at the same depth', () {
    final c = LabViewModel()
      ..select(Experiment.forestRegression)
      ..configure(nEstimators: 1, maxDepth: 6)
      ..start();
    addTearDown(c.dispose);
    expect(c.status, RunStatus.complete);
    expect(c.forestSummary!.trees, 1);
    expect(c.forestSummary!.depth, lessThanOrEqualTo(6));
    final expected = ExperimentSession(
      c.data,
      ExperimentSettings(experiment: Experiment.treeRegression, maxDepth: 6),
    )..start();
    expect(c.plot.samples!.b, expected.predict(c.plot.samples!.rows));
    expect(c.plot.samples!.a, isNot(c.plot.samples!.b));
    expect(c.data.x.map((r) => r[1]).toSet().length, greaterThan(1));
  });
  test('count and depth invalidate immutable cached plots; seeded forest tasks repeat', () {
    for (final task in [
      Experiment.forestClassification,
      Experiment.forestRegression,
    ]) {
      expect(task.isTree, isFalse);
      expect(task.isTreeBased, isTrue);
      final c = LabViewModel()
        ..select(task)
        ..start();
      final other = LabViewModel()
        ..select(task)
        ..start();
      addTearDown(c.dispose);
      addTearDown(other.dispose);
      expect(
        c.score(c.split.validation)!.value,
        other.score(other.split.validation)!.value,
      );
      final plot = c.plot, predictions = List<double>.of(c.plot.samples!.a);
      expect(c.plot, same(plot));
      c.configure(nEstimators: 25, maxDepth: 1);
      expect(c.status, RunStatus.ready);
      expect(c.forestSummary, isNull);
      expect(c.plot, isNot(same(plot)));
      c.start();
      expect(c.forestSummary!.trees, 25);
      expect(c.forestSummary!.depth, lessThanOrEqualTo(1));
      expect(c.treeRoot(alternate: true)!.depth, lessThanOrEqualTo(1));
      expect(plot.samples!.a, predictions);
      expect(() => plot.samples!.a[0] = 9, throwsUnsupportedError);
    }
  });
  test('forest settings and binary CSV reject changes without replacing completed results', () {
    for (final n in [0, 26]) {
      expect(() => ExperimentSettings(nEstimators: n), throwsArgumentError);
    }
    final c = LabViewModel()
      ..select(Experiment.forestClassification)
      ..start();
    addTearDown(c.dispose);
    final data = c.data, plot = c.plot;
    expect(() => c.configure(nEstimators: 0), throwsArgumentError);
    expect(
      () => c.importCsv(
        'x1,x2,y\n${List.generate(20, (i) => '$i,0,2').join('\n')}',
      ),
      throwsA(isA<LabDataException>()),
    );
    expect(c.status, RunStatus.complete);
    expect(c.data, same(data));
    expect(c.plot, same(plot));
    c.select(Experiment.forestRegression);
    c.importCsv(
      'x1,x2,y\n${List.generate(20, (i) => '$i,0,${i * 2 + .5}').join('\n')}',
    );
    c.start();
    expect(c.score(c.split.validation)!.metric, ScoreMetric.rmse);
  });
}
