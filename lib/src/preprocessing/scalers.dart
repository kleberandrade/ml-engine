import 'dart:math';
import '../data/matrix.dart';
import 'transformer.dart';

/// Population standardization. A rejected fit preserves previous statistics.
class StandardScaler implements Transformer {
  List<double>? _center, _scale;
  @override
  void fit(Matrix x) {
    final n = validateMatrix(x);
    final center = List.generate(
      n,
      (j) => x.fold(0.0, (s, r) => s + r[j]) / x.length,
    );
    final scale = List<double>.generate(n, (j) {
      final sd = sqrt(
        x.fold(0.0, (s, r) => s + pow(r[j] - center[j], 2)) / x.length,
      );
      return sd == 0 ? 1 : sd;
    });
    if (center.any((v) => !v.isFinite) || scale.any((v) => !v.isFinite)) {
      throw ArgumentError('Scaling overflow. Rescale input magnitudes.');
    }
    _center = center;
    _scale = scale;
  }

  @override
  Matrix transform(Matrix x) => _transform(x, _center, _scale);
}

/// Unit-range scaling. A rejected fit preserves previous statistics.
class MinMaxScaler implements Transformer {
  List<double>? _min, _range;
  @override
  void fit(Matrix x) {
    final n = validateMatrix(x);
    final minimum = List.generate(n, (j) => x.map((r) => r[j]).reduce(min));
    final range = List<double>.generate(n, (j) {
      final range = x.map((r) => r[j]).reduce(max) - minimum[j];
      return range == 0 ? 1 : range;
    });
    if (range.any((v) => !v.isFinite)) {
      throw ArgumentError('Scaling overflow.');
    }
    _min = minimum;
    _range = range;
  }

  @override
  Matrix transform(Matrix x) => _transform(x, _min, _range);
}

Matrix _transform(Matrix x, List<double>? center, List<double>? scale) {
  if (center == null || scale == null) {
    throw StateError('Fit the transformer first.');
  }
  validateMatrix(x, columns: center.length);
  final result = x
      .map((r) => List.generate(r.length, (j) => (r[j] - center[j]) / scale[j]))
      .toList();
  validateMatrix(result);
  return result;
}
