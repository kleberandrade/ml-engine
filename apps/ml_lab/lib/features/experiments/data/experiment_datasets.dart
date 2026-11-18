import 'dart:math';

import 'package:ml_engine/ml_engine.dart';

import '../domain/experiment.dart';
import '../domain/lab_failure.dart';

Dataset generateDataset(ExperimentSettings settings) {
  final random = Random(settings.seed);
  final x = <List<double>>[], y = <double>[];
  for (var i = 0; i < 150; i++) {
    final a = random.nextDouble() * 6 - 3, b = random.nextDouble() * 6 - 3;
    if (settings.experiment == Experiment.clustering) {
      final c = i % 3;
      x.add([
        a * .3 + [-2, 2, 0][c],
        b * .3 + [-1, -1, 2][c],
      ]);
      y.add(c.toDouble());
    } else if ((settings.experiment == Experiment.forestRegression ||
        settings.experiment == Experiment.boostRegression)) {
      x.add([a, b]);
      y.add(2 * sin(a) + .3 * b + 1 + (random.nextDouble() - .5) * .8);
    } else if ((settings.experiment == Experiment.knnRegression ||
        settings.experiment == Experiment.treeRegression)) {
      x.add([a, 0]);
      y.add(2 * sin(a) + 1 + (random.nextDouble() - .5) * .8);
    } else if ((settings.experiment == Experiment.knnClassification ||
        settings.experiment == Experiment.treeClassification ||
        settings.experiment == Experiment.forestClassification ||
        settings.experiment == Experiment.boostClassification)) {
      x.add([a, b]);
      y.add(a * a + b * b + (random.nextDouble() - .5) * .8 < 4 ? 1 : 0);
    } else {
      x.add([
        a,
        settings.experiment == Experiment.ridge
            ? a + .15 * b
            : (settings.experiment.isRegression ? 0 : b),
      ]);
      y.add(
        settings.experiment.isRegression
            ? 2 * a + 1 + (random.nextDouble() - .5) * 1.4
            : (a + b + (random.nextDouble() - .5) * 1.2 > 0 ? 1 : 0),
      );
    }
  }
  return Dataset(x, y);
}

Dataset parseLabCsv(String value, Experiment experiment) {
  final Dataset parsed;
  try {
    parsed = parseCsv(value);
  } on CsvFormatException catch (error) {
    throw LabDataException(
      error.code == CsvError.invalidRow
          ? LabDataError.numericRow
          : LabDataError.structure,
      row: error.row,
    );
  }
  if (parsed.x.length < 10) {
    throw const LabDataException(LabDataError.tooFewRows);
  }
  if (experiment.isClassification && parsed.y.any((v) => v != 0 && v != 1)) {
    throw const LabDataException(LabDataError.binaryLabels);
  }
  if (parsed.x.any((r) => r.any((v) => v.abs() > 1e6)) ||
      parsed.y.any((v) => v.abs() > 1e6)) {
    throw const LabDataException(LabDataError.magnitude);
  }
  return parsed;
}
