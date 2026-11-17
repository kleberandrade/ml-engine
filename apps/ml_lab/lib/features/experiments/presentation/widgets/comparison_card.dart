import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../application/lab_view_model.dart';
import '../../domain/experiment.dart';
import 'lab_panel.dart';
import '../painters/cost_painter.dart';
import '../formatters/score_formatter.dart';

class ComparisonCard extends StatelessWidget {
  final LabViewModel c;
  const ComparisonCard({super.key, required this.c});
  @override
  Widget build(BuildContext context) => LabPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Same data. Fair comparison.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Train ${c.split.train.length} / validation ${c.split.validation.length} / test ${c.split.test.length}. Same split, scaler and budget for A and B.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 32,
          runSpacing: 16,
          children: [
            _score(
              'A  ${c.experiment == Experiment.clustering ? 'seed ${c.seed}' : 'rate ${c.learningRate.toStringAsFixed(2)}'}',
              formatScore(c.score(c.split.validation)),
            ),
            _score(
              'B  ${c.experiment == Experiment.clustering ? 'seed ${c.seed + 1}' : 'rate ${(c.learningRate / 4).toStringAsFixed(3)}'}',
              formatScore(c.score(c.split.validation, alternate: true)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(formatBaseline(c.baseline), style: const TextStyle(fontSize: 13)),
        if (c.status == RunStatus.complete) ...[
          const Divider(height: 24),
          Text(
            'Final test • A: ${formatScore(c.score(c.split.test))}  /  B: ${formatScore(c.score(c.split.test, alternate: true))}',
          ),
          const Text(
            'Use validation to choose settings. Repeatedly inspecting test results turns test data into validation data.',
            style: TextStyle(fontSize: 12),
          ),
        ],
        if (c.error != null)
          Text(c.error!, style: const TextStyle(color: Color(0xFFB00020))),
        const SizedBox(height: 20),
        Text(
          'Training objective  •  ${c.history.length} iterations',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Semantics(
          label:
              'Training cost curve. ${c.history.isEmpty ? 'No training yet' : 'A latest cost ${c.history.last.toStringAsFixed(4)}'}. Lower is better.',
          image: true,
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: CostPainter(c.history, c.comparisonHistory),
            ),
          ),
        ),
        const Text(
          'A: teal • B: brown. Linear: MSE/2; logistic: binary cross entropy; K-means: train inertia.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
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
