enum Experiment { regression, classification, clustering }

enum ScoreMetric { rmse, accuracy, meanSquaredDistance }

class ExperimentScore {
  final ScoreMetric metric;
  final double value;
  const ExperimentScore(this.metric, this.value);
}

/// Immutable, validated settings for a bounded teaching experiment.
class ExperimentSettings {
  final Experiment experiment;
  final int seed, epochs, clusters;
  final double learningRate;
  ExperimentSettings({
    this.experiment = Experiment.regression,
    this.seed = 42,
    this.epochs = 250,
    this.clusters = 3,
    this.learningRate = .08,
  }) {
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
    double? learningRate,
  }) => ExperimentSettings(
    experiment: experiment ?? this.experiment,
    seed: seed ?? this.seed,
    epochs: epochs ?? this.epochs,
    clusters: clusters ?? this.clusters,
    learningRate: learningRate ?? this.learningRate,
  );
}
