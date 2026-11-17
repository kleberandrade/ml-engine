import 'dataset.dart';

/// Strict numeric CSV: no quoted fields; header x1,x2,y, 2..500 rows.
Dataset parseCsv(String input, {int maxRows = 500}) {
  final lines = input.trim().split(RegExp(r'\r?\n'));
  if (lines.first.trim() != 'x1,x2,y' ||
      lines.length < 3 ||
      lines.length > maxRows + 1) {
    throw const FormatException('Use header x1,x2,y and 2–500 numeric rows.');
  }
  final x = <List<double>>[];
  final y = <double>[];
  for (var i = 1; i < lines.length; i++) {
    final values = lines[i]
        .split(',')
        .map((s) => double.tryParse(s.trim()))
        .toList();
    if (values.length != 3 || values.any((v) => v == null || !v.isFinite)) {
      throw FormatException('Row ${i + 1}: expected three finite numbers.');
    }
    x.add([values[0]!, values[1]!]);
    y.add(values[2]!);
  }
  return Dataset(x, y);
}
