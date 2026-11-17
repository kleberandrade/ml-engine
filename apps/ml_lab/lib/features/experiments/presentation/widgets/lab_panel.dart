import 'package:material_ui/material_ui.dart';

class LabPanel extends StatelessWidget {
  final Widget child;
  const LabPanel({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFDAE3DD)),
    ),
    child: child,
  );
}
