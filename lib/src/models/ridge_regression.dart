import 'gradient_model.dart';

/// Full-batch Ridge with J = mean((prediction-y)^2)/2 + lambda*||w||²/2.
///
/// The intercept is not penalized. Lambda must be finite and nonnegative; zero
/// gives the same updates as `LinearRegression`. Scale features using training
/// rows only and select lambda on validation data, not the final test set.
/// Unlike a sum-loss convention, lambda is invariant to duplicating all rows.
/// Large learning rates can diverge; no closed-form solver is used.
class RidgeRegression extends GradientModel {
  double get lambda => l2Penalty;

  RidgeRegression({
    double lambda = 1,
    super.learningRate = .05,
    super.iterations = 1000,
  }) : super(logistic: false, l2Penalty: lambda);
}
