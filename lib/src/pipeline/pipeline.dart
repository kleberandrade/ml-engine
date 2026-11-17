import '../data/matrix.dart';
import '../models/estimator.dart';
import '../preprocessing/transformer.dart';

/// Construct a fresh transformer and estimator for each validation fold.
class Pipeline implements Estimator {
  final Transformer transformer;
  final Estimator estimator;
  Pipeline(this.transformer, this.estimator);
  @override
  void fit(Matrix x, List<double> y) {
    validateTargets(x, y);
    transformer.fit(x);
    estimator.fit(transformer.transform(x), y);
  }

  Matrix transform(Matrix x) => transformer.transform(x);
  @override
  List<double> predict(Matrix x) => estimator.predict(transform(x));
}
