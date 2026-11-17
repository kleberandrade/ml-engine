import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ml_lab/app/app.dart';
import 'package:ml_lab/features/experiments/application/lab_view_model.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';

import '../support/memory_browser.dart';

void main() {
  testWidgets(
    'depth control, tree rules and bilingual navigation preserve completed results',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = LabViewModel();
      addTearDown(c.dispose);
      await tester.pumpWidget(MlLab(browser: MemoryBrowser(), controller: c));
      await tester.tap(find.text('07  Decision tree classifier'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Learning rate'), findsNothing);
      expect(find.text('Pause'), findsNothing);
      final slider = find.byKey(const ValueKey('tree-depth'));
      await tester.ensureVisible(slider);
      await tester.drag(slider, const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(c.maxDepth, 1);
      await tester.tap(find.text('Fit and evaluate trees'));
      await tester.pumpAndSettle();
      expect(c.status, RunStatus.complete);
      expect(c.history, isEmpty);
      expect(
        c.score(c.split.validation)!.value,
        c.score(c.split.validation, alternate: true)!.value,
      );
      expect(find.textContaining('First rule of A:'), findsOneWidget);
      final plot = c.plot, root = c.treeRoot();
      await tester.tap(find.byKey(const ValueKey('locale-pt-BR')));
      await tester.pumpAndSettle();
      expect(find.text('Profundidade máxima  1'), findsOneWidget);
      expect(find.textContaining('Primeira regra de A:'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-learn')));
      await tester.pumpAndSettle();
      expect(find.text('Árvore de classificação'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-laboratory')));
      await tester.pumpAndSettle();
      expect(c.plot, same(plot));
      expect(c.treeRoot(), same(root));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Portuguese tree regression controls and summaries fit mobile at 150 percent',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = LabViewModel()..select(Experiment.treeRegression);
      addTearDown(c.dispose);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: MlLab(
            browser: MemoryBrowser()..language = 'pt-BR',
            controller: c,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final run = find.text('Ajustar e avaliar árvores');
      await tester.ensureVisible(run);
      await tester.tap(run);
      await tester.pumpAndSettle();
      expect(c.plot.samples!.a, hasLength(60));
      final explanation = find.textContaining('Escolha divisões que reduzam');
      await tester.ensureVisible(explanation);
      await tester.pumpAndSettle();
      expect(explanation, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
