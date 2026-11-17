import 'package:material_ui/material_ui.dart';

import '../../application/lab_view_model.dart';
import '../../domain/experiment.dart';
import 'lab_panel.dart';

class ExplanationCard extends StatelessWidget {
  final LabViewModel c;
  const ExplanationCard({super.key, required this.c});
  @override
  Widget build(BuildContext context) => LabPanel(
    child: Column(
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
  );
}
