import 'package:material_ui/material_ui.dart';

import '../../../app/l10n/app_strings.dart';
import '../application/lab_view_model.dart';
import '../domain/experiment.dart';
import 'widgets/experiment_controls.dart';
import 'widgets/experiment_workspace.dart';

class LabPage extends StatefulWidget {
  final LabViewModel controller;
  const LabPage({super.key, required this.controller});
  @override
  State<LabPage> createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  LabViewModel get c => widget.controller;
  // Keep drafts when the wide/narrow layout reparents the form.
  final _controlsKey = GlobalKey(debugLabel: 'experiment-controls');
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: c,
    builder: (context, _) {
      final s = context.l10n;
      return SingleChildScrollView(
        primary: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.t('labTag'),
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      color: Color(0xFF006B62),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.t('hero'),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.t('subtitle'),
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF4D626A),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Experiment.values
                        .map(
                          (e) => ChoiceChip(
                            label: Text(s.t('chip-${e.name}')),
                            selected: c.experiment == e,
                            onSelected: c.active ? null : (_) => c.select(e),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final controls = ExperimentControls(
                            key: _controlsKey,
                            c: c,
                          ),
                          workspace = ExperimentWorkspace(c: c);
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
                  Text(
                    s.t('footer'),
                    style: const TextStyle(
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
      );
    },
  );
}
