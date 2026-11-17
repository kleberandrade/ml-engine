import 'package:material_ui/material_ui.dart';

import '../../application/lab_view_model.dart';
import 'experiment_plot_card.dart';
import 'comparison_card.dart';
import 'explanation_card.dart';

class ExperimentWorkspace extends StatelessWidget {
  final LabViewModel c;
  const ExperimentWorkspace({super.key, required this.c});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExperimentPlotCard(c: c),
      const SizedBox(height: 18),
      ComparisonCard(c: c),
      const SizedBox(height: 18),
      ExplanationCard(c: c),
    ],
  );
}
