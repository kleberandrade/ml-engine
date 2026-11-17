import 'dart:math';

import 'package:ml_engine/ml_engine.dart';

import 'experiment.dart';
import 'lab_failure.dart';

/// Pure Dart experiment state. The view model is its sole training writer.
class ExperimentSession {
  final Dataset data;
  final ExperimentSettings settings;
  late final DataSplit split;
  late final Matrix scaled;
  Estimator? _directModel, _comparisonDirectModel;
  bool get hasResults => _directModel != null || history.isNotEmpty;
  GradientModel? _model, _comparison;
  KMeans? _kmeans, _comparisonKmeans;

  ExperimentSession(this.data, this.settings) {
    validateMatrix(data.x, columns: 2);
    if (settings.experiment.isClassification &&
        data.y.any((v) => v != 0 && v != 1)) {
      throw const LabDataException(LabDataError.binaryLabels);
    }
    split = trainValidationTestSplit(data.x.length, seed: settings.seed);
    if (settings.experiment.isKnn && settings.neighbors > split.train.length) {
      throw const LabDataException(LabDataError.neighbors);
    }
    final scaler = StandardScaler()
      ..fit(split.train.map((i) => data.x[i]).toList());
    scaled = List.unmodifiable(
      scaler.transform(data.x).map((row) => List<double>.unmodifiable(row)),
    );
  }
  List<double> get history =>
      _model?.costHistory ?? _kmeans?.costHistory ?? const [];
  List<double> get comparisonHistory =>
      _comparison?.costHistory ?? _comparisonKmeans?.costHistory ?? const [];
  List<double> get coefficientsA => _model?.coefficients ?? const [];
  List<double> get coefficientsB => _comparison?.coefficients ?? const [];
  double get interceptA => _model?.intercept ?? 0;
  double get interceptB => _comparison?.intercept ?? 0;
  double coefficientNorm({bool alternate = false}) => sqrt(
    (alternate ? coefficientsB : coefficientsA).fold(
      0.0,
      (sum, w) => sum + w * w,
    ),
  );
  Matrix get centroidsA => _kmeans?.centroids ?? const [];
  Matrix get centroidsB => _comparisonKmeans?.centroids ?? const [];
  List<int>? get clusterLabels => _kmeans?.predict(scaled);

  DecisionTreeNode? treeRoot({bool alternate = false}) {
    final model = alternate ? _comparisonDirectModel : _directModel;
    return switch (model) {
      DecisionTreeClassifier t => t.root,
      DecisionTreeRegressor t => t.root,
      _ => null,
    };
  }

  void start() {
    final train = split.train.map((i) => scaled[i]).toList();
    final targets = split.train.map((i) => data.y[i]).toList();
    if (settings.experiment.isTree) {
      Estimator create(int depth) => settings.experiment.isRegression
          ? DecisionTreeRegressor(maxDepth: depth, minSamplesLeaf: 2)
          : DecisionTreeClassifier(maxDepth: depth, minSamplesLeaf: 2);
      final a = create(settings.maxDepth)..fit(train, targets);
      final b = create(1)..fit(train, targets);
      _directModel = a;
      _comparisonDirectModel = b;
    } else if (settings.experiment.isKnn) {
      Estimator create(int k) => settings.experiment.isRegression
          ? KNNRegressor(k: k)
          : KNNClassifier(k: k);
      final a = create(settings.neighbors)..fit(train, targets);
      final b = create(1)..fit(train, targets);
      _directModel = a;
      _comparisonDirectModel = b;
    } else if (settings.experiment == Experiment.clustering) {
      if (train.map((row) => row.join(',')).toSet().length <
          settings.clusters) {
        throw LabTrainingException();
      }
      final a = KMeans(
        k: settings.clusters,
        seed: settings.seed,
        iterations: settings.epochs,
      )..start(train);
      final b = KMeans(
        k: settings.clusters,
        seed: settings.seed + 1,
        iterations: settings.epochs,
      )..start(train);
      _kmeans = a;
      _comparisonKmeans = b;
    } else {
      if (settings.experiment == Experiment.ridge) {
        // Only regularization differs: same train rows, initialization, rate and budget.
        _model = RidgeRegression(
          lambda: settings.regularization,
          learningRate: settings.learningRate,
          iterations: settings.epochs,
        )..start(train, targets);
        _comparison = LinearRegression(
          learningRate: settings.learningRate,
          iterations: settings.epochs,
        )..start(train, targets);
      } else {
        GradientModel create(double rate) => settings.experiment.isRegression
            ? LinearRegression(learningRate: rate, iterations: settings.epochs)
            : LogisticRegression(
                learningRate: rate,
                iterations: settings.epochs,
              );
        _model = create(settings.learningRate)..start(train, targets);
        _comparison = create(settings.learningRate / 4)..start(train, targets);
      }
    }
  }

  bool step() {
    if (_directModel != null) return false;
    if (_model == null && _kmeans == null) {
      throw StateError('Start the session first.');
    }
    final a = _model?.step() ?? _kmeans!.step();
    final b = _comparison?.step() ?? _comparisonKmeans!.step();
    return a || b;
  }

  List<double> predict(Matrix rows, {bool alternate = false}) {
    final model = alternate
        ? (_comparisonDirectModel ?? _comparison)
        : (_directModel ?? _model);
    if (model == null) throw StateError('No fitted supervised model.');
    return model.predict(rows);
  }

  ExperimentScore? evaluate(List<int> rows, {bool alternate = false}) {
    if (!hasResults) return null;
    final x = rows.map((i) => scaled[i]).toList(),
        y = rows.map((i) => data.y[i]).toList();
    if (settings.experiment == Experiment.clustering) {
      final model = (alternate ? _comparisonKmeans : _kmeans)!;
      final centers = model.centroids, labels = model.predict(x);
      var total = 0.0;
      for (var i = 0; i < x.length; i++) {
        for (var j = 0; j < x[i].length; j++) {
          total += pow(x[i][j] - centers[labels[i]][j], 2);
        }
      }
      return ExperimentScore(ScoreMetric.meanSquaredDistance, total / x.length);
    }
    final predictions = predict(x, alternate: alternate);
    return settings.experiment.isRegression
        ? ExperimentScore(
            ScoreMetric.rmse,
            rootMeanSquaredError(y, predictions),
          )
        : ExperimentScore(
            ScoreMetric.accuracy,
            classificationMetrics(y, predictions).accuracy,
          );
  }

  ExperimentScore? get baseline {
    if (settings.experiment == Experiment.clustering) return null;
    final train = split.train.map((i) => data.y[i]).toList();
    final mean = train.reduce((a, b) => a + b) / train.length;
    final y = split.validation.map((i) => data.y[i]).toList();
    final predictions = List.filled(
      y.length,
      settings.experiment.isRegression ? mean : (mean >= .5 ? 1.0 : 0.0),
    );
    return settings.experiment.isRegression
        ? ExperimentScore(
            ScoreMetric.rmse,
            rootMeanSquaredError(y, predictions),
          )
        : ExperimentScore(
            ScoreMetric.accuracy,
            classificationMetrics(y, predictions).accuracy,
          );
  }
}
