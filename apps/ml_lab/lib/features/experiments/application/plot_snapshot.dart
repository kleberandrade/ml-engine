import 'package:ml_engine/ml_engine.dart';

import '../domain/experiment.dart';
import '../domain/experiment_session.dart';

/// Immutable chart input: renderers never own or advance a mutable model.
class LinearSurface {
  final List<double> coefficients;
  final double intercept;
  LinearSurface(List<double> coefficients, this.intercept)
    : coefficients = List.unmodifiable(coefficients);
  double value(double x1, double x2) =>
      intercept + coefficients[0] * x1 + coefficients[1] * x2;
}

class PlotSnapshot {
  final Experiment experiment;
  final Matrix scaled;
  final List<double> targets;
  final Set<int> train;
  final List<int>? labels;
  final Matrix centroidsA, centroidsB;
  final LinearSurface? modelA, modelB;
  PlotSnapshot.fromSession(ExperimentSession session)
    : experiment = session.settings.experiment,
      scaled = session.scaled,
      targets = session.data.y,
      train = Set.unmodifiable(session.split.train),
      labels = session.clusterLabels == null
          ? null
          : List.unmodifiable(session.clusterLabels!),
      centroidsA = session.centroidsA,
      centroidsB = session.centroidsB,
      modelA = session.coefficientsA.isEmpty
          ? null
          : LinearSurface(session.coefficientsA, session.interceptA),
      modelB = session.coefficientsB.isEmpty
          ? null
          : LinearSurface(session.coefficientsB, session.interceptB);
}
