import 'package:material_ui/material_ui.dart';

import '../features/experiments/presentation/lab_page.dart';
import 'theme.dart';

class MlLab extends StatelessWidget {
  const MlLab({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ML Engine • Learning laboratory',
    debugShowCheckedModeBanner: false,
    theme: buildLabTheme(),
    home: const LabPage(),
  );
}
