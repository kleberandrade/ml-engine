import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:ml_engine/ml_engine.dart';

enum Experiment { regression, classification, clustering }

enum RunStatus { ready, running, paused, complete, cancelled, failed }

class LabController extends ChangeNotifier {
  Experiment experiment = Experiment.regression;
  RunStatus status = RunStatus.ready;
  int seed = 42;
  double learningRate = .08;
  int epochs = 250;
  int clusters = 3;
  String? error;
  bool imported = false;
  late Dataset data;
  late DataSplit split;
  late Matrix scaled;
  StandardScaler scaler = StandardScaler();
  GradientModel? model, comparison;
  KMeans? kmeans, comparisonKmeans;
  Timer? _timer;
  LabController() {
    generate();
  }
  List<double> get history => model?.costHistory ?? kmeans?.costHistory ?? [];
  List<double> get comparisonHistory =>
      comparison?.costHistory ?? comparisonKmeans?.costHistory ?? [];
  bool get active => status == RunStatus.running || status == RunStatus.paused;
  void generate() {
    _timer?.cancel();
    final random = Random(seed);
    final x = <List<double>>[], y = <double>[];
    for (var i = 0; i < 150; i++) {
      final a = random.nextDouble() * 6 - 3, b = random.nextDouble() * 6 - 3;
      if (experiment == Experiment.clustering) {
        final c = i % 3;
        x.add([
          a * .3 + [-2, 2, 0][c],
          b * .3 + [-1, -1, 2][c],
        ]);
        y.add(c.toDouble());
      } else {
        x.add([a, experiment == Experiment.regression ? 0 : b]);
        y.add(
          experiment == Experiment.regression
              ? 2 * a + 1 + (random.nextDouble() - .5) * 1.4
              : (a + b + (random.nextDouble() - .5) * 1.2 > 0 ? 1 : 0),
        );
      }
    }
    imported = false;
    _setData(Dataset(x, y));
  }

  void select(Experiment value) {
    experiment = value;
    generate();
  }

  void importCsv(String value) {
    final parsed = parseCsv(value);
    if (parsed.x.length < 10) {
      throw const FormatException(
        'Lab needs at least 10 rows for three nonempty partitions.',
      );
    }
    if (experiment == Experiment.classification &&
        parsed.y.any((v) => v != 0 && v != 1)) {
      throw const FormatException('Classification requires labels 0 or 1.');
    }
    if (parsed.x.any((r) => r.any((v) => v.abs() > 1e6)) ||
        parsed.y.any((v) => v.abs() > 1e6)) {
      throw const FormatException('Lab magnitudes must be <= 1,000,000.');
    }
    _timer?.cancel();
    imported = true;
    _setData(parsed);
  }

  void _setData(Dataset value) {
    data = value;
    split = trainValidationTestSplit(data.x.length, seed: seed);
    scaler = StandardScaler()..fit(split.train.map((i) => data.x[i]).toList());
    scaled = scaler.transform(data.x);
    _clear();
    notifyListeners();
  }

  void _clear() {
    status = RunStatus.ready;
    error = null;
    model = null;
    comparison = null;
    kmeans = null;
    comparisonKmeans = null;
  }

  void reset() {
    _timer?.cancel();
    _clear();
    notifyListeners();
  }

  void start() {
    _timer?.cancel();
    _clear();
    final train = split.train.map((i) => scaled[i]).toList();
    final targets = split.train.map((i) => data.y[i]).toList();
    try {
      if (experiment == Experiment.clustering) {
        kmeans = KMeans(k: clusters, seed: seed, iterations: epochs)
          ..start(train);
        comparisonKmeans = KMeans(
          k: clusters,
          seed: seed + 1,
          iterations: epochs,
        )..start(train);
      } else {
        GradientModel create(double rate) => experiment == Experiment.regression
            ? LinearRegression(learningRate: rate, iterations: epochs)
            : LogisticRegression(learningRate: rate, iterations: epochs);
        model = create(learningRate)..start(train, targets);
        comparison = create(learningRate / 4)..start(train, targets);
      }
      status = RunStatus.running;
      _schedule();
    } catch (e) {
      status = RunStatus.failed;
      error = '$e';
    }
    notifyListeners();
  }

  void _schedule() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => advance());
  }

  /// Bounded work: one epoch on <=500 rows per frame; never a blocking fit loop.
  void advance() {
    if (status != RunStatus.running) return;
    try {
      final a = model?.step() ?? kmeans!.step();
      final b = comparison?.step() ?? comparisonKmeans!.step();
      if (!a && !b) {
        _timer?.cancel();
        status = RunStatus.complete;
      }
    } catch (e) {
      _timer?.cancel();
      status = RunStatus.failed;
      error = '$e';
    }
    notifyListeners();
  }

  void pauseResume() {
    if (status == RunStatus.running) {
      _timer?.cancel();
      status = RunStatus.paused;
    } else if (status == RunStatus.paused) {
      status = RunStatus.running;
      _schedule();
    }
    notifyListeners();
  }

  void cancel() {
    _timer?.cancel();
    status = RunStatus.cancelled;
    notifyListeners();
  }

  List<double> predictions(Matrix rows, {bool alternate = false}) =>
      (alternate ? comparison : model)!.predict(rows);
  String score(List<int> rows, {bool alternate = false}) {
    if (history.isEmpty) return '—';
    final x = rows.map((i) => scaled[i]).toList(),
        y = rows.map((i) => data.y[i]).toList();
    if (experiment == Experiment.clustering) {
      final centers = (alternate ? comparisonKmeans : kmeans)!.centroids;
      final labels = (alternate ? comparisonKmeans : kmeans)!.predict(x);
      var total = 0.0;
      for (var i = 0; i < x.length; i++) {
        for (var j = 0; j < 2; j++) {
          total += pow(x[i][j] - centers[labels[i]][j], 2);
        }
      }
      return 'Mean distance² ${(total / x.length).toStringAsFixed(3)}';
    }
    final p = predictions(x, alternate: alternate);
    return experiment == Experiment.regression
        ? 'RMSE ${rootMeanSquaredError(y, p).toStringAsFixed(3)}'
        : 'Accuracy ${(100 * classificationMetrics(y, p).accuracy).toStringAsFixed(1)}%';
  }

  String get baseline {
    if (experiment == Experiment.clustering) {
      return 'Unsupervised • lower held-out distance is better';
    }
    final train = split.train.map((i) => data.y[i]).toList();
    final mean = train.reduce((a, b) => a + b) / train.length;
    final y = split.validation.map((i) => data.y[i]).toList();
    final p = List.filled(
      y.length,
      experiment == Experiment.regression ? mean : (mean >= .5 ? 1.0 : 0.0),
    );
    return experiment == Experiment.regression
        ? 'Train-mean baseline • validation RMSE ${rootMeanSquaredError(y, p).toStringAsFixed(3)}'
        : 'Train-majority baseline • validation accuracy ${(classificationMetrics(y, p).accuracy * 100).toStringAsFixed(1)}%';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
