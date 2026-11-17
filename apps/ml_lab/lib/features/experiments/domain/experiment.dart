enum Experiment {
  regression,
  classification,
  clustering,
  ridge,
  knnClassification,
  knnRegression,
  treeClassification,
  treeRegression,
  forestClassification,
  forestRegression;

  bool get isRegression =>
      this == regression ||
      this == ridge ||
      this == knnRegression ||
      this == treeRegression ||
      this == forestRegression;
  bool get isClassification =>
      this == classification ||
      this == knnClassification ||
      this == treeClassification ||
      this == forestClassification;
  bool get isTree => this == treeClassification || this == treeRegression;
  bool get isForest => this == forestClassification || this == forestRegression;
  bool get isTreeBased => isTree || isForest;
  bool get isDirect => isKnn || isTreeBased;
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
  final int seed, epochs, clusters, neighbors, maxDepth, nEstimators;
  final double learningRate, regularization;
  ExperimentSettings({
    this.experiment = Experiment.regression,
    this.seed = 42,
    this.epochs = 250,
    this.clusters = 3,
    this.neighbors = 5,
    this.maxDepth = 3,
    this.nEstimators = 15,
    this.learningRate = .08,
    this.regularization = 1,
  }) {
    if (nEstimators < 1 || nEstimators > 25) {
      throw ArgumentError("Lab trees must be between 1 and 25.");
    }
    if (maxDepth < 1 || maxDepth > 6) {
      throw ArgumentError('Lab depth must be between 1 and 6.');
    }
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
    int? maxDepth,
    int? nEstimators,
    double? learningRate,
    double? regularization,
  }) => ExperimentSettings(
    experiment: experiment ?? this.experiment,
    seed: seed ?? this.seed,
    epochs: epochs ?? this.epochs,
    clusters: clusters ?? this.clusters,
    neighbors: neighbors ?? this.neighbors,
    maxDepth: maxDepth ?? this.maxDepth,
    nEstimators: nEstimators ?? this.nEstimators,
    learningRate: learningRate ?? this.learningRate,
    regularization: regularization ?? this.regularization,
  );
}

/// Read-only aggregate metadata; a forest has no single root rule.
class ForestSummary {
  final int trees, depth, leaves, featuresPerSplit, samplesPerTree;
  const ForestSummary(
    this.trees,
    this.depth,
    this.leaves,
    this.featuresPerSplit,
    this.samplesPerTree,
  );
}
