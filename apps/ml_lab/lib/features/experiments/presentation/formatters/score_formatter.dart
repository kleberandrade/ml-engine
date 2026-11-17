import '../../domain/experiment.dart';

String formatScore(ExperimentScore? score) => score == null
    ? '—'
    : switch (score.metric) {
        ScoreMetric.rmse => 'RMSE ${score.value.toStringAsFixed(3)}',
        ScoreMetric.accuracy =>
          'Accuracy ${(100 * score.value).toStringAsFixed(1)}%',
        ScoreMetric.meanSquaredDistance =>
          'Mean distance² ${score.value.toStringAsFixed(3)}',
      };
String formatBaseline(ExperimentScore? score) => score == null
    ? 'Unsupervised • lower held-out distance is better'
    : score.metric == ScoreMetric.rmse
    ? 'Train-mean baseline • validation ${formatScore(score)}'
    : 'Train-majority baseline • validation ${formatScore(score).toLowerCase()}';
