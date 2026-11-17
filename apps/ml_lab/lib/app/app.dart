import 'package:material_ui/material_ui.dart';

import '../features/experiments/application/lab_view_model.dart';
import '../features/experiments/presentation/lab_page.dart';
import '../features/learning/domain/example_preset.dart';
import '../features/learning/presentation/learning_page.dart';
import '../features/learning/presentation/examples_page.dart';
import 'l10n/app_strings.dart';
import 'platform/browser_services.dart';
import 'lab_navigation.dart';
import 'theme.dart';

class MlLab extends StatefulWidget {
  final BrowserServices? browser;
  final LabViewModel? controller;
  const MlLab({super.key, this.browser, this.controller});
  @override
  State<MlLab> createState() => _MlLabState();
}

class _MlLabState extends State<MlLab> {
  late final BrowserServices browser;
  late final LabViewModel controller;
  AppLanguage language = AppLanguage.en;
  @override
  void initState() {
    super.initState();
    browser = widget.browser ?? createBrowserServices();
    controller = widget.controller ?? LabViewModel();
    try {
      if (browser.readLanguage() == 'pt-BR') language = AppLanguage.ptBr;
    } catch (_) {
      /* Optional browser storage. */
    }
    browser.setDocumentLanguage(language.code);
  }

  void setLanguage(AppLanguage value) {
    browser.setDocumentLanguage(value.code);
    setState(() => language = value);
    try {
      browser.writeLanguage(value.code);
    } catch (_) {
      /* Language remains usable for this session. */
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => context.l10n.t('appTitle'),
    debugShowCheckedModeBanner: false,
    theme: buildLabTheme(),
    locale: language.locale,
    supportedLocales: const [Locale('en'), Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: _LabShell(
      c: controller,
      browser: browser,
      language: language,
      onLanguage: setLanguage,
    ),
  );
}

class _LabShell extends StatefulWidget {
  final LabViewModel c;
  final BrowserServices browser;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguage;
  const _LabShell({
    required this.c,
    required this.browser,
    required this.language,
    required this.onLanguage,
  });
  @override
  State<_LabShell> createState() => _LabShellState();
}

class _LabShellState extends State<_LabShell> {
  LabSection section = LabSection.laboratory;
  void openPreset(ExamplePreset preset) {
    widget.c.select(preset.experiment);
    widget.c.configure(seed: 42, epochs: 250, clusters: 3, learningRate: .08);
    if (preset.csv) widget.c.importCsv(linearCsvFixture());
    setState(() => section = LabSection.laboratory);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        LabNavigation(
          section: section,
          language: widget.language,
          onLanguage: widget.onLanguage,
          onNavigate: (value) => setState(() => section = value),
          onDocumentation: () => widget.browser.openExternal(
            'https://github.com/kleberandrade/ml-engine/blob/main/docs/design.md',
          ),
          onGitHub: () => widget.browser.openExternal(
            'https://github.com/kleberandrade/ml-engine',
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: section.index,
            children: [
              LabPage(controller: widget.c),
              LearningPage(onPreset: openPreset, browser: widget.browser),
              ExamplesPage(onPreset: openPreset),
            ],
          ),
        ),
      ],
    ),
  );
}
