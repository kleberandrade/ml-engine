import 'dart:math';

import 'package:flutter/widgets.dart';

import 'controller.dart';

const _colors = [
  Color(0xFF006B62),
  Color(0xFF8D451F),
  Color(0xFF6356A0),
  Color(0xFFB33362),
  Color(0xFF3166A0),
];
void _text(Canvas canvas, String text, Offset at) {
  final p = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(fontSize: 11, color: Color(0xFF4D626A)),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  p.paint(canvas, at);
}

class DataPainter extends CustomPainter {
  final LabController c;
  DataPainter(this.c);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      44,
      12,
      max(1, size.width - 60),
      size.height - 42,
    );
    final ys = c.experiment == Experiment.regression
        ? c.data.y
        : c.scaled.map((r) => r[1]).toList();
    final xs = c.scaled.map((r) => r[0]).toList();
    var xmin = xs.reduce(min),
        xmax = xs.reduce(max),
        ymin = ys.reduce(min),
        ymax = ys.reduce(max);
    final dx = max(.5, (xmax - xmin) * .1), dy = max(.5, (ymax - ymin) * .1);
    xmin -= dx;
    xmax += dx;
    ymin -= dy;
    ymax += dy;
    Offset point(double x, double y) => Offset(
      rect.left + (x - xmin) / (xmax - xmin) * rect.width,
      rect.bottom - (y - ymin) / (ymax - ymin) * rect.height,
    );
    if (c.experiment == Experiment.classification && c.model != null) {
      const nx = 30, ny = 20;
      final rows = [
        for (var j = 0; j < ny; j++)
          for (var i = 0; i < nx; i++)
            [
              xmin + (i + .5) / nx * (xmax - xmin),
              ymin + (j + .5) / ny * (ymax - ymin),
            ],
      ];
      final probabilities = c.model!.rawPredictions(rows);
      for (var j = 0; j < ny; j++) {
        for (var i = 0; i < nx; i++) {
          canvas.drawRect(
            Rect.fromLTWH(
              rect.left + i / nx * rect.width,
              rect.top + (ny - j - 1) / ny * rect.height,
              rect.width / nx + .5,
              rect.height / ny + .5,
            ),
            Paint()
              ..color = _colors[probabilities[j * nx + i] >= .5 ? 1 : 0]
                  .withValues(alpha: .12),
          );
        }
      }
    }
    for (var i = 0; i <= 4; i++) {
      final gx = rect.left + i / 4 * rect.width,
          gy = rect.top + i / 4 * rect.height;
      canvas.drawLine(
        Offset(gx, rect.top),
        Offset(gx, rect.bottom),
        Paint()..color = const Color(0xFFDFE7E2),
      );
      canvas.drawLine(
        Offset(rect.left, gy),
        Offset(rect.right, gy),
        Paint()..color = const Color(0xFFDFE7E2),
      );
      _text(
        canvas,
        (xmin + i / 4 * (xmax - xmin)).toStringAsFixed(1),
        Offset(gx - 10, rect.bottom + 10),
      );
      _text(
        canvas,
        (ymax - i / 4 * (ymax - ymin)).toStringAsFixed(1),
        Offset(0, gy - 6),
      );
    }
    canvas.save();
    canvas.clipRect(rect);
    if (c.experiment == Experiment.regression && c.model != null) {
      for (final alternate in [false, true]) {
        final rows = List.generate(
          60,
          (i) => [xmin + i / 59 * (xmax - xmin), 0.0],
        );
        final predictions = c.predictions(rows, alternate: alternate),
            path = Path();
        for (var i = 0; i < rows.length; i++) {
          final at = point(rows[i][0], predictions[i]);
          if (i == 0) {
            path.moveTo(at.dx, at.dy);
          } else {
            path.lineTo(at.dx, at.dy);
          }
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = _colors[alternate ? 1 : 0]
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke,
        );
      }
    }
    if (c.experiment == Experiment.classification && c.model != null) {
      for (final alternate in [false, true]) {
        final model = (alternate ? c.comparison : c.model)!;
        final w = model.coefficients;
        final paint = Paint()
          ..color = _colors[alternate ? 1 : 0]
          ..strokeWidth = alternate ? 1.5 : 3;
        if (w[1].abs() > 1e-12) {
          canvas.drawLine(
            point(xmin, -(w[0] * xmin + model.intercept) / w[1]),
            point(xmax, -(w[0] * xmax + model.intercept) / w[1]),
            paint,
          );
        } else if (w[0].abs() > 1e-12) {
          final x = -model.intercept / w[0];
          canvas.drawLine(point(x, ymin), point(x, ymax), paint);
        }
      }
    }
    final labels = c.experiment == Experiment.clustering && c.kmeans != null
        ? c.kmeans!.predict(c.scaled)
        : null;
    final train = c.split.train.toSet();
    for (var i = 0; i < xs.length; i++) {
      final color =
          _colors[(labels?[i] ??
                  (c.experiment == Experiment.classification
                      ? c.data.y[i].toInt()
                      : 0)) %
              _colors.length];
      final at = point(xs[i], ys[i]);
      final paint = Paint()
        ..color = color.withValues(alpha: .8)
        ..strokeWidth = 1.5
        ..style = train.contains(i) ? PaintingStyle.fill : PaintingStyle.stroke;
      if (c.experiment == Experiment.classification && c.data.y[i] == 1) {
        canvas.drawPath(
          Path()
            ..moveTo(at.dx, at.dy - 4)
            ..lineTo(at.dx + 4, at.dy)
            ..lineTo(at.dx, at.dy + 4)
            ..lineTo(at.dx - 4, at.dy)
            ..close(),
          paint,
        );
      } else {
        canvas.drawCircle(at, 3.5, paint);
      }
    }
    if (c.kmeans != null) {
      for (final alternate in [false, true]) {
        for (final center
            in (alternate ? c.comparisonKmeans : c.kmeans)!.centroids) {
          final at = point(center[0], center[1]);
          canvas.drawCircle(
            at,
            alternate ? 10 : 7,
            Paint()..color = const Color(0xFFFFFFFF),
          );
          final paint = Paint()
            ..color = _colors[alternate ? 1 : 0]
            ..strokeWidth = 3;
          canvas.drawLine(
            at - const Offset(6, 0),
            at + const Offset(6, 0),
            paint,
          );
          canvas.drawLine(
            at - const Offset(0, 6),
            at + const Offset(0, 6),
            paint,
          );
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DataPainter oldDelegate) => true;
}

class CostPainter extends CustomPainter {
  final List<double> a, b;
  CostPainter(this.a, this.b);
  @override
  void paint(Canvas canvas, Size size) {
    if (a.isEmpty) {
      _text(
        canvas,
        'Train models to trace their learning curves.',
        const Offset(10, 40),
      );
      return;
    }
    final maxValue = max(1e-12, [...a, ...b].reduce(max)),
        length = max(2, max(a.length, b.length));
    final rect = Rect.fromLTWH(
      44,
      10,
      max(1, size.width - 60),
      size.height - 30,
    );
    _text(canvas, maxValue.toStringAsPrecision(3), const Offset(0, 4));
    _text(canvas, '0', Offset(22, rect.bottom - 5));
    for (var i = 0; i < 3; i++) {
      final y = rect.top + i / 2 * rect.height;
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        Paint()..color = const Color(0xFFDFE7E2),
      );
    }
    for (var m = 0; m < 2; m++) {
      final values = m == 0 ? a : b, path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = rect.left + i / (length - 1) * rect.width,
            y = rect.bottom - values[i] / maxValue * rect.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = _colors[m]
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
    _text(canvas, '1', Offset(rect.left, rect.bottom + 4));
    _text(
      canvas,
      '${max(a.length, b.length)} iterations',
      Offset(max(rect.left, rect.right - 90), rect.bottom + 4),
    );
  }

  @override
  bool shouldRepaint(covariant CostPainter oldDelegate) => true;
}
