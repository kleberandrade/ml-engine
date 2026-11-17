import 'package:material_ui/material_ui.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme.dart';
import '../../application/lab_view_model.dart';
import '../../domain/experiment.dart';
import '../painters/cost_painter.dart';
import '../formatters/score_formatter.dart';
import '../formatters/failure_formatter.dart';
import 'lab_panel.dart';

class ComparisonCard extends StatelessWidget {
  final LabViewModel c;
  const ComparisonCard({super.key, required this.c});
  @override
  Widget build(BuildContext context) {
    final s = context.l10n;
    final ridge = c.experiment == Experiment.ridge;
    final labelA = ridge
        ? s.t('ridgeShort', {'value': s.number(c.regularization, 1)})
        : c.experiment == Experiment.clustering
        ? s.t('seedShort', {'value': c.seed})
        : s.t('rateShort', {'value': s.number(c.learningRate, 2)});
    final labelB = ridge
        ? s.t('linearShort')
        : c.experiment == Experiment.clustering
        ? s.t('seedShort', {'value': c.seed + 1})
        : s.t('rateShort', {'value': s.number(c.learningRate / 4, 3)});
    return LabPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.t('fair'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            s.t('split', {
              'train': c.split.train.length,
              'validation': c.split.validation.length,
              'test': c.split.test.length,
            }),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              _score('A  $labelA', formatScore(s, c.score(c.split.validation))),
              _score(
                'B  $labelB',
                formatScore(s, c.score(c.split.validation, alternate: true)),
              ),
            ],
          ),
          if (ridge) ...[
            const SizedBox(height: 12),
            Text(
              s.t('coefficientNorm', {
                'a': s.number(c.coefficientNorm(), 3),
                'b': s.number(c.coefficientNorm(alternate: true), 3),
              }),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            formatBaseline(s, c.baseline),
            style: const TextStyle(fontSize: 13),
          ),
          if (c.status == RunStatus.complete) ...[
            const Divider(height: 24),
            Text(
              s.t('finalTest', {
                'a': formatScore(s, c.score(c.split.test)),
                'b': formatScore(s, c.score(c.split.test, alternate: true)),
              }),
            ),
            Text(s.t('testWarning'), style: const TextStyle(fontSize: 12)),
          ],
          if (c.error != null)
            Text(
              formatFailure(s, c.error!),
              style: const TextStyle(color: Color(0xFFB00020)),
            ),
          const SizedBox(height: 20),
          Text(
            s.t('objective', {'count': c.history.length}),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: s.t('costAria', {
              'cost': c.history.isEmpty
                  ? s.t('noTraining')
                  : s.t('latestCost', {'value': s.number(c.history.last, 4)}),
            }),
            image: true,
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: CustomPaint(
                painter: CostPainter(c.history, c.comparisonHistory, s),
              ),
            ),
          ),
          Text(
            s.t(ridge ? 'ridgeObjectiveLegend' : 'objectiveLegend'),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _score(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF4D626A)),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
    ],
  );
}
