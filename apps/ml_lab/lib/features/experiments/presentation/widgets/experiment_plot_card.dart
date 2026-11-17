import 'package:material_ui/material_ui.dart';

import '../../../../app/theme.dart';
import '../../application/lab_view_model.dart';
import '../../domain/experiment.dart';
import 'lab_panel.dart';
import '../painters/data_painter.dart';

class ExperimentPlotCard extends StatelessWidget {
  final LabViewModel c;
  const ExperimentPlotCard({super.key, required this.c});
  @override
  Widget build(BuildContext context) => LabPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(switch (c.experiment) {
                Experiment.regression => 'Fit a relationship',
                Experiment.classification => 'Find the boundary',
                Experiment.clustering => 'Discover the structure',
              }, style: Theme.of(context).textTheme.titleLarge),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: paper,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                c.status.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  color: teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          c.experiment == Experiment.regression
              ? 'x₁ standardized → target y • line holds x₂ at its training mean'
              : 'x₁ standardized → x₂ standardized • scaling fitted on training rows',
        ),
        const SizedBox(height: 12),
        Semantics(
          label:
              'Data plot. ${c.data.x.length} samples. ${c.experiment.name}. ${c.history.length} iterations completed. Validation scores are listed below.',
          image: true,
          child: SizedBox(
            height: 310,
            width: double.infinity,
            child: CustomPaint(painter: DataPainter(c.plot)),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 18,
          runSpacing: 6,
          children: [
            Text(
              c.experiment == Experiment.clustering
                  ? '+ A centroids'
                  : '● Model A / class 0',
              style: const TextStyle(color: teal),
            ),
            Text(
              c.experiment == Experiment.clustering
                  ? '+ B centroids'
                  : '◆ Model B / class 1',
              style: const TextStyle(color: Color(0xFF8D451F)),
            ),
            Text(
              c.experiment == Experiment.clustering
                  ? '${c.clusters} cluster colors • ○ held-out rows'
                  : '○ held-out rows • ● training rows',
            ),
          ],
        ),
      ],
    ),
  );
}
