import 'package:flutter/widgets.dart';

const plotColors = [
  Color(0xFF006B62),
  Color(0xFF8D451F),
  Color(0xFF6356A0),
  Color(0xFFB33362),
  Color(0xFF3166A0),
];
void paintPlotText(Canvas canvas, String text, Offset at) {
  final p = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(fontSize: 11, color: Color(0xFF4D626A)),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  p.paint(canvas, at);
}
