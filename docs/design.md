# Numerical conventions and extension guide

## Domain glossary

A row is one sample; a column is one feature. A target is a finite real value (regression) or 0/1 (binary classification). Fit learns parameters; transform applies learned preprocessing; predict applies the fitted estimator. A fold contains disjoint train/test indices. Validation selects settings; final test estimates the selected procedure's generalization.

## Contracts

Matrices are nonempty rectangular `List<List<double>>` values. Targets match row count. Public fitting and prediction boundaries reject NaN and infinity, and prediction rejects the wrong feature count. Dataset rows, model parameter getters, centroid getters and cost histories cannot be mutated through returned collections. No training state is shared between runs.

Gradient descent starts at zero coefficients and intercept, includes the intercept gradient, and uses full-batch average gradients. Linear cost is MSE/2. Binary logistic cost uses `max(z,0) - z*y + log(1+exp(-abs(z)))`; probabilities use a sign-stable sigmoid; class threshold is >=0.5. Costs are recorded AFTER each update, without a synthetic initial sample. `step()` returns false after the requested budget. Overflow causes an explicit error rather than clipping a diverged model silently. There is no regularization or automatic learning-rate tuning.

StandardScaler uses population variance (ddof=0). Zero standard deviation or zero MinMax range becomes scale 1; training constants map to zero, while a new value outside the constant training value maps to its difference. MinMax transforms can fall outside [0,1] on held-out data. Extreme finite magnitudes may overflow floating-point arithmetic and are rejected during scaling/training; arbitrary precision is not supported.

K-means++ samples the first center uniformly, then samples unchosen locations proportional to squared nearest-center distance. Identical locations cannot supply multiple centers. Ties choose the first center; an empty cluster retains its preceding center. Lloyd updates stop on squared maximum shift <=1e-16 or iteration budget. Inertia is the total squared distance after each update. Seeded runs are reproducible in the same validated runtime; Dart's Random algorithm is not promised to remain identical across SDK versions.

Splits floor train and validation counts and assign the remainder to test; empty partitions are rejected. K-fold distributes shuffled indices round-robin. Stratified K-fold shuffles each class and carries the bucket offset across groups; every class must have at least k samples. These random splits assume independent rows: chronological, grouped or subject-correlated data needs a different splitting strategy. No implicit time-series validity is claimed.

R² returns 1 for perfect predictions on constant targets and 0 otherwise. Undefined binary precision/recall/F1 denominators return 0. Binary confusion counts are exposed as truePositive, trueNegative, falsePositive, falseNegative. Multiclass metrics and probability calibration are outside v0.1.0.

## Add an estimator

Implement `Estimator.fit(Matrix, List<double>)` and `Estimator.predict(Matrix)`. Validate the boundary, own any stored rows, reject prediction before fitting, and preserve the training feature count. Add an independent numerical fixture before implementing the algorithm. Plug it into `Pipeline` without importing Flutter. Models with iterative UI use should expose an explicit start/step state machine as GradientModel and KMeans do. Move genuinely large training work to an isolate/worker; do not call synchronous fit in a widget callback.

Implement `Transformer` for new preprocessing. `Pipeline.transform` returns the fitted transformation. Chained preprocessing may be implemented as a composite Transformer; each fold factory must create all stages afresh. Unsupervised KMeans has a separate fit signature and deliberately does not pretend that labels are needed by implementing Estimator.

## Boundaries

`lib/` imports only Dart SDK libraries. `apps/ml_lab/` consumes the core via a path dependency. Its view model owns experiment lifetime and timers; the pure Dart experiment session owns fitting/evaluation, and painters render immutable snapshots. See [architecture.md](architecture.md) for the feature layout and enforced dependency direction. Persistence, file pickers, network datasets and native platform integration are not needed for the first usable version.
