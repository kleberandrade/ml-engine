# Numerical conventions and extension guide

## Domain glossary

A row is one sample; a column is one feature. A target is a finite real value (regression) or 0/1 (binary classification). Fit learns parameters; transform applies learned preprocessing; predict applies the fitted estimator. A fold contains disjoint train/test indices. Validation selects settings; final test estimates the selected procedure's generalization.

## Contracts

Matrices are nonempty rectangular `List<List<double>>` values. Targets match row count. Public fitting and prediction boundaries reject NaN and infinity, and prediction rejects the wrong feature count. Dataset rows, model parameter getters, centroid getters and cost histories cannot be mutated through returned collections. No training state is shared between runs.

Gradient descent starts at zero coefficients and intercept, includes the intercept gradient, and uses full-batch average gradients. Linear cost is MSE/2. Binary logistic cost uses `max(z,0) - z*y + log(1+exp(-abs(z)))`; probabilities use a sign-stable sigmoid; class threshold is >=0.5. Costs are recorded AFTER each update, without a synthetic initial sample. `step()` returns false after the requested budget. Overflow causes an explicit error rather than clipping a diverged model silently. RidgeRegression adds `lambda*sum(w²)/2` to MSE/2 and `lambda*w` to the weight gradient. Lambda is finite and nonnegative, the intercept is unpenalized and lambda=0 uses precisely the linear updates. This mean-loss convention is invariant to row duplication; a sum-loss implementation uses alpha=n*lambda. Cost history includes the penalty after each update. Large rates/lambda may diverge; no automatic learning-rate tuning or matrix solver is supplied.

StandardScaler uses population variance (ddof=0). Zero standard deviation or zero MinMax range becomes scale 1; training constants map to zero, while a new value outside the constant training value maps to its difference. MinMax transforms can fall outside [0,1] on held-out data. Extreme finite magnitudes may overflow floating-point arithmetic and are rejected during scaling/training; arbitrary precision is not supported.

K-means++ samples the first center uniformly, then samples unchosen locations proportional to squared nearest-center distance. Identical locations cannot supply multiple centers. Ties choose the first center; an empty cluster retains its preceding center. Lloyd updates stop on squared maximum shift <=1e-16 or iteration budget. Inertia is the total squared distance after each update. Seeded runs are reproducible in the same validated runtime; Dart's Random algorithm is not promised to remain identical across SDK versions.

Splits floor train and validation counts and assign the remainder to test; empty partitions are rejected. K-fold distributes shuffled indices round-robin. Stratified K-fold shuffles each class and carries the bucket offset across groups; every class must have at least k samples. These random splits assume independent rows: chronological, grouped or subject-correlated data needs a different splitting strategy. No implicit time-series validity is claimed.

R² returns 1 for perfect predictions on constant targets and 0 otherwise. Undefined binary precision/recall/F1 denominators return 0. Binary confusion counts are exposed as truePositive, trueNegative, falsePositive, falseNegative. Multiclass metrics and probability calibration are outside v0.2.0.

## KNN conventions

`KNNClassifier(k: 5)` and `KNNRegressor(k: 5)` implement Estimator and work with Pipeline/CV. Both store a validated deep copy of training data. k is positive and no larger than that fit's training row count. A rejected fit preserves the previous dataset. Prediction ranks squared Euclidean distances (equivalent to Euclidean ranking), breaking equal distances by training row index. Nonfinite distance arithmetic throws an explicit ArgumentError.

Classification accepts finite numeric class labels and chooses the most frequent label in the k selected rows. Equal vote counts choose the smallest label. Regression averages those k target values with equal weights; it divides before summing to avoid avoidable sum overflow. Duplicate coordinates remain separate rows, including exact matches. No inverse-distance weighting, radius search, KD-tree, class probabilities or gradient training is supplied. Prediction costs O(n*d + n log n) time and O(n) temporary memory per query. The lab restricts classification to labels 0/1 because its plot and metrics are binary.

Fit/scaling see training rows only. Each validation fold must fit a fresh pipeline and satisfy k<=fold.train.length. Small k can follow noise; large k may oversmooth. KNN stores examples instead of learning an extrapolation function. Select k using validation and leave the final test untouched.

## Decision tree conventions

`DecisionTreeClassifier(maxDepth: 5, minSamplesLeaf: 1)` and `DecisionTreeRegressor(...)` implement Estimator with finite numeric features and labels/targets. The classifier supports multiple numeric classes; lab metrics/plots remain binary. Root depth is zero; maxDepth is nonnegative and minSamplesLeaf positive. Small datasets can be a single root leaf even if smaller than minSamplesLeaf. Children of every accepted split satisfy the bound.

At each node, sort every feature, consider adjacent distinct values and score prefix/suffix losses. Classification uses weighted Gini; regression uses weighted MSE via Welford moments instead of subtracting E[y²]−E[y]². Splits require impurity improvement greater than 1e-12 of the parent impurity. Gain ties within that tolerance keep the first feature index, then the lowest threshold. No zero-gain exploratory splits are performed: XOR with no useful first split remains a single majority leaf. Greedy growth is not globally optimal.

Thresholds are `(low/2 + high/2)` to avoid sum overflow. If rounding reaches high, use low, preserving a nonempty partition. Prediction routes `<=` left; class leaves choose the smallest numeric label on a majority tie; regression leaves average training targets. Pure targets, constant/unsplittable features, depth limits or small partitions stop growth. Fit commits immutable nodes only after the full tree succeeds; nonfinite arithmetic throws and preserves the previous root. No input rows are retained by the fitted tree.

The immutable root exposes prediction, sampleCount, impurity (Gini/MSE), featureIndex/threshold and children. Depth is actual edge depth; leafCount counts terminal nodes. Scale is not necessary for ordering-based trees, but preprocessing must still be fitted on training rows when used in a pipeline. Every CV fold builds fresh components. No missing/categorical handling, pruning, class probabilities or smooth extrapolation is provided. Fitting sorts per feature at each node; prediction costs O(depth) per sample.

## Add an estimator

Implement `Estimator.fit(Matrix, List<double>)` and `Estimator.predict(Matrix)`. Validate the boundary, own any stored rows, reject prediction before fitting, and preserve the training feature count. Add an independent numerical fixture before implementing the algorithm. Plug it into `Pipeline` without importing Flutter. Models with iterative UI use should expose an explicit start/step state machine as GradientModel and KMeans do. Move genuinely large training work to an isolate/worker; do not call synchronous fit in a widget callback.

Implement `Transformer` for new preprocessing. `Pipeline.transform` returns the fitted transformation. Chained preprocessing may be implemented as a composite Transformer; each fold factory must create all stages afresh. Unsupervised KMeans has a separate fit signature and deliberately does not pretend that labels are needed by implementing Estimator.

## Boundaries

`lib/` imports only Dart SDK libraries. `apps/ml_lab/` consumes the core via a path dependency. Its view model owns experiment lifetime and timers; the pure Dart experiment session owns fitting/evaluation, and painters render immutable snapshots. See [architecture.md](architecture.md) for the feature layout and enforced dependency direction. Persistence, file pickers, network datasets and native platform integration are not needed for the first usable version.

CSV parsing throws FormatException-compatible `CsvFormatException` values with a `CsvError` code and optional one-based `row`. Consumers can translate errors from metadata instead of parsing English error text. The lab maps these to its own typed data failures; numerical/training code has no localization or Flutter dependency.
