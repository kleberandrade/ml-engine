import 'dart:math';

import '../../../../app/l10n/app_strings.dart';

import 'package:flutter/widgets.dart';

import '../../application/plot_snapshot.dart';
import 'plot_style.dart';

class DataPainter extends CustomPainter {
  final PlotSnapshot c;
  final AppStrings strings;
  DataPainter(this.c, this.strings);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      44,
      12,
      max(1, size.width - 60),
      size.height - 42,
    );
    final ys = c.experiment.isRegression
        ? c.targets
        : c.scaled.map((r) => r[1]).toList();
    final xs = c.scaled.map((r) => r[0]).toList();
    final xmin = c.bounds.xmin,
        xmax = c.bounds.xmax,
        ymin = c.bounds.ymin,
        ymax = c.bounds.ymax;
    Offset point(double x, double y) => Offset(
      rect.left + (x - xmin) / (xmax - xmin) * rect.width,
      rect.bottom - (y - ymin) / (ymax - ymin) * rect.height,
    );
    if (c.experiment.isClassification &&
        (c.modelA != null || c.neighbors != null)) {
      final nx = c.neighbors?.columns ?? 30, ny = c.neighbors?.gridRows ?? 20;
      final rows = [
        for (var j = 0; j < ny; j++)
          for (var i = 0; i < nx; i++)
            [
              xmin + (i + .5) / nx * (xmax - xmin),
              ymin + (j + .5) / ny * (ymax - ymin),
            ],
      ];
      final decisions =
          c.neighbors?.a ??
          rows
              .map((row) => c.modelA!.value(row[0], row[1]) >= 0 ? 1.0 : 0.0)
              .toList();
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
              ..color = plotColors[decisions[j * nx + i] >= .5 ? 1 : 0]
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
      paintPlotText(
        canvas,
        strings.number(xmin + i / 4 * (xmax - xmin), 1),
        Offset(gx - 10, rect.bottom + 10),
      );
      paintPlotText(
        canvas,
        strings.number(ymax - i / 4 * (ymax - ymin), 1),
        Offset(0, gy - 6),
      );
    }
    canvas.save();
    canvas.clipRect(rect);
    if (c.experiment.isRegression &&
        (c.modelA != null || c.neighbors != null)) {
      for (final alternate in [false, true]) {
        final rows =
            c.neighbors?.rows ??
            List.generate(60, (i) => [xmin + i / 59 * (xmax - xmin), 0.0]);
        final predictions =
                (c.neighbors == null
                    ? null
                    : (alternate ? c.neighbors!.b : c.neighbors!.a)) ??
                rows
                    .map(
                      (row) => (alternate ? c.modelB : c.modelA)!.value(
                        row[0],
                        row[1],
                      ),
                    )
                    .toList(),
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
            ..color = plotColors[alternate ? 1 : 0]
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke,
        );
      }
    }
    if (c.experiment.isClassification && c.modelA != null) {
      for (final alternate in [false, true]) {
        final model = (alternate ? c.modelB : c.modelA)!;
        final w = model.coefficients;
        final paint = Paint()
          ..color = plotColors[alternate ? 1 : 0]
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
    final labels = c.labels;
    final train = c.train;
    for (var i = 0; i < xs.length; i++) {
      final color =
          plotColors[(labels?[i] ??
                  (c.experiment.isClassification ? c.targets[i].toInt() : 0)) %
              plotColors.length];
      final at = point(xs[i], ys[i]);
      final paint = Paint()
        ..color = color.withValues(alpha: .8)
        ..strokeWidth = 1.5
        ..style = train.contains(i) ? PaintingStyle.fill : PaintingStyle.stroke;
      if (c.experiment.isClassification && c.targets[i] == 1) {
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
    if (c.centroidsA.isNotEmpty) {
      for (final alternate in [false, true]) {
        for (final center in (alternate ? c.centroidsB : c.centroidsA)) {
          final at = point(center[0], center[1]);
          canvas.drawCircle(
            at,
            alternate ? 10 : 7,
            Paint()..color = const Color(0xFFFFFFFF),
          );
          final paint = Paint()
            ..color = plotColors[alternate ? 1 : 0]
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
