import 'dart:math';
import 'package:ml_engine/ml_engine.dart';

/// Separates label predictions from sigmoid scores on a hand-solvable fixture.
void main() {
  final classifier = GradientBoostingClassifier(
    nEstimators: 1,
    maxDepth: 1,
    learningRate: .5,
  );
  final pipeline = Pipeline(StandardScaler(), classifier)
    ..fit(
      [
        [0],
        [1],
        [2],
        [3],
      ],
      [0, 0, 1, 1],
    );
  final query = <List<double>>[
    [0],
    [3],
  ];
  final labels = pipeline.predict(query);
  // The classifier was fitted on transformed rows; probabilities need that scale.
  final probabilities = classifier.probabilities(pipeline.transform(query));
  final metrics = classificationMetrics([0, 1], labels);
  if (metrics.accuracy != 1 ||
      (probabilities.last - 1 / (1 + exp(-.25))).abs() > 1e-12) {
    throw StateError(
      'Expected labels [0,1] and positive probability sigmoid(.25).',
    );
  }
  print('Labels: $labels; probabilities: $probabilities; F1: ${metrics.f1}');
}
