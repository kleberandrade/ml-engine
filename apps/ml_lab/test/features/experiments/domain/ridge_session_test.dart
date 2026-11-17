import 'package:flutter_test/flutter_test.dart';
import 'package:ml_lab/features/experiments/data/experiment_datasets.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';
import 'package:ml_lab/features/experiments/domain/experiment_session.dart';

void main() {
  test(
    'Ridge and linear share all settings and match exactly at lambda zero',
    () {
      final settings = ExperimentSettings(
        experiment: Experiment.ridge,
        regularization: 0,
      );
      final data = generateDataset(settings);
      final session = ExperimentSession(data, settings)..start();
      while (session.step()) {}
      expect(session.history, session.comparisonHistory);
      expect(session.coefficientsA, session.coefficientsB);
      expect(session.interceptA, session.interceptB);
      expect(
        session.evaluate(session.split.validation)!.metric,
        ScoreMetric.rmse,
      );
      expect(
        session.evaluate(session.split.validation)!.value,
        session.evaluate(session.split.validation, alternate: true)!.value,
      );
      expect(data.x, generateDataset(settings).x);
      for (var j = 0; j < 2; j++) {
        expect(
          session.split.train.fold(0.0, (sum, i) => sum + session.scaled[i][j]),
          closeTo(0, 1e-10),
        );
      }
    },
  );

  test(
    'positive regularization shrinks weights with equal iteration budgets',
    () {
      final settings = ExperimentSettings(
        experiment: Experiment.ridge,
        regularization: 3,
      );
      final session = ExperimentSession(generateDataset(settings), settings)
        ..start();
      session.step();
      expect(
        session.coefficientsA,
        session.coefficientsB,
      ); // initial penalty gradient = 0
      while (session.step()) {}
      expect(session.history.length, settings.epochs);
      expect(session.comparisonHistory.length, settings.epochs);
      expect(
        session.coefficientNorm(),
        lessThan(session.coefficientNorm(alternate: true)),
      );
      expect(session.evaluate(session.split.test)!.value.isFinite, isTrue);
      expect(session.baseline!.metric, ScoreMetric.rmse);
    },
  );

  test('Ridge settings bound lambda and CSV accepts continuous targets', () {
    for (final value in [-1.0, 3.1, double.nan, double.infinity]) {
      expect(
        () => ExperimentSettings(regularization: value),
        throwsArgumentError,
      );
    }
    final data = parseLabCsv(
      'x1,x2,y\n${List.generate(20, (i) => '$i,${i + 1},${2 * i + .5}').join('\n')}',
      Experiment.ridge,
    );
    final settings = ExperimentSettings(experiment: Experiment.ridge);
    final session = ExperimentSession(data, settings)..start();
    while (session.step()) {}
    expect(session.evaluate(session.split.validation)!.value.isFinite, isTrue);
  });
}
