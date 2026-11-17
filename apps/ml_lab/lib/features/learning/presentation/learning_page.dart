import 'package:material_ui/material_ui.dart';

import '../../../app/l10n/app_strings.dart';
import '../../../app/platform/browser_services.dart';
import '../../experiments/presentation/widgets/lab_panel.dart';
import '../domain/example_preset.dart';
import '../domain/learning_content.dart';

class LearningPage extends StatelessWidget {
  final ValueChanged<ExamplePreset> onPreset;
  final BrowserServices browser;
  const LearningPage({
    super.key,
    required this.onPreset,
    required this.browser,
  });
  @override
  Widget build(BuildContext context) {
    final s = context.l10n, pt = context.l10n.language == AppLanguage.ptBr;
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
                  s.t('learnTitle'),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(s.t('learnSubtitle')),
                const SizedBox(height: 10),
                Text(
                  s.t('sourceVersion'),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 24),
                for (final topic in learningTopics) ...[
                  LabPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.title.inLanguage(pt),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(topic.body.inLanguage(pt)),
                        const SizedBox(height: 16),
                        SelectableText(
                          pt
                              ? (topic.formulaPt ?? topic.formula)
                              : topic.formula,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 17,
                            color: Color(0xFF006B62),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(topic.interpretation.inLanguage(pt)),
                        if (topic.preset != null) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            key: ValueKey('learn-preset-${topic.preset}'),
                            onPressed: () => onPreset(
                              examplePresets.firstWhere(
                                (p) => p.id == topic.preset,
                              ),
                            ),
                            icon: const Icon(Icons.science_outlined),
                            label: Text(s.t('openExample')),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                Text(
                  s.t('references'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    for (final (key, path) in [
                      ('tutorialLink', 'docs/tutorial.md'),
                      ('designLink', 'docs/design.md'),
                      ('codeLink', 'example/main.dart'),
                      ('roadmapLink', 'docs/roadmap.md'),
                    ])
                      TextButton(
                        onPressed: () => browser.openExternal(
                          'https://github.com/kleberandrade/ml-engine/blob/main/$path',
                        ),
                        child: Text(s.t(key)),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  s.t('exercises'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                for (final exercise in learningExercises) ...[
                  LabPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.title.inLanguage(pt),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.t('objectiveLabel') +
                              exercise.objective.inLanguage(pt),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.t('completionLabel') +
                              exercise.completion.inLanguage(pt),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
