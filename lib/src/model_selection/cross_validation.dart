import '../data/matrix.dart';
import '../pipeline/pipeline.dart';
import '../preprocessing/transformer.dart';
import 'fold.dart';

/// Factory must return a NEW pipeline for every fold. Each scaler sees train only.
List<double> crossValidate(
  Matrix x,
  List<double> y,
  List<Fold> folds,
  Pipeline Function() createPipeline,
  double Function(List<double>, List<double>) metric,
) {
  validateTargets(x, y);
  if (folds.isEmpty) throw ArgumentError('At least one fold required.');
  final used = <Pipeline>{};
  final transformers = <Transformer>{};
  final estimators = <Object>{};
  return folds.map((fold) {
    final all = [...fold.train, ...fold.test];
    if (fold.train.isEmpty ||
        fold.test.isEmpty ||
        all.any((i) => i < 0 || i >= x.length) ||
        all.toSet().length != all.length) {
      throw ArgumentError('Fold rows must be valid, unique and disjoint.');
    }
    final pipeline = createPipeline();
    if (!used.add(pipeline) ||
        !transformers.add(pipeline.transformer) ||
        !estimators.add(pipeline.estimator)) {
      throw ArgumentError(
        'Create a fresh pipeline, transformer and estimator per fold.',
      );
    }
    pipeline.fit(
      fold.train.map((i) => x[i]).toList(),
      fold.train.map((i) => y[i]).toList(),
    );
    return metric(
      fold.test.map((i) => y[i]).toList(),
      pipeline.predict(fold.test.map((i) => x[i]).toList()),
    );
  }).toList();
}
