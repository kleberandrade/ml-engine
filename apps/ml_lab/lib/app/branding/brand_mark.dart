import 'package:flutter/widgets.dart';

import '../l10n/app_strings.dart';

/// Original rising-seed mark; the matching SVG is used by the Web shell.
class BrandMark extends StatelessWidget {
  final bool compact;
  const BrandMark({super.key, this.compact = false});
  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.t('brandLabel'),
    image: true,
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 38,
            height: 38,
            child: CustomPaint(painter: _SeedPainter()),
          ),
          const SizedBox(width: 10),
          Text(
            compact ? 'ML' : 'ML / ENGINE',
            style: const TextStyle(
              color: Color(0xFF172B36),
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SeedPainter extends CustomPainter {
  const _SeedPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    final paint = Paint()
      ..color = const Color(0xFF006B62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(9, 51)
        ..lineTo(25, 17)
        ..lineTo(36, 38)
        ..lineTo(53, 10),
      paint,
    );
    canvas.drawCircle(
      const Offset(9, 51),
      5,
      Paint()..color = const Color(0xFF006B62),
    );
    canvas.drawCircle(
      const Offset(53, 10),
      7,
      Paint()..color = const Color(0xFF8D451F),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
