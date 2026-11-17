import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ml_lab/app/app.dart';
import 'package:ml_lab/app/l10n/app_strings.dart';
import 'package:ml_lab/features/learning/domain/learning_content.dart';
import 'package:ml_lab/features/learning/domain/example_preset.dart';

import '../support/memory_browser.dart';

void main() {
  test('both languages cover every message and keep matching placeholder contracts', () {
    final pattern = RegExp(r'\{(\w+)\}');
    for (final entry in messages.entries) {
      expect(entry.value.length, 2, reason: entry.key);
      expect(
        entry.value.every((text) => text.trim().isNotEmpty),
        isTrue,
        reason: entry.key,
      );
      expect(
        pattern.allMatches(entry.value[0]).map((m) => m[1]).toSet(),
        pattern.allMatches(entry.value[1]).map((m) => m[1]).toSet(),
        reason: entry.key,
      );
    }
    expect(learningExercises.length, 5);
    final ids = examplePresets.map((p) => p.id).toSet();
    for (final topic in learningTopics) {
      expect(
        [
          topic.title.en,
          topic.title.pt,
          topic.body.en,
          topic.body.pt,
          topic.interpretation.en,
          topic.interpretation.pt,
        ].every((text) => text.isNotEmpty),
        isTrue,
      );
      if (topic.preset != null) expect(ids, contains(topic.preset));
    }
  });
  testWidgets(
    'CSV feedback changes language without replacing the editor or data',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final browser = MemoryBrowser()..language = 'pt-BR';
      await tester.pumpWidget(MlLab(browser: browser));
      await tester.pumpAndSettle();
      const invalid = 'x1,x2,y\nNaN,0,1\n2,0,5';
      await tester.enterText(find.byType(TextField), invalid);
      final load = find.text('Carregar CSV');
      await tester.ensureVisible(load);
      await tester.tap(load);
      await tester.pumpAndSettle();
      expect(find.textContaining('Linha 2:'), findsOneWidget);
      expect(find.text('150 linhas • dados sintéticos'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('locale-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('Row 2:'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        invalid,
      );
    },
  );
  testWidgets(
    'Portuguese Learn and navbar remain usable on a narrow screen at 150 percent text',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final browser = MemoryBrowser()..language = 'pt-BR';
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: MlLab(browser: browser),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Treinar modelos'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aprender').last);
      await tester.pumpAndSettle();
      expect(find.text('Fundamentos antes do ajuste'), findsOneWidget);
      expect(
        MediaQuery.textScalerOf(
          tester.element(find.text('Fundamentos antes do ajuste')),
        ).scale(10),
        15,
      );
      final last = find.text('5. Investigue a estabilidade dos grupos');
      await tester.ensureVisible(last);
      await tester.pumpAndSettle();
      expect(last, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
