import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ml_lab/app/app.dart';
import 'package:ml_lab/features/experiments/application/lab_view_model.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';

import '../support/memory_browser.dart';

void main() {
  testWidgets(
    'Ridge slider, linear comparison and language preserve paused state',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = LabViewModel();
      addTearDown(c.dispose);
      await tester.pumpWidget(MlLab(browser: MemoryBrowser(), controller: c));
      await tester.tap(find.text('04  Ridge vs linear'));
      await tester.pumpAndSettle();
      expect(c.experiment, Experiment.ridge);
      final slider = find.byKey(const ValueKey('ridge-regularization'));
      await tester.ensureVisible(slider);
      await tester.drag(slider, const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(c.regularization, 0);
      expect(find.text('A  Ridge λ=0.0'), findsOneWidget);
      expect(find.text('B  Linear λ=0'), findsOneWidget);
      c.start();
      await tester.pump(const Duration(milliseconds: 160));
      c.pauseResume();
      await tester.pump();
      expect(c.history, c.comparisonHistory);
      expect(tester.widget<Slider>(slider).onChanged, isNull);
      final count = c.history.length;
      await tester.tap(find.byKey(const ValueKey('locale-pt-BR')));
      await tester.pumpAndSettle();
      expect(c.history.length, count);
      expect(c.status, RunStatus.paused);
      expect(find.text('Regularização λ  0,0'), findsOneWidget);
      expect(
        find.textContaining('Os objetivos são diferentes'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Portuguese Ridge controls and explanations fit narrow scaled text',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = LabViewModel()..select(Experiment.ridge);
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
      await tester.ensureVisible(
        find.byKey(const ValueKey('ridge-regularization')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Regularização λ  1,0'), findsOneWidget);
      final explanation = find.textContaining('Ridge minimiza');
      await tester.ensureVisible(explanation);
      await tester.pumpAndSettle();
      expect(explanation, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
