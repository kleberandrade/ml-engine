import '../../../../app/l10n/app_strings.dart';
import '../../domain/experiment.dart';

String formatScore(AppStrings s, ExperimentScore? score) => score == null
    ? '—'
    : switch (score.metric) {
        ScoreMetric.rmse => 'RMSE ${s.number(score.value, 3)}',
        ScoreMetric.accuracy => s.t('accuracy', {
          'value': s.number(100 * score.value, 1),
        }),
        ScoreMetric.meanSquaredDistance => s.t('distance', {
          'value': s.number(score.value, 3),
        }),
      };
String formatBaseline(AppStrings s, ExperimentScore? score) => score == null
    ? s.t('baselineClusters')
    : s.t(
        score.metric == ScoreMetric.rmse ? 'baselineMean' : 'baselineMajority',
        {'score': formatScore(s, score)},
      );
