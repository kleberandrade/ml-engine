import '../data/matrix.dart';
import 'gradient_model.dart';

/// Binary logistic regression with an intercept and stable sigmoid loss.
///
/// Requires numeric labels 0/1. Full-batch descent minimizes mean binary cross
/// entropy. [predict] thresholds at .5, while [probabilities] returns class-1
/// scores. Scores are not independently calibrated probabilities; choose any
/// application-specific threshold and decision costs on validation data.
class LogisticRegression extends GradientModel {
  /// Creates an unfitted binary model with positive rate and iteration budget.
  ///
  /// Throws [ArgumentError] for nonfinite/nonpositive [learningRate] or
  /// [iterations] < 1. See [GradientModel.fit] for failure-state semantics.
  LogisticRegression({super.learningRate = .1, super.iterations = 1000})
    : super(logistic: true);

  /// Returns sigmoid class-1 probabilities in query row order, without thresholding.
  ///
  /// Each [x] row must have the training feature width and finite values. Throws
  /// [StateError] before initialization or on score overflow, and [ArgumentError]
  /// for invalid rows. This is an alias of inherited [rawPredictions], not logits.
  List<double> probabilities(Matrix x) => rawPredictions(x);
}
