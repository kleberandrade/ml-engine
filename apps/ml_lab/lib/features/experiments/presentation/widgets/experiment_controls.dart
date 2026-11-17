import 'package:material_ui/material_ui.dart';

import '../../application/lab_view_model.dart';
import '../../domain/experiment.dart';
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
  String? csvError;
  @override
  void dispose() {
    csv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LabPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Experiment setup', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 18),
        Text(
          '${c.data.x.length} rows • ${c.imported ? 'CSV data' : 'synthetic data'}',
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          initialValue: c.seed,
          decoration: const InputDecoration(
            labelText: 'Random seed',
            border: OutlineInputBorder(),
          ),
          items: [
            7,
            42,
            123,
          ].map((s) => DropdownMenuItem(value: s, child: Text('$s'))).toList(),
          onChanged: c.active
              ? null
              : (s) {
                  c.configure(seed: s!);
                },
        ),
        const SizedBox(height: 16),
        if (c.experiment != Experiment.clustering) ...[
          Text('Learning rate  ${c.learningRate.toStringAsFixed(2)}'),
          Slider(
            semanticFormatterCallback: (v) =>
                'Learning rate ${v.toStringAsFixed(2)}',
            value: c.learningRate,
            min: .01,
            max: .3,
            divisions: 29,
            onChanged: c.active ? null : (v) => c.configure(learningRate: v),
          ),
        ] else ...[
          Text('Clusters  ${c.clusters}'),
          Slider(
            label: '${c.clusters} clusters',
            value: c.clusters.toDouble(),
            min: 2,
            max: 5,
            divisions: 3,
            onChanged: c.active
                ? null
                : (v) => c.configure(clusters: v.round()),
          ),
        ],
        Text('Iteration budget  ${c.epochs}'),
        Slider(
          semanticFormatterCallback: (v) => '${v.round()} iterations',
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
            label: const Text('Train models'),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            OutlinedButton(
              onPressed: c.active ? c.pauseResume : null,
              child: Text(c.status == RunStatus.paused ? 'Resume' : 'Pause'),
            ),
            OutlinedButton(
              onPressed: c.active ? c.cancel : null,
              child: const Text('Cancel'),
            ),
            TextButton(onPressed: c.reset, child: const Text('Restart')),
          ],
        ),
        const Divider(height: 32),
        const Text(
          'Bring your own data',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Paste numeric CSV with header x1,x2,y. 10–500 rows; binary y for classification. Labels are ignored for clustering.',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: csv,
          enabled: !c.active,
          minLines: 3,
          maxLines: 5,
          maxLength: 50000,
          decoration: InputDecoration(
            labelText: 'CSV data',
            hintText: 'x1,x2,y\n1,0,3\n2,0,5',
            border: const OutlineInputBorder(),
            errorText: csvError,
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
                      } catch (e) {
                        setState(() => csvError = '$e');
                      }
                    },
              child: const Text('Load CSV'),
            ),
            TextButton(
              onPressed: c.active ? null : c.generate,
              child: const Text('Use synthetic'),
            ),
          ],
        ),
      ],
    ),
  );
}
