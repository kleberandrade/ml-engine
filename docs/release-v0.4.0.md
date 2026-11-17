# v0.4.0 — Decision tree classification and regression

- Add pure Dart DecisionTreeClassifier (Gini) and DecisionTreeRegressor (squared error) with maxDepth, minSamplesLeaf and deterministic greedy rules.
- Expose immutable fitted nodes, actual depth and leaf counts. Fit commits atomically; failures preserve the previous tree. Depth starts at zero; pure/unsplittable nodes stop early.
- Handle threshold midpoints without sum overflow and fall back to the lower adjacent value when rounding reaches the upper value.
- Add PT/EN lab tree modes, depth 1–6 controls, comparison with depth 1, minimum two training rows per leaf, first-rule summaries and sampled plots. No fake optimizer epochs/rates/cost history.
- Explain greedy limits, overfitting, validation, axis-aligned regions and piecewise-constant predictions. No pruning, missing/categorical handling or probabilities are included.
- 49 Dart tests and 38 Flutter tests pass locally. Independent fixtures, ties/stopping, leakage, recovery, threshold edges, language/navigation and mobile interactions are covered.

[Live laboratory](https://kleberandrade.github.io/ml-engine/) · [Dart package](https://pub.dev/packages/ml_engine/versions/0.4.0) · [Source](https://github.com/kleberandrade/ml-engine)

Publication verified on November 17, 2026: [CI and Pages run 44191198810](https://github.com/kleberandrade/ml-engine/actions/runs/44191198810) succeeded for source `5b2ec7435e816fba7492f0805b9a1a6d55fdd503`. Pub.dev accepted version 0.4.0; its 24,692-byte archive matches the validated core. An independent hosted consumer recovered threshold 1.5, classes [0,1] and leaf means [1,11]. See [public archive metadata](pub-v0.4.0.json). The source tag identifies that package's code; later evidence/README commits do not republish it. The Flutter app remains excluded from pub.dev.
