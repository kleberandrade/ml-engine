import 'dart:math';
import 'data.dart';
import 'preprocessing.dart';

void _paired(List<double> y, List<double> predicted) {
  if (y.isEmpty ||
      y.length != predicted.length ||
      [...y, ...predicted].any((v) => !v.isFinite)) {
    throw ArgumentError('Expected matching nonempty finite vectors.');
  }
}

double meanSquaredError(List<double> y, List<double> predicted) {
  _paired(y, predicted);
  return List.generate(
        y.length,
        (i) => pow(y[i] - predicted[i], 2).toDouble(),
      ).reduce((a, b) => a + b) /
      y.length;
}

double rootMeanSquaredError(List<double> y, List<double> predicted) =>
    sqrt(meanSquaredError(y, predicted));
double meanAbsoluteError(List<double> y, List<double> predicted) {
  _paired(y, predicted);
  return List.generate(
        y.length,
        (i) => (y[i] - predicted[i]).abs(),
      ).reduce((a, b) => a + b) /
      y.length;
}

/// Constant targets: 1 for perfect predictions, 0 otherwise.
double rSquared(List<double> y, List<double> predicted) {
  _paired(y, predicted);
  final mean = y.reduce((a, b) => a + b) / y.length;
  final variance = y.fold(0.0, (s, v) => s + pow(v - mean, 2));
  final residual = meanSquaredError(y, predicted) * y.length;
  return variance == 0 ? (residual == 0 ? 1 : 0) : 1 - residual / variance;
}

class ClassificationMetrics {
  final int truePositive, trueNegative, falsePositive, falseNegative;
  const ClassificationMetrics(
    this.truePositive,
    this.trueNegative,
    this.falsePositive,
    this.falseNegative,
  );
  double get accuracy =>
      (truePositive + trueNegative) /
      (truePositive + trueNegative + falsePositive + falseNegative);
  double get precision => _ratio(truePositive, truePositive + falsePositive);
  double get recall => _ratio(truePositive, truePositive + falseNegative);
  double get f1 => _ratio(2 * precision * recall, precision + recall);
  double _ratio(num a, num b) => b == 0 ? 0 : a / b;
}

ClassificationMetrics classificationMetrics(
  List<double> y,
  List<double> predicted,
) {
  _paired(y, predicted);
  if ([...y, ...predicted].any((v) => v != 0 && v != 1))
    throw ArgumentError('Binary labels 0/1 required.');
  var tp = 0, tn = 0, fp = 0, fn = 0;
  for (var i = 0; i < y.length; i++) {
    if (y[i] == 1) {
      predicted[i] == 1 ? tp++ : fn++;
    } else {
      predicted[i] == 0 ? tn++ : fp++;
    }
  }
  return ClassificationMetrics(tp, tn, fp, fn);
}

/// Factory must return a NEW pipeline for every fold. Each scaler sees train only.
List<double> crossValidate(
  Matrix x,
  List<double> y,
  List<Fold> folds,
  Pipeline Function() createPipeline,
  double Function(List<double>, List<double>) metric,
) {
  validateTargets(x, y);
  if (folds.isEmpty) throw ArgumentError('At least one fold required.');
  final used = <Pipeline>{};
  final transformers = <Transformer>{};
  final estimators = <Object>{};
  return folds.map((fold) {
    final all = [...fold.train, ...fold.test];
    if (fold.train.isEmpty ||
        fold.test.isEmpty ||
        all.any((i) => i < 0 || i >= x.length) ||
        all.toSet().length != all.length) {
      throw ArgumentError('Fold rows must be valid, unique and disjoint.');
    }
    final pipeline = createPipeline();
    if (!used.add(pipeline) ||
        !transformers.add(pipeline.transformer) ||
        !estimators.add(pipeline.estimator)) {
      throw ArgumentError(
        'Create a fresh pipeline, transformer and estimator per fold.',
      );
    }
    pipeline.fit(
      fold.train.map((i) => x[i]).toList(),
      fold.train.map((i) => y[i]).toList(),
    );
    return metric(
      fold.test.map((i) => y[i]).toList(),
      pipeline.predict(fold.test.map((i) => x[i]).toList()),
    );
  }).toList();
}
