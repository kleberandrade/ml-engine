# v0.5.0 — Random Forest classification and regression

- Pure Dart seeded bootstrap forests with per-node random features, nEstimators/maxDepth/minSamplesLeaf/maxFeatures controls, hard class votes and averaged regression predictions.
- Immutable fitted trees, bag indices and seeds, aggregate depth/leaves and atomic refit recovery. Standalone decision trees preserve their all-feature defaults.
- PT/EN Flutter forest modes with 1–25 trees, depth 1–6, comparison to a full-training all-feature tree at equal depth and two-feature nonlinear regression data.
- Explicit sampling/tie/stopping conventions, conditional plots and validation advice. No invented optimizer history or unimplemented OOB/importance/probability claims.
- Numerical, sampling, failure recovery, leakage, controls, language/navigation and mobile tests.

[Live laboratory](https://kleberandrade.github.io/ml-engine/) · [Dart package](https://pub.dev/packages/ml_engine/versions/0.5.0) · [Source](https://github.com/kleberandrade/ml-engine)
