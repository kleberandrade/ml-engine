import 'package:flutter/widgets.dart';

import '../l10n/app_strings.dart';

/// Locally drawn circular national-flag geometry; no remote image or emoji.
class LanguageFlag extends StatelessWidget {
  final AppLanguage language;
  const LanguageFlag({super.key, required this.language});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(painter: _FlagPainter(language)),
    ),
  );
}

class _FlagPainter extends CustomPainter {
  final AppLanguage language;
  const _FlagPainter(this.language);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 40, size.height / 40);
    canvas.clipPath(Path()..addOval(const Rect.fromLTWH(0, 0, 40, 40)));
    if (language == AppLanguage.ptBr) {
      canvas.drawColor(const Color(0xFF009739), BlendMode.srcOver);
      canvas.drawPath(
        Path()
          ..moveTo(20, 4)
          ..lineTo(38, 20)
          ..lineTo(20, 36)
          ..lineTo(2, 20)
          ..close(),
        Paint()..color = const Color(0xFFFEDD00),
      );
      canvas.drawCircle(
        const Offset(20, 20),
        9,
        Paint()..color = const Color(0xFF002776),
      );
      canvas.save();
      canvas.clipPath(
        Path()
          ..addOval(Rect.fromCircle(center: const Offset(20, 20), radius: 9)),
      );
      canvas.drawPath(
        Path()
          ..moveTo(10, 17)
          ..quadraticBezierTo(22, 14, 31, 23),
        Paint()
          ..color = const Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      for (final point in [
        const Offset(16, 22),
        const Offset(21, 25),
        const Offset(25, 22),
        const Offset(20, 20),
      ]) {
        canvas.drawCircle(point, .6, Paint()..color = const Color(0xFFFFFFFF));
      }
      canvas.restore();
    } else {
      canvas.drawColor(const Color(0xFF012169), BlendMode.srcOver);
      final diagonal = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..strokeWidth = 9;
      canvas.drawLine(const Offset(0, 0), const Offset(40, 40), diagonal);
      canvas.drawLine(const Offset(40, 0), const Offset(0, 40), diagonal);
      diagonal
        ..color = const Color(0xFFC8102E)
        ..strokeWidth = 3;
      canvas.drawLine(const Offset(0, 0), const Offset(40, 40), diagonal);
      canvas.drawLine(const Offset(40, 0), const Offset(0, 40), diagonal);
      final white = Paint()..color = const Color(0xFFFFFFFF);
      canvas.drawRect(const Rect.fromLTWH(14, 0, 12, 40), white);
      canvas.drawRect(const Rect.fromLTWH(0, 14, 40, 12), white);
      final red = Paint()..color = const Color(0xFFC8102E);
      canvas.drawRect(const Rect.fromLTWH(17, 0, 6, 40), red);
      canvas.drawRect(const Rect.fromLTWH(0, 17, 40, 6), red);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlagPainter oldDelegate) =>
      language != oldDelegate.language;
}
