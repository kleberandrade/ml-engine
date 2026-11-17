import 'dart:math';

import 'package:ml_engine/ml_engine.dart';

import '../domain/experiment.dart';

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
    } else {
      x.add([a, settings.experiment == Experiment.regression ? 0 : b]);
      y.add(
        settings.experiment == Experiment.regression
            ? 2 * a + 1 + (random.nextDouble() - .5) * 1.4
            : (a + b + (random.nextDouble() - .5) * 1.2 > 0 ? 1 : 0),
      );
    }
  }
  return Dataset(x, y);
}

Dataset parseLabCsv(String value, Experiment experiment) {
  final parsed = parseCsv(value);
  if (parsed.x.length < 10) {
    throw const FormatException(
      'Lab needs at least 10 rows for three nonempty partitions.',
    );
  }
  if (experiment == Experiment.classification &&
      parsed.y.any((v) => v != 0 && v != 1)) {
    throw const FormatException('Classification requires labels 0 or 1.');
  }
  if (parsed.x.any((r) => r.any((v) => v.abs() > 1e6)) ||
      parsed.y.any((v) => v.abs() > 1e6)) {
    throw const FormatException('Lab magnitudes must be <= 1,000,000.');
  }
  return parsed;
}
