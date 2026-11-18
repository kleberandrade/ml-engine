import 'validation.dart';

/// Binary confusion counts and derived metrics; positive means label 1.
///
/// Use [classificationMetrics] to validate label vectors and calculate counts.
/// The direct constructor stores supplied counts without validation.
class ClassificationMetrics {
  /// Rows with actual label 1 and predicted label 1.
  final int truePositive;

  /// Rows with actual label 0 and predicted label 0.
  final int trueNegative;

  /// Rows with actual label 0 and predicted label 1 (false alarms).
  final int falsePositive;

  /// Rows with actual label 1 and predicted label 0 (misses).
  final int falseNegative;

  /// Stores confusion counts in TP, TN, FP, FN order.
  ///
  /// Counts should be nonnegative. This constructor does not check that invariant
  /// or require a positive total; [classificationMetrics] does so through its inputs.
  const ClassificationMetrics(
    this.truePositive,
    this.trueNegative,
    this.falsePositive,
    this.falseNegative,
  );

  /// Fraction of correct predictions: (TP + TN) / total.
  ///
  /// Returns NaN when all directly constructed counts are zero; results from
  /// [classificationMetrics] always have a positive total.
  double get accuracy =>
      (truePositive + trueNegative) /
      (truePositive + trueNegative + falsePositive + falseNegative);

  /// TP / (TP + FP), or 0 when no positive prediction exists.
  double get precision => _ratio(truePositive, truePositive + falsePositive);

  /// TP / (TP + FN), or 0 when no actual positive exists.
  double get recall => _ratio(truePositive, truePositive + falseNegative);

  /// Harmonic mean of [precision] and [recall], or 0 when their sum is zero.
  double get f1 => _ratio(2 * precision * recall, precision + recall);
  double _ratio(num a, num b) => b == 0 ? 0 : a / b;
}

/// Calculates binary confusion counts for actual [y] and [predicted] labels.
///
/// Both vectors must be nonempty, equal length and contain only finite 0/1 values.
/// Throws [ArgumentError] otherwise. Predictions must already be thresholded;
/// passing probabilities or multiclass labels is an error. Class 1 is positive.
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
