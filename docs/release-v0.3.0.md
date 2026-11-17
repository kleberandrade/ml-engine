# v0.3.0 — KNN classification and regression

- Add pure Dart KNNClassifier/KNNRegressor with configurable k, exact Euclidean neighbor search, uniform vote/mean, copied training data and finite/shape validation.
- Resolve distance ties by original training row order and class-vote ties by smallest numeric label. Duplicate coordinates count as separate rows, including exact matches.
- Add KNN lab classification and regression with k controls and comparisons against k=1 on the same split and train-fitted scaler. Classification shows A on a sampled grid; regression shows sampled A/B slices at standardized x₂=0.
- Explain KNN in EN/PT-BR, including scaling, validation, ties, duplicates and limits. Fit stores rows; the UI does not invent epochs, a learning rate or optimizer curves.
- Keep painters model-free with cached immutable prediction samples. Reject unsupported k/CSV imports without losing the previous experiment.
- 39 core tests and 32 Flutter tests pass locally; both analyses and architecture checks pass. Exact brute-force prediction is intended for small datasets; no KD-tree, distance weighting or calibrated probabilities are included.

[Live laboratory](https://kleberandrade.github.io/ml-engine/) · [Dart package](https://pub.dev/packages/ml_engine/versions/0.3.0) · [Source](https://github.com/kleberandrade/ml-engine)

Publication is performed after CI validation; the public version API and the GitHub workflow provide the final delivery record. The Flutter application is not included in the pub.dev archive.
