import 'package:flutter_test/flutter_test.dart';
import 'package:ml_lab/controller.dart';
import 'package:ml_lab/main.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'pause freezes training, resume advances, cancel stops and restart clears',
    (tester) async {
      final c = LabController();
      c.start();
      await tester.pump(const Duration(milliseconds: 80));
      expect(c.history, isNotEmpty);
      c.pauseResume();
      final paused = c.history.length;
      await tester.pump(const Duration(seconds: 1));
      expect(c.history.length, paused);
      c.pauseResume();
      await tester.pump(const Duration(milliseconds: 50));
      expect(c.history.length, greaterThan(paused));
      c.cancel();
      final cancelled = c.history.length;
      await tester.pump(const Duration(seconds: 1));
      expect(c.history.length, cancelled);
      c.reset();
      expect(c.history, isEmpty);
      expect(c.status, RunStatus.ready);
      c.dispose();
    },
  );
  testWidgets('all experiments complete and scores remain finite', (
    tester,
  ) async {
    final c = LabController();
    for (final experiment in Experiment.values) {
      c.select(experiment);
      c.epochs = 50;
      c.start();
      await tester.pump(const Duration(seconds: 2));
      expect(c.status, RunStatus.complete);
      expect(c.score(c.split.test), isNot(contains('NaN')));
      expect(c.history.last, lessThanOrEqualTo(c.history.first));
    }
    c.dispose();
  });
  testWidgets(
    'CSV rejection preserves existing data and import cancels old timer',
    (tester) async {
      final c = LabController();
      final original = c.data;
      expect(() => c.importCsv('bad'), throwsFormatException);
      expect(c.data, same(original));
      c.start();
      c.importCsv(
        'x1,x2,y\n${List.generate(20, (i) => '$i,0,${2 * i + 1}').join('\n')}',
      );
      await tester.pump(const Duration(seconds: 1));
      expect(c.data.x.length, 20);
      expect(c.history, isEmpty);
      expect(c.status, RunStatus.ready);
      c.dispose();
    },
  );
  testWidgets('desktop interactions and mobile text scaling have no overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MlLab());
    await tester.tap(find.text('Train models'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.text('CANCELLED'), findsOneWidget);
    await tester.tap(find.text('Restart'));
    await tester.pump();
    expect(find.text('READY'), findsOneWidget);
    await tester.tap(find.text('02  Logistic classification'));
    await tester.pump();
    expect(find.text('Find the boundary'), findsOneWidget);
    await tester.tap(find.text('03  K-means++'));
    await tester.pump();
    expect(find.text('Discover the structure'), findsOneWidget);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MlLab(),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  testWidgets('mobile touch targets and contrast meet Flutter guidelines', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MlLab());
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });
}
