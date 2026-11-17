import 'validation.dart';

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
  validateMetricVectors(y, predicted);
  if ([...y, ...predicted].any((v) => v != 0 && v != 1)) {
    throw ArgumentError('Binary labels 0/1 required.');
  }
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
