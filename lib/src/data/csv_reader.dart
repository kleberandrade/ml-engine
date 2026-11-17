import 'dataset.dart';

enum CsvError { invalidStructure, invalidRow }

class CsvFormatException extends FormatException {
  final CsvError code;
  final int? row;
  const CsvFormatException(this.code, String message, {this.row})
    : super(message);
}

/// Strict numeric CSV: no quoted fields; header x1,x2,y, 2..500 rows.
Dataset parseCsv(String input, {int maxRows = 500}) {
  final lines = input.trim().split(RegExp(r'\r?\n'));
  if (lines.first.trim() != 'x1,x2,y' ||
      lines.length < 3 ||
      lines.length > maxRows + 1) {
    throw CsvFormatException(
      CsvError.invalidStructure,
      'Use header x1,x2,y and 2–$maxRows numeric rows.',
    );
  }
  final x = <List<double>>[];
  final y = <double>[];
  for (var i = 1; i < lines.length; i++) {
    final values = lines[i]
        .split(',')
        .map((s) => double.tryParse(s.trim()))
        .toList();
    if (values.length != 3 || values.any((v) => v == null || !v.isFinite)) {
      throw CsvFormatException(
        CsvError.invalidRow,
        'Row ${i + 1}: expected three finite numbers.',
        row: i + 1,
      );
    }
    x.add([values[0]!, values[1]!]);
    y.add(values[2]!);
  }
  return Dataset(x, y);
}
