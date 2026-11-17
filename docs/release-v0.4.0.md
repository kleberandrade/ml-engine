# v0.4.0 — Decision tree classification and regression

- Add pure Dart DecisionTreeClassifier (Gini) and DecisionTreeRegressor (squared error) with maxDepth, minSamplesLeaf and deterministic greedy rules.
- Expose immutable fitted nodes, actual depth and leaf counts. Fit commits atomically; failures preserve the previous tree. Depth starts at zero; pure/unsplittable nodes stop early.
- Handle threshold midpoints without sum overflow and fall back to the lower adjacent value when rounding reaches the upper value.
- Add PT/EN lab tree modes, depth 1–6 controls, comparison with depth 1, minimum two training rows per leaf, first-rule summaries and sampled plots. No fake optimizer epochs/rates/cost history.
- Explain greedy limits, overfitting, validation, axis-aligned regions and piecewise-constant predictions. No pruning, missing/categorical handling or probabilities are included.
- 49 Dart tests and 38 Flutter tests pass locally. Independent fixtures, ties/stopping, leakage, recovery, threshold edges, language/navigation and mobile interactions are covered.

[Live laboratory](https://kleberandrade.github.io/ml-engine/) · [Dart package](https://pub.dev/packages/ml_engine/versions/0.4.0) · [Source](https://github.com/kleberandrade/ml-engine)

Publication follows CI verification; public package/version and workflow endpoints provide the final result. The Flutter app remains excluded from pub.dev.
