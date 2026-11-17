import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ml_lab/app/app.dart';
import 'package:ml_lab/features/experiments/application/lab_view_model.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';

import '../support/memory_browser.dart';

void main() {
  testWidgets(
    'KNN k slider, instant evaluation and language/navigation preserve results',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = LabViewModel();
      addTearDown(c.dispose);
      await tester.pumpWidget(MlLab(browser: MemoryBrowser(), controller: c));
      await tester.tap(find.text('05  KNN classification'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Learning rate'), findsNothing);
      expect(find.textContaining('Iteration budget'), findsNothing);
      expect(find.text('Pause'), findsNothing);
      final slider = find.byKey(const ValueKey('knn-neighbors'));
      await tester.ensureVisible(slider);
      await tester.drag(slider, const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(c.neighbors, 1);
      await tester.tap(find.text('Evaluate neighbors'));
      await tester.pumpAndSettle();
      expect(c.status, RunStatus.complete);
      expect(c.history, isEmpty);
      final score = c.score(c.split.validation)!.value;
      expect(score, c.score(c.split.validation, alternate: true)!.value);
      final plot = c.plot;
      await tester.tap(find.byKey(const ValueKey('locale-pt-BR')));
      await tester.pumpAndSettle();
      expect(find.text('Vizinhos k  1'), findsOneWidget);
      expect(find.textContaining('não tem épocas'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-learn')));
      await tester.pumpAndSettle();
      expect(find.text('Classificação KNN'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-laboratory')));
      await tester.pumpAndSettle();
      expect(c.score(c.split.validation)!.value, score);
      expect(c.plot, same(plot));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Portuguese KNN regression controls and predictions fit mobile 150 percent',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = LabViewModel()..select(Experiment.knnRegression);
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
      final run = find.text('Avaliar vizinhos');
      await tester.ensureVisible(run);
      await tester.tap(run);
      await tester.pumpAndSettle();
      expect(c.plot.neighbors!.b, hasLength(60));
      final explanation = find.textContaining('KNN prevê a média simples');
      await tester.ensureVisible(explanation);
      await tester.pumpAndSettle();
      expect(explanation, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
