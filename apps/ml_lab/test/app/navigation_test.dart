import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ml_lab/app/app.dart';

import '../support/memory_browser.dart';

import 'package:ml_lab/features/experiments/application/lab_view_model.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';

void main() {
  testWidgets(
    'language and Learn navigation preserve a paused experiment and CSV draft',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final browser = MemoryBrowser(), c = LabViewModel();
      addTearDown(c.dispose);
      await tester.pumpWidget(MlLab(browser: browser, controller: c));
      const draft = 'x1,x2,y\n1,0,3\n2,0,5';
      await tester.enterText(find.byType(TextField), draft);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        draft,
      );
      c.start();
      await tester.pump(const Duration(milliseconds: 100));
      c.pauseResume();
      final count = c.history.length;
      await tester.tap(find.byKey(const ValueKey('locale-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Português (BR)').last);
      await tester.pumpAndSettle();
      expect(find.text('Treinar modelos'), findsOneWidget);
      expect(find.text('Retomar'), findsOneWidget);
      expect(browser.language, 'pt-BR');
      expect(c.history.length, count);
      expect(c.status, RunStatus.paused);
      await tester.tap(find.byKey(const ValueKey('nav-learn')));
      await tester.pumpAndSettle();
      expect(find.text('Fundamentos antes do ajuste'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-laboratory')));
      await tester.pumpAndSettle();
      expect(c.history.length, count);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        draft,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'stored language and all executable examples use real implemented models',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final browser = MemoryBrowser()..language = 'pt-BR';
      final c = LabViewModel();
      addTearDown(c.dispose);
      await tester.pumpWidget(MlLab(browser: browser, controller: c));
      await tester.pumpAndSettle();
      expect(find.text('Treinar modelos'), findsOneWidget);
      for (final (id, experiment) in [
        ('linear', Experiment.regression),
        ('binary', Experiment.classification),
        ('clusters', Experiment.clustering),
        ('csv', Experiment.regression),
      ]) {
        await tester.tap(find.byKey(const ValueKey('nav-examples')));
        await tester.pumpAndSettle();
        final button = find.byKey(ValueKey('preset-$id'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(c.experiment, experiment);
        expect(c.status, RunStatus.ready);
        expect(c.data.x.length, id == 'csv' ? 20 : 150);
      }
    },
  );
  testWidgets(
    'mobile navigation supports keyboard and external links have real project targets',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final browser = MemoryBrowser();
      await tester.pumpWidget(MlLab(browser: browser));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nav-menu')));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Foundations before fitting'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Documentation').last);
      await tester.pumpAndSettle();
      expect(
        browser.opened.single,
        'https://github.com/kleberandrade/ml-engine/blob/main/docs/design.md',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
