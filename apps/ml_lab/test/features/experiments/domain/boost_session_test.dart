import 'package:flutter_test/flutter_test.dart';
import 'package:ml_engine/ml_engine.dart';
import 'package:ml_lab/features/experiments/application/lab_view_model.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';
import 'package:ml_lab/features/experiments/domain/experiment_session.dart';
import 'package:ml_lab/features/experiments/domain/lab_failure.dart';

void main() {
  test('boosting uses only training targets and exposes real stages including initial loss', () {
    final split = trainValidationTestSplit(20);
    for (final task in [
      Experiment.boostClassification,
      Experiment.boostRegression,
    ]) {
      final s = ExperimentSession(
        Dataset(
          List.generate(20, (_) => [0.0, 0.0]),
          List.generate(20, (i) => split.train.contains(i) ? 0.0 : 1.0),
        ),
        ExperimentSettings(experiment: task, nEstimators: 3),
      )..start();
      expect(task.isDirect, isFalse);
      expect(task.isTreeBased, isTrue);
      expect(s.boostSummary()!.stages, 0);
      expect(s.history, hasLength(1));
      while (s.step()) {}
      expect(
        s.predict([
          [0, 0],
        ]),
        [0],
      );
      expect(s.boostSummary()!.stages, 3);
      expect(s.history, hasLength(4));
      expect(s.boostSummary()!.depth, 0);
      expect(s.comparisonHistory, hasLength(4));
      expect(s.treeRoot(), isNull);
      expect(s.forestSummary, isNull);
    }
  });
  test(
    'session comparison exactly matches independently fitted rate-only A and B',
    () {
      final c = LabViewModel()
        ..select(Experiment.boostRegression)
        ..configure(nEstimators: 5, maxDepth: 2, learningRate: .2)
        ..start();
      addTearDown(c.dispose);
      final s = ExperimentSession(
        c.data,
        ExperimentSettings(experiment: Experiment.boostRegression),
      );
      final train = c.split.train.map((i) => s.scaled[i]).toList(),
          y = c.split.train.map((i) => c.data.y[i]).toList();
      final a = GradientBoostingRegressor(
        nEstimators: 5,
        maxDepth: 2,
        minSamplesLeaf: 2,
        learningRate: .2,
      )..fit(train, y);
      final b = GradientBoostingRegressor(
        nEstimators: 5,
        maxDepth: 2,
        minSamplesLeaf: 2,
        learningRate: .05,
      )..fit(train, y);
      while (c.status == RunStatus.running) {
        c.advance();
      }
      expect(c.plot.samples!.a, a.predict(c.plot.samples!.rows));
      expect(c.plot.samples!.b, b.predict(c.plot.samples!.rows));
      expect(c.history, a.lossHistory);
      expect(c.comparisonHistory, b.lossHistory);
      expect(c.boostSummary()!.depth, lessThanOrEqualTo(2));
      expect(c.data.x.map((r) => r[1]).toSet().length, greaterThan(1));
    },
  );
  testWidgets(
    'pause resume cancel and parameter changes preserve immutable stage snapshots',
    (tester) async {
      final c = LabViewModel()
        ..select(Experiment.boostClassification)
        ..start();
      addTearDown(c.dispose);
      await tester.pump(const Duration(milliseconds: 48));
      c.pauseResume();
      final count = c.boostSummary()!.stages,
          plot = c.plot,
          values = List.of(c.plot.samples!.a);
      expect(count, greaterThan(0));
      await tester.pump(const Duration(seconds: 1));
      expect(c.boostSummary()!.stages, count);
      expect(() => c.configure(nEstimators: 1), throwsStateError);
      c.pauseResume();
      await tester.pump(const Duration(milliseconds: 32));
      c.cancel();
      expect(c.status, RunStatus.cancelled);
      expect(c.boostSummary()!.stages, greaterThan(count));
      expect(plot.samples!.a, values);
      expect(() => plot.samples!.a[0] = 9, throwsUnsupportedError);
      c.configure(nEstimators: 1, maxDepth: 1, learningRate: .3);
      expect(c.status, RunStatus.ready);
      expect(c.history, isEmpty);
      expect(c.plot.samples, isNull);
      c.start();
      await tester.pump(const Duration(seconds: 1));
      expect(c.status, RunStatus.complete);
      expect(c.boostSummary()!.stages, 1);
      expect(c.history, hasLength(2));
    },
  );
  test('invalid CSV and bounds preserve completed models and settings', () {
    final c = LabViewModel()
      ..select(Experiment.boostClassification)
      ..configure(nEstimators: 1)
      ..start();
    addTearDown(c.dispose);
    while (c.status == RunStatus.running) {
      c.advance();
    }
    final data = c.data, history = c.history;
    expect(
      () => c.importCsv(
        'x1,x2,y\n${List.generate(20, (i) => '$i,0,2').join('\n')}',
      ),
      throwsA(isA<LabDataException>()),
    );
    expect(() => c.configure(nEstimators: 26), throwsArgumentError);
    expect(() => c.configure(maxDepth: 7), throwsArgumentError);
    expect(() => c.configure(learningRate: double.nan), throwsArgumentError);
    expect(c.status, RunStatus.complete);
    expect(c.data, same(data));
    expect(c.history, same(history));
  });
}
