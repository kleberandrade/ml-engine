import 'dart:convert';
import 'dart:math';
import 'package:ml_engine/ml_engine.dart';

void main() {
  final random = Random(42);
  final x = List.generate(
    500,
    (_) => [random.nextDouble() * 6 - 3, random.nextDouble() * 6 - 3],
  );
  final y = x.map((r) => r[0] + r[1] > 0 ? 1.0 : 0.0).toList();
  final scaler = StandardScaler()..fit(x);
  final scaled = scaler.transform(x);
  final a = LogisticRegression(iterations: 500)..start(scaled, y);
  final b = LogisticRegression(iterations: 500, learningRate: .025)
    ..start(scaled, y);
  final durations = <int>[];
  final grid = List.generate(
    600,
    (i) => [(i % 30) / 5 - 3, (i ~/ 30) / 4 - 2.5],
  );
  for (var i = 0; i < 500; i++) {
    final watch = Stopwatch()..start();
    a.step();
    b.step();
    a.rawPredictions(grid);
    watch.stop();
    durations.add(watch.elapsedMicroseconds);
  }
  final sorted = List<int>.of(durations.skip(20))..sort();
  print(
    jsonEncode({
      'samples': 500,
      'features': 2,
      'iterations': 500,
      'gridPredictionsPerIteration': 600,
      'warmupIterations': 20,
      'medianMicroseconds': sorted[sorted.length ~/ 2],
      'p95Microseconds': sorted[(sorted.length * .95).floor()],
      'maxIncludingWarmupMicroseconds': durations.reduce(max),
      'scope':
          'two logistic updates plus probability grid; excludes Flutter layout/painting',
    }),
  );
}
