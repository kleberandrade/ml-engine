import 'dart:math';

import 'package:ml_engine/ml_engine.dart';

/// Shared sample/axis geometry; sampling and painting use identical coordinates.
class PlotBounds {
  final double xmin, xmax, ymin, ymax;
  const PlotBounds(this.xmin, this.xmax, this.ymin, this.ymax);
  factory PlotBounds.fromData(
    Matrix x,
    List<double> targets, {
    required bool regression,
  }) {
    final xs = x.map((r) => r[0]),
        ys = regression ? targets : x.map((r) => r[1]);
    final xmin = xs.reduce(min),
        xmax = xs.reduce(max),
        ymin = ys.reduce(min),
        ymax = ys.reduce(max);
    final dx = max(.5, (xmax - xmin) * .1), dy = max(.5, (ymax - ymin) * .1);
    return PlotBounds(xmin - dx, xmax + dx, ymin - dy, ymax + dy);
  }
}
