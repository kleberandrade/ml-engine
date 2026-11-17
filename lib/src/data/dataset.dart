import 'matrix.dart';

class Dataset {
  final Matrix x;
  final List<double> y;
  Dataset(Matrix x, List<double> y)
    : x = List.unmodifiable(x.map((r) => List<double>.unmodifiable(r))),
      y = List.unmodifiable(y) {
    validateTargets(x, y);
  }
}
