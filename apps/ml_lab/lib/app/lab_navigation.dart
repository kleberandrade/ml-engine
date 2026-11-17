import 'package:material_ui/material_ui.dart';

import 'branding/brand_mark.dart';
import 'l10n/app_strings.dart';
import 'language_switcher.dart';

enum LabSection { laboratory, learn, examples }

class LabNavigation extends StatelessWidget {
  final LabSection section;
  final AppLanguage language;
  final ValueChanged<LabSection> onNavigate;
  final ValueChanged<AppLanguage> onLanguage;
  final VoidCallback onDocumentation, onGitHub;
  const LabNavigation({
    super.key,
    required this.section,
    required this.language,
    required this.onNavigate,
    required this.onLanguage,
    required this.onDocumentation,
    required this.onGitHub,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: SafeArea(
      bottom: false,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFDAE3DD))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1352),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final s = context.l10n,
                    wide =
                        constraints.maxWidth >=
                        1050 *
                            MediaQuery.textScalerOf(context)
                                .scale(1)
                                .clamp(1, 3);
                final locale = LanguageSwitcher(
                  language: language,
                  onLanguage: onLanguage,
                );
                return Row(
                  children: [
                    BrandMark(compact: !wide),
                    if (wide) ...[
                      const SizedBox(width: 32),
                      for (final target in LabSection.values)
                        TextButton(
                          key: ValueKey('nav-${target.name}'),
                          onPressed: () => onNavigate(target),
                          style: TextButton.styleFrom(
                            backgroundColor: section == target
                                ? const Color(0xFFE0F0EC)
                                : null,
                          ),
                          child: Text(s.t('nav-${target.name}')),
                        ),
                      TextButton(
                        key: const ValueKey('nav-documentation'),
                        onPressed: onDocumentation,
                        child: Text(s.t('nav-documentation')),
                      ),
                    ],
                    const Spacer(),
                    locale,
                    const SizedBox(width: 8),
                    if (wide)
                      IconButton(
                        key: const ValueKey('nav-github'),
                        tooltip: s.t('nav-github'),
                        onPressed: onGitHub,
                        icon: const Icon(Icons.code),
                      )
                    else
                      PopupMenuButton<String>(
                        key: const ValueKey('nav-menu'),
                        tooltip: s.t('menu'),
                        initialValue: section.name,
                        onSelected: (value) {
                          switch (value) {
                            case 'documentation':
                              onDocumentation();
                            case 'github':
                              onGitHub();
                            default:
                              onNavigate(LabSection.values.byName(value));
                          }
                        },
                        itemBuilder: (context) => [
                          for (final target in LabSection.values)
                            PopupMenuItem(
                              value: target.name,
                              child: Text(s.t('nav-${target.name}')),
                            ),
                          PopupMenuItem(
                            value: 'documentation',
                            child: Text(s.t('nav-documentation')),
                          ),
                          PopupMenuItem(
                            value: 'github',
                            child: Text(s.t('nav-github')),
                          ),
                        ],
                        icon: const Icon(Icons.menu),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
