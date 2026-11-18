import 'dart:math';

import '../../../../app/l10n/app_strings.dart';

import 'package:flutter/widgets.dart';

import 'plot_style.dart';

class CostPainter extends CustomPainter {
  final List<double> a, b;
  final AppStrings strings;
  final bool stages;
  CostPainter(this.a, this.b, this.strings, {this.stages = false});
  @override
  void paint(Canvas canvas, Size size) {
    if (a.isEmpty) {
      paintPlotText(canvas, strings.t('costEmpty'), const Offset(10, 40));
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
    paintPlotText(
      canvas,
      strings.language == AppLanguage.ptBr
          ? maxValue.toStringAsPrecision(3).replaceAll('.', ',')
          : maxValue.toStringAsPrecision(3),
      const Offset(0, 4),
    );
    paintPlotText(canvas, '0', Offset(22, rect.bottom - 5));
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
          ..color = plotColors[m]
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
    paintPlotText(
      canvas,
      stages ? '0' : '1',
      Offset(rect.left, rect.bottom + 4),
    );
    paintPlotText(
      canvas,
      strings.t(stages ? 'boostStages' : 'iterations', {
        'count': stages
            ? max(0, max(a.length, b.length) - 1)
            : max(a.length, b.length),
      }),
      Offset(max(rect.left, rect.right - 90), rect.bottom + 4),
    );
  }

  @override
  bool shouldRepaint(covariant CostPainter oldDelegate) => true;
}
