import 'package:material_ui/material_ui.dart';

import '../../../../app/l10n/app_strings.dart';
import '../../application/lab_view_model.dart';
import 'lab_panel.dart';

class ExplanationCard extends StatelessWidget {
  final LabViewModel c;
  const ExplanationCard({super.key, required this.c});
  @override
  Widget build(BuildContext context) {
    final s = context.l10n;
    return LabPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.t('insight'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(s.t('explain-${c.experiment.name}')),
          const SizedBox(height: 10),
          Text(s.t('leakage'), style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
