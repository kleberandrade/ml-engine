import 'package:ml_engine/ml_engine.dart';

import '../domain/experiment.dart';
import 'plot_bounds.dart';
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

/// Evaluated values only: painters never hold a mutable direct-fit model.
class PredictionSamples {
  final Matrix rows;
  final List<double> a, b;
  final int columns, gridRows;
  PredictionSamples(
    Matrix rows,
    List<double> a,
    List<double> b, {
    this.columns = 0,
    this.gridRows = 0,
  }) : rows = List.unmodifiable(rows.map((r) => List<double>.unmodifiable(r))),
       a = List.unmodifiable(a),
       b = List.unmodifiable(b);
}

class PlotSnapshot {
  final Experiment experiment;
  final PlotBounds bounds;
  final PredictionSamples? samples;
  final Matrix scaled;
  final List<double> targets;
  final Set<int> train;
  final List<int>? labels;
  final Matrix centroidsA, centroidsB;
  final LinearSurface? modelA, modelB;
  factory PlotSnapshot.fromSession(ExperimentSession session) {
    final regression = session.settings.experiment.isRegression;
    final bounds = PlotBounds.fromData(
      session.scaled,
      session.data.y,
      regression: regression,
    );
    PredictionSamples? samples;
    if ((session.settings.experiment.isDirect ||
            session.settings.experiment.isBoost) &&
        session.hasResults) {
      if (regression) {
        final rows = List.generate(
          60,
          (i) => [bounds.xmin + i / 59 * (bounds.xmax - bounds.xmin), 0.0],
        );
        samples = PredictionSamples(
          rows,
          session.predict(rows),
          session.predict(rows, alternate: true),
        );
      } else {
        const nx = 24, ny = 16;
        final rows = [
          for (var j = 0; j < ny; j++)
            for (var i = 0; i < nx; i++)
              [
                bounds.xmin + (i + .5) / nx * (bounds.xmax - bounds.xmin),
                bounds.ymin + (j + .5) / ny * (bounds.ymax - bounds.ymin),
              ],
        ];
        samples = PredictionSamples(
          rows,
          session.predict(rows),
          const [],
          columns: nx,
          gridRows: ny,
        );
      }
    }
    return PlotSnapshot._(session, bounds, samples);
  }
  PlotSnapshot._(ExperimentSession session, this.bounds, this.samples)
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
