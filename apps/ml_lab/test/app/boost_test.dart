import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ml_lab/app/app.dart';
import 'package:ml_lab/features/experiments/application/lab_view_model.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';

import '../support/memory_browser.dart';

void main() {
  testWidgets(
    'three boosting sliders, pause and bilingual navigation retain the additive model',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = LabViewModel();
      addTearDown(c.dispose);
      await tester.pumpWidget(MlLab(browser: MemoryBrowser(), controller: c));
      await tester.tap(find.text('11  Gradient Boosting classifier'));
      await tester.pumpAndSettle();
      for (final item in [
        ('boost-trees', 500.0),
        ('tree-depth', -500.0),
        ('learning-rate', 500.0),
      ]) {
        final slider = find.byKey(ValueKey(item.$1));
        await tester.ensureVisible(slider);
        await tester.drag(slider, Offset(item.$2, 0));
        await tester.pumpAndSettle();
      }
      expect(c.nEstimators, 25);
      expect(c.maxDepth, 1);
      expect(c.learningRate, .3);
      expect(find.textContaining('Iteration budget'), findsNothing);
      final run = find.text('Train models');
      await tester.ensureVisible(run);
      await tester.tap(run);
      await tester.pump(const Duration(milliseconds: 32));
      await tester.tap(find.text('Pause'));
      await tester.pump();
      expect(c.status, RunStatus.paused);
      final history = c.history;
      expect(
        tester
            .widget<Slider>(find.byKey(const ValueKey('boost-trees')))
            .onChanged,
        isNull,
      );
      await tester.tap(find.byKey(const ValueKey('locale-pt-BR')));
      await tester.pumpAndSettle();
      expect(find.text('Taxa de aprendizado  0,30'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-learn')));
      await tester.pumpAndSettle();
      expect(find.text('Classificação Gradient Boosting'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-laboratory')));
      await tester.pumpAndSettle();
      expect(c.history, same(history));
      expect(c.status, RunStatus.paused);
      await tester.tap(find.text('Retomar'));
      await tester.pumpAndSettle();
      expect(c.status, RunStatus.complete);
      expect(c.boostSummary()!.stages, 25);
      expect(c.history, hasLength(26));
      expect(find.textContaining('Etapas ajustadas: 25/25'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Portuguese boosting regression fits mobile at 150 percent text',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = LabViewModel()
        ..select(Experiment.boostRegression)
        ..configure(nEstimators: 5);
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
      final run = find.text('Treinar modelos');
      await tester.ensureVisible(run);
      await tester.tap(run);
      await tester.pumpAndSettle();
      expect(c.status, RunStatus.complete);
      expect(c.plot.samples!.a, hasLength(60));
      final explanation = find.textContaining('Comece na média dos alvos');
      await tester.ensureVisible(explanation);
      await tester.pumpAndSettle();
      expect(explanation, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
