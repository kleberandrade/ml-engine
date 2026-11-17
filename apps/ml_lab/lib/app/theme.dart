import 'package:material_ui/material_ui.dart';

const ink = Color(0xFF172B36),
    teal = Color(0xFF006B62),
    paper = Color(0xFFF4F6F3);
ThemeData buildLabTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: teal),
  scaffoldBackgroundColor: paper,
  useMaterial3: true,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: ink,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: ink,
    ),
  ),
);
