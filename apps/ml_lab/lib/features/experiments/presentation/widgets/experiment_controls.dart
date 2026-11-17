import 'package:material_ui/material_ui.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../application/lab_view_model.dart';
import '../../domain/experiment.dart';
import '../formatters/failure_formatter.dart';
import 'lab_panel.dart';

class ExperimentControls extends StatefulWidget {
  final LabViewModel c;
  const ExperimentControls({super.key, required this.c});
  @override
  State<ExperimentControls> createState() => _ExperimentControlsState();
}

class _ExperimentControlsState extends State<ExperimentControls> {
  LabViewModel get c => widget.c;
  final csv = TextEditingController();
  Object? csvError;
  @override
  void dispose() {
    csv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.l10n;
    return LabPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.t('setup'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 18),
          Text(
            s.t('rows', {
              'count': c.data.x.length,
              'source': s.t(c.imported ? 'imported' : 'synthetic'),
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: c.seed,
            decoration: InputDecoration(
              labelText: s.t('seed'),
              border: const OutlineInputBorder(),
            ),
            items: [7, 42, 123]
                .map(
                  (seed) => DropdownMenuItem(value: seed, child: Text('$seed')),
                )
                .toList(),
            onChanged: c.active
                ? null
                : (seed) {
                    if (seed != null) c.configure(seed: seed);
                  },
          ),
          const SizedBox(height: 16),
          if (c.experiment != Experiment.clustering) ...[
            Text(s.t('rate', {'value': s.number(c.learningRate, 2)})),
            Slider(
              semanticFormatterCallback: (v) =>
                  s.t('rate', {'value': s.number(v, 2)}),
              value: c.learningRate,
              min: .01,
              max: .3,
              divisions: 29,
              onChanged: c.active ? null : (v) => c.configure(learningRate: v),
            ),
          ] else ...[
            Text(s.t('clusters', {'count': c.clusters})),
            Slider(
              semanticFormatterCallback: (v) =>
                  s.t('clusterSemantic', {'count': v.round()}),
              value: c.clusters.toDouble(),
              min: 2,
              max: 5,
              divisions: 3,
              onChanged: c.active
                  ? null
                  : (v) => c.configure(clusters: v.round()),
            ),
          ],
          Text(s.t('budget', {'count': c.epochs})),
          Slider(
            semanticFormatterCallback: (v) =>
                s.t('iterations', {'count': v.round()}),
            value: c.epochs.toDouble(),
            min: 50,
            max: 500,
            divisions: 9,
            onChanged: c.active ? null : (v) => c.configure(epochs: v.round()),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: c.active ? null : c.start,
              icon: const Icon(Icons.play_arrow),
              label: Text(s.t('train')),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton(
                onPressed: c.active ? c.pauseResume : null,
                child: Text(
                  s.t(c.status == RunStatus.paused ? 'resume' : 'pause'),
                ),
              ),
              OutlinedButton(
                onPressed: c.active ? c.cancel : null,
                child: Text(s.t('cancel')),
              ),
              TextButton(onPressed: c.reset, child: Text(s.t('restart'))),
            ],
          ),
          const Divider(height: 32),
          Text(
            s.t('csvTitle'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(s.t('csvHelp'), style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: csv,
            enabled: !c.active,
            minLines: 3,
            maxLines: 5,
            maxLength: 50000,
            decoration: InputDecoration(
              labelText: s.t('csvLabel'),
              hintText: 'x1,x2,y\n1,0,3\n2,0,5',
              border: const OutlineInputBorder(),
              errorMaxLines: 4,
              errorText: csvError == null ? null : formatFailure(s, csvError!),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: c.active
                    ? null
                    : () {
                        try {
                          c.importCsv(csv.text);
                          setState(() => csvError = null);
                        } catch (error) {
                          setState(() => csvError = error);
                        }
                      },
                child: Text(s.t('loadCsv')),
              ),
              TextButton(
                onPressed: c.active
                    ? null
                    : () {
                        setState(() => csvError = null);
                        c.generate();
                      },
                child: Text(s.t('useSynthetic')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
