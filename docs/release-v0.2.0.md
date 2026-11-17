# v0.2.0 — Ridge regression and interactive regularization

- Add pure Dart `RidgeRegression` with configurable nonnegative lambda, an unpenalized intercept, stepwise/full-batch training and finite-update recovery.
- Explicit objective: mean((prediction-y)²)/2 + lambda*sum(w²)/2. Lambda=0 matches LinearRegression exactly; a sum-loss convention uses alpha=n*lambda.
- Add a Ridge/linear lab with correlated-feature data, lambda controls, coefficient norms, equal split/scaler/rate/initialization/budget, EN/PT-BR explanations and an executable Learn/Examples preset.
- Compare validation RMSE rather than penalized/unpenalized objective heights. Regularization does not guarantee a better test score.
- 31 core tests and 26 Flutter tests pass locally; analysis, boundary checks and the repository-path release build are validated. Final CI/publication is auditable through the repository workflow and public package/version endpoints.
- Prepare a small core-only package archive; retain `publish_to: none` for the Flutter lab. No credentials are added to repository workflows.

[Live laboratory](https://kleberandrade.github.io/ml-engine/) · [Dart package](https://pub.dev/packages/ml_engine/versions/0.2.0) · [Source](https://github.com/kleberandrade/ml-engine)
