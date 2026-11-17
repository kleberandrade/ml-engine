import 'package:material_ui/material_ui.dart';

import 'branding/language_flag.dart';
import 'l10n/app_strings.dart';

class LanguageSwitcher extends StatelessWidget {
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguage;
  const LanguageSwitcher({
    super.key,
    required this.language,
    required this.onLanguage,
  });
  @override
  Widget build(BuildContext context) {
    final s = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in AppLanguage.values)
          Semantics(
            selected: language == value,
            child: IconButton(
              key: ValueKey(
                value == AppLanguage.en ? 'locale-en' : 'locale-pt-BR',
              ),
              tooltip:
                  s.t(
                    value == AppLanguage.en
                        ? 'languageEnglish'
                        : 'languagePortuguese',
                  ) +
                  (language == value ? ' • ${s.t('selected')}' : ''),
              onPressed: () => onLanguage(value),
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
                shape: CircleBorder(
                  side: BorderSide(
                    color: language == value
                        ? const Color(0xFF006B62)
                        : const Color(0xFFBBCAC5),
                    width: language == value ? 3 : 1,
                  ),
                ),
                backgroundColor: language == value
                    ? const Color(0xFFE0F0EC)
                    : null,
              ),
              icon: LanguageFlag(language: value),
            ),
          ),
      ],
    );
  }
}
