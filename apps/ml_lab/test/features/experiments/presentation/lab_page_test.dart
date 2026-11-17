import 'package:flutter_test/flutter_test.dart';
import 'package:ml_lab/app/app.dart';
import 'package:material_ui/material_ui.dart';

void main() {
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
    expect(
      MediaQuery.textScalerOf(
        tester.element(find.text('Make learning visible.')),
      ).scale(10),
      15,
    );
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
  testWidgets('CSV drafts survive a responsive layout change', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MlLab());
    const draft = 'x1,x2,y\n1,0,3\n2,0,5';
    await tester.enterText(find.byType(TextField), draft);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      draft,
    );
    expect(tester.takeException(), isNull);
  });
}
