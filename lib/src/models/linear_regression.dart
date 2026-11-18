import 'gradient_model.dart';

/// Multivariate linear regression with an intercept and full-batch descent.
///
/// Minimizes mean((prediction-target)²)/2. Fit a scaler on training rows for
/// unequal feature magnitudes. No closed-form solver, automatic rate selection
/// or convergence-based early stopping is performed.
///
/// ```dart
/// final model = LinearRegression(learningRate: .05, iterations: 1000);
/// model.fit([[0], [1], [2]], [1, 3, 5]);
/// final predictions = model.predict([[1.5]]);
/// ```
class LinearRegression extends GradientModel {
  /// Creates an unfitted linear model with a positive finite [learningRate].
  ///
  /// [iterations] must be positive; invalid settings throw [ArgumentError].
  /// See [GradientModel.fit] for synchronous training and failure-state semantics.
  LinearRegression({super.learningRate = .05, super.iterations = 1000})
    : super(logistic: false);
}
