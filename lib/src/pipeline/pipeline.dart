import '../data/matrix.dart';
import '../models/estimator.dart';
import '../preprocessing/transformer.dart';

/// Construct a fresh transformer and estimator for each validation fold.
///
/// A failed fit invalidates this composition until a successful fit. Generic
/// components cannot be rolled back; do not refit them outside this pipeline.
class Pipeline implements Estimator {
  final Transformer transformer;
  final Estimator estimator;
  bool _fitted = false;
  Pipeline(this.transformer, this.estimator);
  @override
  void fit(Matrix x, List<double> y) {
    _fitted = false;
    validateTargets(x, y);
    transformer.fit(x);
    estimator.fit(transformer.transform(x), y);
    _fitted = true;
  }

  Matrix transform(Matrix x) {
    if (!_fitted) throw StateError('Fit the pipeline successfully first.');
    return transformer.transform(x);
  }

  @override
  List<double> predict(Matrix x) => estimator.predict(transform(x));
}
