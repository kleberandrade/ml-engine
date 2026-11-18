# Integrating ML Engine

Import only `package:ml_engine/ml_engine.dart`. The facade exports the supported API; imports from `src/` couple your application to internal implementation details. The package is the engine; `apps/ml_lab` is an optional consumer, not a dependency or a required application shell.

## Data and feature schema

`Matrix` means `List<List<double>>`, with samples in rows and features in columns. Both training and prediction require at least one row, a positive fixed width and finite values. The engine has no column names or schema inference: preserve feature order, units and encoding between training and inference. Targets must align with training row order. Core estimators support more than the laboratory's two features.

`Dataset` owns deeply immutable copies. `validateMatrix(x, columns: expectedWidth)` returns the width or throws `ArgumentError`; `validateTargets` additionally checks target length/finiteness. This checks structure, not whether input magnitudes are numerically well conditioned or labels are valid for a particular estimator.

Missing values, strings and categories must be handled before constructing matrices. Define that transformation from training data and apply the same mapping during inference. Do not independently normalize each query batch. Empty prediction batches are rejected; return an empty result in your application's batching layer when that is the desired behavior.

`parseCsv` is a strict convenience parser, not a general CSV reader: exact case-sensitive header `x1,x2,y`, two features, one target, 2–500 data rows by default, finite dot-decimal numbers and no quoted fields. `CsvFormatException.code` is suitable for localization; `.row` is one-based including the header, or null for structural errors. Labels are validated by the chosen model.

## Fit preprocessing once

`Pipeline(transformer, estimator)` stores the instances passed to it; it does not clone them. `fit` learns preprocessing from its training rows, transforms those rows and fits the estimator. `predict` accepts raw rows, applies the learned transform and returns model predictions. `transform` exposes the fitted preprocessing alone.

Use `pipeline.transform(query)` when calling an additional concrete-model method such as classifier probabilities. Passing raw query rows directly to that model after fitting through a scaler is a schema error that dimensions alone cannot detect.

`StandardScaler` uses population variance. Constant training columns use scale one: their training values map to zero, while a different held-out value maps to its difference from the constant. `MinMaxScaler` uses training minima/ranges, replaces a zero range with one and does not clip held-out values to `[0,1]`. Rejected scaler fits preserve previous statistics; transformations return new rows and do not learn from the query.

See the complete executable [quickstart](https://github.com/kleberandrade/ml-engine/blob/main/example/quickstart.dart) and [classification](https://github.com/kleberandrade/ml-engine/blob/main/example/classification.dart) examples.

## Targets, labels and scoring

- Linear/Ridge/KNN/tree/forest/boosting regressors accept finite continuous targets and return target estimates.
- Logistic regression and Gradient Boosting classification accept only `0`/`1`. `predict` thresholds class-1 sigmoid scores at `.5`, assigning ties to `1`. `probabilities` returns uncalibrated scores, not thresholded labels.
- KNN, decision-tree and Random Forest classifiers accept arbitrary finite numeric labels and return hard decisions. Class-vote ties prefer the smallest numeric label. There is no probability method for these models.
- K-means takes features without targets and returns centroid indices. These IDs are arbitrary; they are not supervised class labels. It has its own API rather than `Estimator.fit(x,y)`.

`classificationMetrics(actual, predicted)` is binary only, requires nonempty aligned `0`/`1` vectors and treats `1` as positive. It rejects probability vectors and multiclass labels. Precision, recall and F1 return zero for their zero-denominator cases. Direct `ClassificationMetrics(tp,tn,fp,fn)` construction stores counts without validation; all-zero counts yield NaN accuracy. Prefer `classificationMetrics` for application label vectors.

Regression metrics require nonempty aligned finite vectors. MSE is in squared target units; RMSE/MAE are in target units and lower is better. R² can be negative; for constant targets it is 1 on exact predictions and 0 otherwise. Extreme finite differences/sums can still overflow to infinity/NaN: input validation is not a universal guarantee of finite metric output.

## Split before fitting

`trainValidationTestSplit` defaults to 60% training, 20% validation and the remaining 20% test. Train/validation counts are floored, so small datasets may be rejected if a partition would be empty. The returned lists are immutable and exhaustive/disjoint. A directly constructed `DataSplit` only copies lists; it does not enforce those invariants.

Use validation to select preprocessing, rate, depth, count and other settings. Reserve test rows until selection is complete. Repeatedly consulting the final-test score changes its role in your selection process.

`crossValidate` calls a factory per fold. Return a new `Pipeline`, new transformer and new estimator each time; reuse is rejected. Within each fold, indices must be nonempty, unique, disjoint and in range. Custom folds may overlap across folds and need not hold out every row exactly once. `kFold` does hold out each row once; `stratifiedKFold` also distributes integer class labels and requires at least `k` examples in every class. These are shuffled independent-row splitters, not temporal/group-aware splitters.

A scorer receives held-out actual targets first and predictions second. `crossValidate` returns the scores unchanged, without averaging, checking finiteness or deciding which direction is better. Supply your own scorer for multiclass problems. Ensure neighbor counts fit every fold's training set. See [cross_validation.dart](https://github.com/kleberandrade/ml-engine/blob/main/example/cross_validation.dart).

## Lifecycle and safe model replacement

Construction validates hyperparameters but does not fit a model. `fit` is synchronous. Some estimators also expose `start`/`step`; prediction and snapshot reads do not advance them.

Whole-fit rollback is deliberately model-specific:

- KNN installs validated owned training data atomically. Trees and Random Forest install complete immutable fitted roots. Gradient Boosting trains a complete private candidate before committing it. A rejected fit preserves the previously usable model for these estimators.
- Gradient descent (`LinearRegression`, `RidgeRegression`, `LogisticRegression`) validates before resetting a run, then updates iteratively. A valid `start` discards previous parameters/history. A later failed update retains the last finite state of that new run, not the model that existed before `fit`.
- K-means validates/seeds initialization atomically. A valid `start` replaces centers and clears history; a failed later update retains the initialized/last-complete new state.
- A failed `Pipeline.fit` invalidates the composition, since arbitrary components can have already changed. Further `transform`/`predict` throw `StateError` until a successful refit. Do not refit its exposed components independently.

To keep serving a known-good model, train a separate model/pipeline instance and replace your application's reference only after fitting and acceptance checks succeed. Never assume that catching an exception makes an arbitrary mutated pipeline safe to reuse. Log/report the original exception and retain the previous serving reference.

Invalid settings/shapes/labels generally throw `ArgumentError`. Calls requiring initialization generally throw `StateError`. Numeric failure types vary: gradient-descent divergence uses `StateError`; tree/boosting fitting overflow uses `ArgumentError`; KNN and forest regression mean overflow uses `StateError`. Consult the method's dartdoc for the precise path. Scale magnitudes or reduce a gradient rate when appropriate, rather than silently substituting predictions.

## Stages and histories

A successful `step` returns `true` when it commits an update/tree. It returns `false` at the requested budget, or for converged K-means. Gradient descent does not stop early on a loss tolerance. Boosting builds the requested number of residual trees, even for a zero correction, and has no automatic early stopping.

`GradientModel.costHistory` is an immutable snapshot of post-update objectives: MSE/2 plus any Ridge penalty, or binary cross entropy. It omits the initial zero-parameter cost. `GradientBoostingModel.lossHistory` includes the initial constant loss at index zero and one value per residual tree. `KMeans.costHistory` contains post-update total training inertia; `inertia` throws until one update completes. These quantities are not interchangeable with validation RMSE/accuracy.

Boosting classification `rawPredictions` returns additive logits; its `probabilities` applies sigmoid. Logistic regression's inherited `GradientModel.rawPredictions` already returns sigmoid probabilities. That naming difference is part of the current API; use `probabilities` when the distinction matters to an integrating application.

Boosting/tree/forest nodes and returned histories/parameter arrays are immutable snapshots. Holding an old snapshot does not create a live view of subsequent stages. The stage methods are synchronous; yield between them or use a platform-supported worker/isolate for prolonged fitting. The Flutter lab's small bounded presets are not a general performance guarantee.

## Numerical choices that affect interoperability

Ridge minimizes mean squared loss / 2 plus `lambda*||weights||²/2`, without penalizing the intercept. Its lambda is not directly the alpha of a sum-loss definition: `alpha=n*lambda`. KNN is uniform exact Euclidean search, with row-order ties at the neighbor boundary and duplicates counted separately.

Tree depth counts edges from root zero; a zero maximum yields a constant root. Split children must meet minimum leaf size, but an unsplittable root can contain fewer rows. Splits must improve impurity positively; a greedy zero-gain XOR split is not explored. Numeric threshold equality goes left.

Random Forest draws `n` rows with replacement for each tree and samples fresh features per eligible node. The default subset is `max(1,floor(sqrt(d)))` in both tasks, and only those selected features are searched. Classification uses uniform hard votes, regression means. There is no OOB score or probability aggregation. Immutable bootstrap indices refer to the rows supplied to the latest successful fit; retaining them costs `O(n*trees)` integers.

Gradient Boosting starts from mean targets for regression or clipped training-prior log odds for binary classification. It fits `y-F` or `y-sigmoid(F)` with numeric regression trees, adds `learningRate*tree`, and uses all training rows/features. This is first-order boosting without Newton leaf corrections, line search, subsampling or automatic early stopping. It is not XGBoost and does not claim equivalent predictions or model formats.

## Public API and deployment boundaries

All core operations use in-memory numeric values. The package does not provide persistence/model interchange, categorical encoding, missing-value routing, calibration, GPU execution, concurrent model serving or monitoring. Define these at the application boundary and validate your data/model choices on representative held-out inputs.

The API reference is generated from source dartdoc. CI rejects undocumented public members, documentation warnings/broken links and failing executable examples. Runtime tests protect numerical behavior; documentation coverage is not a measure of predictive quality or suitability for every dataset. See the [API reference](https://pub.dev/documentation/ml_engine/latest/), [numerical design](https://github.com/kleberandrade/ml-engine/blob/main/docs/design.md), and [architecture](https://github.com/kleberandrade/ml-engine/blob/main/docs/architecture.md).
