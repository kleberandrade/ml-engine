typedef Matrix = List<List<double>>;

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

void validateTargets(Matrix x, List<double> y) {
  validateMatrix(x);
  if (x.length != y.length || y.any((v) => !v.isFinite)) {
    throw ArgumentError('Expected one finite target per row.');
  }
}
