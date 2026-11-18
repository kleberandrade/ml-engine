import 'dataset.dart';

/// Language-independent category of a strict CSV parsing failure.
enum CsvError {
  /// Wrong header or a row count outside the parser's accepted limits.
  invalidStructure,

  /// A data row does not contain exactly three finite numeric fields.
  invalidRow,
}

/// A CSV format failure with a stable [code] and optional source [row].
class CsvFormatException extends FormatException {
  /// Machine-readable category; use it to localize application error messages.
  final CsvError code;

  /// One-based line number, counting the header as line 1; null for structural errors.
  final int? row;

  /// Creates an error with a human-readable [message] and optional line number.
  const CsvFormatException(this.code, String message, {this.row})
    : super(message);
}

/// Parses two features and one target from strict numeric CSV.
///
/// Requires the case-sensitive header `x1,x2,y` and 2..[maxRows] data rows.
/// Trims outer input and each numeric field, accepts LF/CRLF and dot decimals,
/// and does not support quoted fields, missing values or alternate delimiters.
/// Returns an owned immutable [Dataset]. Throws [CsvFormatException] with
/// [CsvError.invalidStructure] for header/count errors or [CsvError.invalidRow]
/// with a one-based source line for malformed/nonfinite numeric rows.
/// Classification labels are checked by the estimator, not this parser.
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
