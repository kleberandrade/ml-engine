enum Experiment {
  regression,
  classification,
  clustering,
  ridge,
  knnClassification,
  knnRegression;

  bool get isRegression =>
      this == regression || this == ridge || this == knnRegression;
  bool get isClassification =>
      this == classification || this == knnClassification;
  bool get isKnn => this == knnClassification || this == knnRegression;
}

enum ScoreMetric { rmse, accuracy, meanSquaredDistance }

class ExperimentScore {
  final ScoreMetric metric;
  final double value;
  const ExperimentScore(this.metric, this.value);
}

/// Immutable, validated settings for a bounded teaching experiment.
class ExperimentSettings {
  final Experiment experiment;
  final int seed, epochs, clusters, neighbors;
  final double learningRate, regularization;
  ExperimentSettings({
    this.experiment = Experiment.regression,
    this.seed = 42,
    this.epochs = 250,
    this.clusters = 3,
    this.neighbors = 5,
    this.learningRate = .08,
    this.regularization = 1,
  }) {
    if (neighbors < 1 || neighbors > 15) {
      throw ArgumentError('Lab neighbors must be between 1 and 15.');
    }
    if (!regularization.isFinite || regularization < 0 || regularization > 3) {
      throw ArgumentError('Lab regularization must be between 0 and 3.');
    }
    if (!learningRate.isFinite ||
        learningRate < .01 ||
        learningRate > .3 ||
        epochs < 1 ||
        epochs > 500 ||
        clusters < 2 ||
        clusters > 5) {
      throw ArgumentError(
        'Invalid lab settings: rate .01–.3, iterations 1–500, clusters 2–5.',
      );
    }
  }
  ExperimentSettings copyWith({
    Experiment? experiment,
    int? seed,
    int? epochs,
    int? clusters,
    int? neighbors,
    double? learningRate,
    double? regularization,
  }) => ExperimentSettings(
    experiment: experiment ?? this.experiment,
    seed: seed ?? this.seed,
    epochs: epochs ?? this.epochs,
    clusters: clusters ?? this.clusters,
    neighbors: neighbors ?? this.neighbors,
    learningRate: learningRate ?? this.learningRate,
    regularization: regularization ?? this.regularization,
  );
}
