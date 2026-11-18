/// Pure Dart classical machine learning for application developers.
///
/// Import this facade rather than implementation files under `src/`. [Matrix]
/// uses samples as rows and features as columns. Supervised [Estimator] models
/// fit aligned finite targets; unsupervised [KMeans] accepts features only.
/// [Pipeline] fits preprocessing on training rows and reuses it at inference.
///
/// ```dart
/// final model = Pipeline(StandardScaler(), LinearRegression());
/// model.fit([[0], [1], [2]], [2, 5, 8]);
/// final predictions = model.predict([[3]]);
/// ```
///
/// Classifiers differ in supported labels and probability APIs; consult their
/// class documentation. Fitting is synchronous and failure-state guarantees are
/// model-specific. [crossValidate] requires fresh components for each fold.
library;

export 'src/data/matrix.dart';
export 'src/data/dataset.dart';
export 'src/data/csv_reader.dart';
export 'src/model_selection/split.dart';
export 'src/model_selection/fold.dart';
export 'src/model_selection/cross_validation.dart';
export 'src/models/estimator.dart';
export 'src/models/decision_tree.dart';
export 'src/models/random_forest.dart';
export 'src/models/knn.dart';
export 'src/models/gradient_model.dart';
export 'src/models/linear_regression.dart';
export 'src/models/ridge_regression.dart';
export 'src/models/logistic_regression.dart';
export 'src/models/k_means.dart';
export 'src/preprocessing/transformer.dart';
export 'src/preprocessing/scalers.dart';
export 'src/pipeline/pipeline.dart';
export 'src/metrics/regression.dart';
export 'src/metrics/classification.dart';
export 'src/models/gradient_boosting.dart';
