/// A row-major numeric matrix: outer entries are samples, inner entries features.
///
/// Every engine operation requires at least one row and one feature, rectangular
/// rows and finite values. This alias itself does not validate or copy lists;
/// use [validateMatrix] or `Dataset` at the boundary of application input.
typedef Matrix = List<List<double>>;

/// Validates [x] and returns its feature count.
///
/// When [columns] is provided, every row must have exactly that width; otherwise
/// width comes from the first row. Throws [ArgumentError] for empty matrices,
/// empty first rows, unequal widths or nonfinite entries. Does not copy [x].
int validateMatrix(Matrix x, {int? columns}) {
  if (x.isEmpty || x.first.isEmpty) {
    throw ArgumentError('Expected a nonempty matrix.');
  }
  final width = columns ?? x.first.length;
  if (x.any((r) => r.length != width || r.any((v) => !v.isFinite))) {
    throw ArgumentError('Rows must have $width finite values.');
  }
  return width;
}

/// Validates [x] and one finite target per row in [y].
///
/// Throws [ArgumentError] for invalid matrix shape, different sample/target counts
/// or NaN/infinite targets. Does not impose classifier-specific label constraints
/// or copy either input.
void validateTargets(Matrix x, List<double> y) {
  validateMatrix(x);
  if (x.length != y.length || y.any((v) => !v.isFinite)) {
    throw ArgumentError('Expected one finite target per row.');
  }
}
