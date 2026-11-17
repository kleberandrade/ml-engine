import 'package:material_ui/material_ui.dart';

import '../../../app/l10n/app_strings.dart';
import '../../experiments/presentation/widgets/lab_panel.dart';
import '../domain/example_preset.dart';

class ExamplesPage extends StatelessWidget {
  final ValueChanged<ExamplePreset> onPreset;
  const ExamplesPage({super.key, required this.onPreset});
  @override
  Widget build(BuildContext context) {
    final s = context.l10n;
    return SingleChildScrollView(
      primary: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.t('examplesTitle'),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(s.t('examplesSubtitle')),
                const SizedBox(height: 24),
                for (final preset in examplePresets) ...[
                  LabPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.t('example-${preset.id}'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(s.t('example-${preset.id}-body')),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          key: ValueKey('preset-${preset.id}'),
                          onPressed: () => onPreset(preset),
                          icon: const Icon(Icons.play_arrow),
                          label: Text(s.t('openExample')),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
