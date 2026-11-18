# v0.6.0 — Gradient Boosting classification and regression

- Add pure Dart GradientBoostingRegressor (squared loss) and binary GradientBoostingClassifier (logistic loss), composing numeric regression trees with shrinkage.
- Control tree count, depth, minimum leaf size and rate; expose start/step/fit, probabilities and immutable fitted trees/real loss histories.
- Commit whole fits and individual stages atomically. Explain clipped prior initialization, first-order gradients, no Newton leaf corrections/line search/subsampling/automatic early stopping, and no XGBoost equivalence.
- Add PT/EN Flutter modes with count/depth/rate controls, equal-budget rate-only A/B, observable stages, loss curves, pause/resume/cancel/restart and nonlinear presets.
- 69 Dart and 50 Flutter tests pass locally, covering independent numerical fixtures, error recovery, ownership, leakage, lifecycle, real controls, bilingual navigation and mobile 150% text.

[Live laboratory](https://kleberandrade.github.io/ml-engine/) · [Dart package](https://pub.dev/packages/ml_engine/versions/0.6.0) · [Source](https://github.com/kleberandrade/ml-engine)
