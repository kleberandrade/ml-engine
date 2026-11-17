# ADR 0005: Ridge mean loss and equal-budget comparison

## Status

Accepted — November 17, 2026.

## Context

Ridge should reuse the existing pure Dart full-batch optimizer and start/step lifecycle without altering linear/logistic behavior. The lab must isolate regularization from learning rate, display comparable validation metrics and retain the same ownership/dependency boundaries. The user additionally authorized publishing the core to pub.dev.

## Decision

Expose `RidgeRegression(lambda: 1, learningRate: .05, iterations: 1000)` through `lib/ml_engine.dart`. Minimize mean squared residual / 2 + lambda*sum(weights²)/2. The weight derivative is Xᵀ residual/n + lambda*w; the bias derivative is mean residual. The intercept is unpenalized. Lambda must be finite/nonnegative. A zero penalty takes the exact existing arithmetic path, preserving linear coefficients and history. Validate the penalized candidate cost before committing an update.

Reuse GradientModel with an optional zero-default L2 term instead of duplicating its data validation, stable stepping and failure semantics. A closed-form inverse/solver would require a new numerical subsystem and would remove the stepwise teaching behavior: deferred. Mean loss makes lambda invariant to duplicating every training row; conversion to a sum-loss convention is alpha=n*lambda.

The lab adds a regression experiment: A=Ridge and B=LinearRegression at identical rate, zero initialization, budget, train split and train-fitted scaler. A generated correlated-feature dataset and coefficient norms show shrinkage. Lambda ranges from 0 to 3 and cannot change during an active/paused run. Both models report validation RMSE; cost histories deliberately retain their own objectives and the UI warns that curve heights are not comparable. Plots are slices at standardized x₂=0. Regularization may underfit or fail to improve test performance.

## Packaging

The Dart package becomes 0.2.0 and may publish to the default pub.dev host. The Flutter manifest retains `publish_to: none`. `.pubignore` removes the Flutter app, generated output, tools and repository documentation; README references point to the public repository. CI dry-runs publication without credentials or upload. Actual publication uses the user's existing local pub.dev session after verification; automated publishing credentials are not added to GitHub.

## Verification and limits

Independent fixtures check the orthogonal closed-form result, exact lambda-zero equality, the first two gradient steps/objectives, duplicate-row invariance, unpenalized constant-target intercepts, collinear features and safe overflow. Session/widget tests verify equal-budget comparison, shrinkage, continuous-target CSV, bound validation, language/pause preservation and narrow scaled text. Training remains synchronous in the core and bounded/yielding in the lab; no exact solver or automatic lambda search is claimed.
