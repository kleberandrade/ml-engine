import 'package:flutter_test/flutter_test.dart';
import 'package:ml_lab/features/experiments/application/lab_view_model.dart';
import 'package:ml_lab/features/experiments/domain/experiment.dart';

void main() {
  testWidgets(
    'pause freezes training, resume advances, cancel stops and restart clears',
    (tester) async {
      final c = LabViewModel();
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
    final c = LabViewModel();
    for (final experiment in Experiment.values) {
      c.select(experiment);
      c.configure(epochs: 50);
      c.start();
      await tester.pump(const Duration(seconds: 2));
      expect(c.status, RunStatus.complete);
      expect(c.score(c.split.test)!.value.isFinite, isTrue);
      expect(c.history.last, lessThanOrEqualTo(c.history.first));
    }
    c.dispose();
  });
  testWidgets(
    'CSV rejection preserves existing data and import cancels old timer',
    (tester) async {
      final c = LabViewModel();
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
  testWidgets(
    'snapshots remain immutable while training and invalid imports preserve a running experiment',
    (tester) async {
      final c = LabViewModel()..start();
      await tester.pump(const Duration(milliseconds: 50));
      final old = c.plot;
      final coefficients = List<double>.of(old.modelA!.coefficients);
      final before = c.history.length;
      expect(() => c.configure(epochs: 50), throwsStateError);
      expect(() => c.importCsv('bad'), throwsFormatException);
      expect(c.status, RunStatus.running);
      await tester.pump(const Duration(milliseconds: 50));
      expect(c.history.length, greaterThan(before));
      expect(old.modelA!.coefficients, coefficients);
      expect(() => old.scaled[0][0] = 7, throwsUnsupportedError);
      c.dispose();
    },
  );
  testWidgets(
    'invalid clustering fails atomically and synthetic data recovers',
    (tester) async {
      final c = LabViewModel()..select(Experiment.clustering);
      c.importCsv('x1,x2,y\n${List.generate(20, (_) => '1,1,0').join('\n')}');
      c.start();
      expect(c.status, RunStatus.failed);
      expect(c.error, contains('distinct points'));
      expect(c.plot.centroidsA, isEmpty);
      c.generate();
      c.start();
      await tester.pump(const Duration(seconds: 2));
      expect(c.status, RunStatus.complete);
      c.dispose();
    },
  );
  testWidgets('disposing an active run cancels every pending update', (
    tester,
  ) async {
    final c = LabViewModel()..start();
    await tester.pump(const Duration(milliseconds: 50));
    final iterations = c.history.length;
    c.dispose();
    await tester.pump(const Duration(seconds: 2));
    expect(c.history.length, iterations);
    expect(tester.takeException(), isNull);
  });
}
