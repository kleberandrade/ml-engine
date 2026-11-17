import 'package:material_ui/material_ui.dart';

import 'controller.dart';
import 'plots.dart';

void main() => runApp(const MlLab());

const ink = Color(0xFF172B36),
    teal = Color(0xFF006B62),
    paper = Color(0xFFF4F6F3);

class MlLab extends StatelessWidget {
  const MlLab({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ML Engine • Learning laboratory',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: teal),
      scaffoldBackgroundColor: paper,
      useMaterial3: true,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
    ),
    home: const LabPage(),
  );
}

class LabPage extends StatefulWidget {
  const LabPage({super.key});
  @override
  State<LabPage> createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  final c = LabController();
  final csv = TextEditingController();
  String? csvError;
  @override
  void dispose() {
    c.dispose();
    csv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.scatter_plot, color: teal),
                        SizedBox(width: 10),
                        Text(
                          'ML / ENGINE',
                          style: TextStyle(
                            letterSpacing: 3,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                        Text(
                          'CLASSICAL ML   /   LAB 01',
                          style: TextStyle(fontSize: 11, color: teal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Make learning visible.',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Build an intuition for models, one training step at a time.',
                      style: TextStyle(fontSize: 17, color: Color(0xFF4D626A)),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Experiment.values
                          .map(
                            (e) => ChoiceChip(
                              label: Text(switch (e) {
                                Experiment.regression =>
                                  '01  Linear regression',
                                Experiment.classification =>
                                  '02  Logistic classification',
                                Experiment.clustering => '03  K-means++',
                              }),
                              selected: c.experiment == e,
                              onSelected: c.active ? null : (_) => c.select(e),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final controls = _controls();
                        final workspace = _workspace();
                        return constraints.maxWidth >= 900
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 290, child: controls),
                                  const SizedBox(width: 24),
                                  Expanded(child: workspace),
                                ],
                              )
                            : Column(
                                children: [
                                  controls,
                                  const SizedBox(height: 20),
                                  workspace,
                                ],
                              );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'PURE DART CORE  /  REPRODUCIBLE SEEDS  /  TRAIN-ONLY PREPROCESSING',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: Color(0xFF4D626A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  Widget panel(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFDAE3DD)),
    ),
    child: child,
  );
  Widget _controls() => panel(
    Column(
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
                  c.seed = s!;
                  c.generate();
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
            onChanged: c.active
                ? null
                : (v) => setState(() {
                    c.learningRate = v;
                    c.reset();
                  }),
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
                : (v) => setState(() {
                    c.clusters = v.round();
                    c.reset();
                  }),
          ),
        ],
        Text('Iteration budget  ${c.epochs}'),
        Slider(
          semanticFormatterCallback: (v) => '${v.round()} iterations',
          value: c.epochs.toDouble(),
          min: 50,
          max: 500,
          divisions: 9,
          onChanged: c.active
              ? null
              : (v) => setState(() {
                  c.epochs = v.round();
                  c.reset();
                }),
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
  Widget _workspace() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      panel(
        Column(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
                child: CustomPaint(painter: DataPainter(c)),
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
      ),
      const SizedBox(height: 18),
      panel(
        Column(
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
                  c.score(c.split.validation),
                ),
                _score(
                  'B  ${c.experiment == Experiment.clustering ? 'seed ${c.seed + 1}' : 'rate ${(c.learningRate / 4).toStringAsFixed(3)}'}',
                  c.score(c.split.validation, alternate: true),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(c.baseline, style: const TextStyle(fontSize: 13)),
            if (c.status == RunStatus.complete) ...[
              const Divider(height: 24),
              Text(
                'Final test • A: ${c.score(c.split.test)}  /  B: ${c.score(c.split.test, alternate: true)}',
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
      ),
      const SizedBox(height: 18),
      panel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why this experiment matters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(switch (c.experiment) {
              Experiment.regression => 'Gradient descent adjusts coefficients to reduce squared error. Try a smaller learning rate and watch model B converge more slowly. A flat feature contributes no information; the scaler maps it to zero.',
              Experiment.classification => 'Logistic regression turns a linear score into a probability. The plotted boundary uses a 0.5 threshold. Accuracy alone can hide class imbalance: the Dart API also reports precision, recall, F1 and confusion counts.',
              Experiment.clustering => 'K-means++ seeds centers with distance-weighted sampling, then alternates assignments and centroid updates. Different seeds can find different local minima. Cluster IDs are arbitrary; they are not class predictions.',
            }),
            const SizedBox(height: 10),
            const Text(
              'No leakage: preprocessing sees training rows only. For cross validation, the core creates a fresh pipeline inside every fold. This lab is a bounded teaching tool, not an out-of-core trainer.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    ],
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
