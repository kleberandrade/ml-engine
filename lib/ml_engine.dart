/// Classical ML with explicit training boundaries and reproducible splits.
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
