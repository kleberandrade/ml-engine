import '../data/matrix.dart';
import '../models/estimator.dart';
import '../preprocessing/transformer.dart';

/// Construct a fresh transformer and estimator for each validation fold.
///
/// A failed fit invalidates this composition until a successful fit. Generic
/// components cannot be rolled back; do not refit them outside this pipeline.
class Pipeline implements Estimator {
  /// Preprocessor owned by this composition; do not refit it outside the pipeline.
  final Transformer transformer;

  /// Supervised model trained on transformed rows; do not refit it independently.
  final Estimator estimator;
  bool _fitted = false;

  /// Composes the supplied [transformer] and [estimator] without cloning them.
  ///
  /// Both instances must be fresh for each validation fold. Construction does not
  /// fit either component.
  Pipeline(this.transformer, this.estimator);

  /// Fits preprocessing and the estimator on [x]/[y], invalidating old state first.
  ///
  /// Even an invalid-input failure leaves this pipeline unusable until a later
  /// successful fit. Component exceptions propagate and may leave individual
  /// components changed. Use a separate candidate pipeline to preserve a serving
  /// model. Validates finite aligned targets before fitting preprocessing.
  @override
  void fit(Matrix x, List<double> y) {
    _fitted = false;
    validateTargets(x, y);
    transformer.fit(x);
    estimator.fit(transformer.transform(x), y);
    _fitted = true;
  }

  /// Applies the fitted preprocessing without predicting or learning new statistics.
  ///
  /// Throws [StateError] before a successful pipeline fit, including after a failed
  /// refit. Input/overflow exceptions from the transformer propagate. Returns new
  /// transformed rows; this method is useful when inspecting the model's input.
  Matrix transform(Matrix x) {
    if (!_fitted) throw StateError('Fit the pipeline successfully first.');
    return transformer.transform(x);
  }

  /// Transforms raw query rows with the fitted scaler, then predicts in row order.
  ///
  /// Throws [StateError] before a successful fit or after a failed refit.
  /// Transformer/estimator input and numerical exceptions propagate. Do not
  /// pass already transformed rows; this method applies preprocessing itself.
  @override
  List<double> predict(Matrix x) => estimator.predict(transform(x));
}
