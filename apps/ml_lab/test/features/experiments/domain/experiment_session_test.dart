import 'package:flutter_test/flutter_test.dart';
import 'package:ml_engine/ml_engine.dart';
import 'package:ml_lab/features/experiments/data/experiment_datasets.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';
import 'package:ml_lab/features/experiments/domain/experiment_session.dart';

void main() {
  test(
    'dataset generation is seeded and sessions learn train-only scaling',
    () {
      final settings = ExperimentSettings(
        experiment: Experiment.regression,
        seed: 42,
      );
      final data = generateDataset(settings);
      expect(data.x, generateDataset(settings).x);
      expect(data.y, generateDataset(settings).y);
      final session = ExperimentSession(data, settings)..start();
      while (session.step()) {}
      final score = session.evaluate(session.split.test)!;
      expect(score.metric, ScoreMetric.rmse);
      expect(score.value, closeTo(.389, .002));
      for (var j = 0; j < 2; j++) {
        final sum = session.split.train.fold(
          0.0,
          (s, i) => s + session.scaled[i][j],
        );
        expect(sum, closeTo(0, 1e-10));
      }
    },
  );
  test('binary and clustering scores preserve independent semantics', () {
    for (final experiment in [
      Experiment.classification,
      Experiment.clustering,
    ]) {
      final settings = ExperimentSettings(experiment: experiment);
      final session = ExperimentSession(generateDataset(settings), settings)
        ..start();
      while (session.step()) {}
      final score = session.evaluate(session.split.test)!;
      expect(
        score.metric,
        experiment == Experiment.clustering
            ? ScoreMetric.meanSquaredDistance
            : ScoreMetric.accuracy,
      );
      expect(
        score.value,
        experiment == Experiment.clustering
            ? closeTo(.207, .002)
            : closeTo(28 / 30, 1e-12),
      );
    }
  });
  test('invalid lab configuration and bad CSV fail at the boundary', () {
    expect(
      () => ExperimentSettings(learningRate: double.nan),
      throwsArgumentError,
    );
    expect(() => ExperimentSettings(epochs: 0), throwsArgumentError);
    expect(
      () => parseLabCsv(
        'x1,x2,y\n${List.generate(10, (i) => '$i,0,2').join('\n')}',
        Experiment.classification,
      ),
      throwsFormatException,
    );
    final data = Dataset(
      List.generate(20, (_) => [1.0, 1.0]),
      List.filled(20, 0),
    );
    final session = ExperimentSession(
      data,
      ExperimentSettings(experiment: Experiment.clustering),
    );
    expect(session.start, throwsArgumentError);
  });
  test(
    'lab sessions reject feature shapes that the two-axis UI cannot represent',
    () {
      final data = Dataset(
        List.generate(20, (i) => [i.toDouble()]),
        List.filled(20, 0),
      );
      expect(
        () => ExperimentSession(data, ExperimentSettings()),
        throwsArgumentError,
      );
    },
  );
}
