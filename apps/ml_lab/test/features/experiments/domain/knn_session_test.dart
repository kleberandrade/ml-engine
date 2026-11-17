import 'package:flutter_test/flutter_test.dart';
import 'package:ml_engine/ml_engine.dart';
import 'package:ml_lab/features/experiments/application/lab_view_model.dart';
import 'package:ml_lab/features/experiments/data/experiment_datasets.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';
import 'package:ml_lab/features/experiments/domain/experiment_session.dart';
import 'package:ml_lab/features/experiments/domain/lab_failure.dart';

void main() {
  test(
    'KNN fits only training rows and has no invented iterative objective',
    () {
      final split = trainValidationTestSplit(20);
      final data = Dataset(
        List.generate(20, (_) => [0.0, 0.0]),
        List.generate(20, (i) => split.train.contains(i) ? 0.0 : 1.0),
      );
      final session = ExperimentSession(
        data,
        ExperimentSettings(experiment: Experiment.knnClassification),
      )..start();
      expect(
        session.predict([
          [0, 0],
        ]),
        [0],
      ); // Held-out labels must never vote.
      expect(session.evaluate(split.test)!.value, 0);
      expect(session.history, isEmpty);
      expect(session.comparisonHistory, isEmpty);
      expect(session.step(), isFalse);
      expect(session.hasResults, isTrue);
    },
  );

  test(
    'KNN k=1 comparison is identical for both tasks, using train-only scaling',
    () {
      for (final experiment in [
        Experiment.knnClassification,
        Experiment.knnRegression,
      ]) {
        final settings = ExperimentSettings(
          experiment: experiment,
          neighbors: 1,
        );
        final data = generateDataset(settings);
        expect(data.x, generateDataset(settings).x);
        final session = ExperimentSession(data, settings)..start();
        for (var j = 0; j < 2; j++) {
          expect(
            session.split.train.fold(0.0, (s, i) => s + session.scaled[i][j]),
            closeTo(0, 1e-10),
          );
        }
        expect(
          session.evaluate(session.split.validation)!.value,
          session.evaluate(session.split.validation, alternate: true)!.value,
        );
        expect(
          session.evaluate(session.split.test)!.metric,
          experiment.isRegression ? ScoreMetric.rmse : ScoreMetric.accuracy,
        );
      }
    },
  );

  test(
    'invalid k and rejected small or nonbinary CSV preserve completed state',
    () {
      for (final k in [0, 16]) {
        expect(() => ExperimentSettings(neighbors: k), throwsArgumentError);
      }
      expect(
        () => ExperimentSession(
          Dataset(List.generate(20, (_) => [0.0, 0.0]), List.filled(20, 2)),
          ExperimentSettings(experiment: Experiment.knnClassification),
        ),
        throwsA(
          isA<LabDataException>().having(
            (e) => e.code,
            'code',
            LabDataError.binaryLabels,
          ),
        ),
      );
      final c = LabViewModel()
        ..select(Experiment.knnClassification)
        ..configure(neighbors: 15)
        ..start();
      addTearDown(c.dispose);
      final data = c.data;
      expect(
        () => c.importCsv(
          'x1,x2,y\n${List.generate(10, (i) => '$i,0,1').join('\n')}',
        ),
        throwsA(
          isA<LabDataException>().having(
            (e) => e.code,
            'code',
            LabDataError.neighbors,
          ),
        ),
      );
      expect(
        () => c.importCsv(
          'x1,x2,y\n${List.generate(30, (i) => '$i,0,2').join('\n')}',
        ),
        throwsA(
          isA<LabDataException>().having(
            (e) => e.code,
            'code',
            LabDataError.binaryLabels,
          ),
        ),
      );
      expect(c.data, same(data));
      expect(c.status, RunStatus.complete);
      c.configure(neighbors: 5);
      c.importCsv('x1,x2,y\n${List.generate(10, (i) => '$i,0,1').join('\n')}');
      expect(c.maxNeighbors, 6);
    },
  );

  test('cached KNN plot samples are immutable and reset when k changes', () {
    for (final experiment in [
      Experiment.knnClassification,
      Experiment.knnRegression,
    ]) {
      final c = LabViewModel()
        ..select(experiment)
        ..start();
      final first = c.plot;
      expect(c.plot, same(first));
      final samples = first.samples!;
      expect(samples.a.length, experiment.isRegression ? 60 : 384);
      expect(() => samples.a[0] = 999, throwsUnsupportedError);
      expect(() => samples.rows[0][0] = 999, throwsUnsupportedError);
      final old = List<double>.of(samples.a);
      c.configure(neighbors: 1);
      expect(c.status, RunStatus.ready);
      expect(c.plot.samples, isNull);
      c.start();
      expect(c.plot, isNot(same(first)));
      expect(first.samples!.a, old);
      c.dispose();
    }
  });
}
