## Classical ML in pure Dart

Initial usable release of ML Engine, with a pure Dart core and a separate Flutter Web learning laboratory.

### Included

- Linear and binary logistic regression with full-batch gradient descent, stable logistic loss and cost history.
- Seeded K-means++ initialization and iterative centroid updates.
- StandardScaler, MinMaxScaler, fit/transform/predict pipelines and train-only preprocessing.
- Seeded train/validation/test splitting, K-fold, stratified K-fold and fresh-pipeline cross validation.
- Regression and binary classification metrics, finite-value/shape checks and explicit degenerate-case handling.
- Synthetic data and validated numeric CSV in the Flutter lab, scatter plots, fitted lines, boundaries, centroids, cost curves and equal-budget A/B comparison.
- Pause, resume, cancel and restart controls with bounded incremental training.

### Validation

16 Dart numerical/boundary tests and 5 Flutter interaction/accessibility tests. The Verify workflow runs format checks, both analyzers, both test suites, CLI examples and a release Flutter Web build. Local browser evidence and the 95.3% core line-coverage measurement are documented in `docs/validation.md`.

Validated toolchain: Dart 3.14.0 and Flutter 3.50.0. The Web build is JavaScript/CanvasKit; native platform builds and Wasm are not claimed. Screenshots are real local browser captures.

### Use

Clone the repository, run `dart pub get`, `dart test`, and `dart run example/main.dart`. For the lab, enter `apps/ml_lab/`, run `flutter pub get`, then `flutter run -d chrome`. See the README for release build commands and numerical conventions.

### Scope

This is a GitHub source release under MIT. No package has been published to pub.dev; `publish_to: none` remains in place. Ridge/KNN, trees/Random Forest/Gradient Boosting, PCA, permutation importance and SHAP are documented future work, not included functionality. No official XGBoost integration or SHAP implementation is claimed.
