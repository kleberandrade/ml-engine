import 'package:material_ui/material_ui.dart';

import '../../../app/theme.dart';
import '../application/lab_view_model.dart';
import '../domain/experiment.dart';
import 'widgets/experiment_controls.dart';
import 'widgets/experiment_workspace.dart';

class LabPage extends StatefulWidget {
  const LabPage({super.key});
  @override
  State<LabPage> createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  final c = LabViewModel();
  @override
  void dispose() {
    c.dispose();
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
                        final controls = ExperimentControls(c: c);
                        final workspace = ExperimentWorkspace(c: c);
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
}
