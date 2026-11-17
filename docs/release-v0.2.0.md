# v0.2.0 — Ridge regression and interactive regularization

- Add pure Dart `RidgeRegression` with configurable nonnegative lambda, an unpenalized intercept, stepwise/full-batch training and finite-update recovery.
- Explicit objective: mean((prediction-y)²)/2 + lambda*sum(w²)/2. Lambda=0 matches LinearRegression exactly; a sum-loss convention uses alpha=n*lambda.
- Add a Ridge/linear lab with correlated-feature data, lambda controls, coefficient norms, equal split/scaler/rate/initialization/budget, EN/PT-BR explanations and an executable Learn/Examples preset.
- Compare validation RMSE rather than penalized/unpenalized objective heights. Regularization does not guarantee a better test score.
- 31 core tests and 26 Flutter tests pass locally; analysis, boundary checks and the repository-path release build are validated. Final CI/publication is auditable through the repository workflow and public package/version endpoints.
- Publish the 17,085-byte core-only package archive to pub.dev; retain `publish_to: none` for the Flutter lab. No credentials are added to repository workflows.

[Live laboratory](https://kleberandrade.github.io/ml-engine/) · [Dart package](https://pub.dev/packages/ml_engine/versions/0.2.0) · [Source](https://github.com/kleberandrade/ml-engine)

Publication verified on November 17, 2026: [CI and Pages run 44184785601](https://github.com/kleberandrade/ml-engine/actions/runs/44184785601) succeeded for application/package-source commit `423fd82247fe324fae884d0260cb95916b6dfd5c`. The pub.dev API reports 0.2.0, and an independent hosted-dependency consumer recovered the expected Ridge coefficient 0.5. Archive SHA-256 and checks are recorded in [pub-v0.2.0.json](pub-v0.2.0.json). The source release tag identifies the code used for that package; later documentation/capture commits do not republish it.
