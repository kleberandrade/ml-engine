import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ml_engine/ml_engine.dart';

import '../data/experiment_datasets.dart';
import '../domain/experiment.dart';
import '../domain/experiment_session.dart';
import 'plot_snapshot.dart';

enum RunStatus { ready, running, paused, complete, cancelled, failed }

/// Owns commands, notifications and timer lifetime; mathematics stays in Dart.
class LabViewModel extends ChangeNotifier {
  ExperimentSettings _settings = ExperimentSettings();
  late ExperimentSession _session;
  RunStatus _status = RunStatus.ready;
  Object? _error;
  bool _imported = false;
  Timer? _timer;
  PlotSnapshot? _directPlot;
  LabViewModel() {
    _session = ExperimentSession(generateDataset(_settings), _settings);
  }
  Experiment get experiment => _settings.experiment;
  int get seed => _settings.seed;
  int get epochs => _settings.epochs;
  int get nEstimators => _settings.nEstimators;
  ForestSummary? get forestSummary => _session.forestSummary;
  int get maxDepth => _settings.maxDepth;
  DecisionTreeNode? treeRoot({bool alternate = false}) =>
      _session.treeRoot(alternate: alternate);
  int get neighbors => _settings.neighbors;
  int get maxNeighbors => split.train.length < 15 ? split.train.length : 15;
  int get clusters => _settings.clusters;
  double get regularization => _settings.regularization;
  double coefficientNorm({bool alternate = false}) =>
      _session.coefficientNorm(alternate: alternate);
  double get learningRate => _settings.learningRate;
  RunStatus get status => _status;
  Object? get error => _error;
  bool get imported => _imported;
  Dataset get data => _session.data;
  DataSplit get split => _session.split;
  List<double> get history => _session.history;
  List<double> get comparisonHistory => _session.comparisonHistory;
  bool get active =>
      _status == RunStatus.running || _status == RunStatus.paused;
  PlotSnapshot get plot => experiment.isDirect
      ? (_directPlot ??= PlotSnapshot.fromSession(_session))
      : PlotSnapshot.fromSession(_session);
  ExperimentScore? score(List<int> rows, {bool alternate = false}) =>
      _session.evaluate(rows, alternate: alternate);
  ExperimentScore? get baseline => _session.baseline;
  void configure({
    int? seed,
    int? epochs,
    int? clusters,
    int? neighbors,
    int? maxDepth,
    int? nEstimators,
    double? learningRate,
    double? regularization,
  }) {
    if (active) {
      throw StateError('Stop the active run before changing settings.');
    }
    final next = _settings.copyWith(
      seed: seed,
      epochs: epochs,
      clusters: clusters,
      neighbors: neighbors,
      maxDepth: maxDepth,
      nEstimators: nEstimators,
      learningRate: learningRate,
      regularization: regularization,
    );
    final data = seed == null ? _session.data : generateDataset(next);
    final session = ExperimentSession(data, next);
    _settings = next;
    _replace(session, imported: seed == null && _imported);
  }

  void select(Experiment value) {
    final next = _settings.copyWith(experiment: value);
    final session = ExperimentSession(generateDataset(next), next);
    _settings = next;
    _replace(session, imported: false);
  }

  void generate() => _replace(
    ExperimentSession(generateDataset(_settings), _settings),
    imported: false,
  );
  void importCsv(String value) {
    // Parse and prepare before replacing: rejected imports preserve the current run.
    final next = ExperimentSession(parseLabCsv(value, experiment), _settings);
    _replace(next, imported: true);
  }

  void _replace(ExperimentSession session, {required bool imported}) {
    _timer?.cancel();
    _session = session;
    _directPlot = null;
    _imported = imported;
    _status = RunStatus.ready;
    _error = null;
    notifyListeners();
  }

  void reset() =>
      _replace(ExperimentSession(data, _settings), imported: _imported);
  void start() {
    _timer?.cancel();
    _error = null;
    try {
      final next = ExperimentSession(data, _settings)..start();
      _session = next;
      _directPlot = null;
      if (experiment.isDirect) {
        _status = RunStatus.complete;
      } else {
        _status = RunStatus.running;
        _schedule();
      }
    } catch (error) {
      _status = RunStatus.failed;
      _error = error;
    }
    notifyListeners();
  }

  void _schedule() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => advance());
  }

  /// One bounded iteration per event-loop tick, on <=500 rows and two features.
  void advance() {
    if (_status != RunStatus.running) return;
    try {
      if (!_session.step()) {
        _timer?.cancel();
        _status = RunStatus.complete;
      }
    } catch (error) {
      _timer?.cancel();
      _status = RunStatus.failed;
      _error = error;
    }
    notifyListeners();
  }

  void pauseResume() {
    if (_status == RunStatus.running) {
      _timer?.cancel();
      _status = RunStatus.paused;
    } else if (_status == RunStatus.paused) {
      _status = RunStatus.running;
      _schedule();
    }
    notifyListeners();
  }

  void cancel() {
    if (!active) return;
    _timer?.cancel();
    _status = RunStatus.cancelled;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
