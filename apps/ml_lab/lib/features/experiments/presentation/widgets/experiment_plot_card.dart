import 'package:material_ui/material_ui.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../../../app/theme.dart';
import '../../application/lab_view_model.dart';
import '../../domain/experiment.dart';
import '../painters/data_painter.dart';
import 'lab_panel.dart';

class ExperimentPlotCard extends StatelessWidget {
  final LabViewModel c;
  const ExperimentPlotCard({super.key, required this.c});
  @override
  Widget build(BuildContext context) {
    final s = context.l10n;
    return LabPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.t('plot-${c.experiment.name}'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: paper,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    s.t('status-${c.status.name}'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            s.t(c.experiment.isRegression ? 'axisRegression' : 'axisFeatures'),
          ),
          if (c.experiment == Experiment.knnClassification)
            Text(s.t('knnRegions')),
          const SizedBox(height: 12),
          Semantics(
            label: s.t(c.experiment.isKnn ? 'knnPlotAria' : 'plotAria', {
              'count': c.data.x.length,
              'type': s.t('type-${c.experiment.name}'),
              'iterations': c.history.length,
            }),
            image: true,
            child: SizedBox(
              height: 310,
              width: double.infinity,
              child: CustomPaint(painter: DataPainter(c.plot, s)),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 18,
            runSpacing: 6,
            children: [
              Text(
                s.t(
                  c.experiment == Experiment.clustering
                      ? 'centroidsA'
                      : 'legendA',
                ),
                style: const TextStyle(color: teal),
              ),
              Text(
                s.t(
                  c.experiment == Experiment.clustering
                      ? 'centroidsB'
                      : 'legendB',
                ),
                style: const TextStyle(color: Color(0xFF8D451F)),
              ),
              Text(
                c.experiment == Experiment.clustering
                    ? s.t('clusterColors', {'count': c.clusters})
                    : s.t('heldOut'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
