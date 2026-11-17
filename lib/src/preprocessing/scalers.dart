import 'dart:math';
import '../data/matrix.dart';
import 'transformer.dart';

class StandardScaler implements Transformer {
  List<double>? _center, _scale;
  @override
  void fit(Matrix x) {
    final n = validateMatrix(x);
    _center = List.generate(
      n,
      (j) => x.fold(0.0, (s, r) => s + r[j]) / x.length,
    );
    _scale = List.generate(n, (j) {
      final sd = sqrt(
        x.fold(0.0, (s, r) => s + pow(r[j] - _center![j], 2)) / x.length,
      );
      return sd == 0 ? 1 : sd;
    });
    if (_center!.any((v) => !v.isFinite) || _scale!.any((v) => !v.isFinite)) {
      throw ArgumentError('Scaling overflow. Rescale input magnitudes.');
    }
  }

  @override
  Matrix transform(Matrix x) => _transform(x, _center, _scale);
}

class MinMaxScaler implements Transformer {
  List<double>? _min, _range;
  @override
  void fit(Matrix x) {
    final n = validateMatrix(x);
    _min = List.generate(n, (j) => x.map((r) => r[j]).reduce(min));
    _range = List.generate(n, (j) {
      final range = x.map((r) => r[j]).reduce(max) - _min![j];
      return range == 0 ? 1 : range;
    });
    if (_range!.any((v) => !v.isFinite)) {
      throw ArgumentError('Scaling overflow.');
    }
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
