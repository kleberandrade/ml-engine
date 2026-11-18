import '../data/matrix.dart';
import '../pipeline/pipeline.dart';
import '../preprocessing/transformer.dart';
import 'fold.dart';

/// Fits and scores a fresh pipeline on each supplied fold, returning one score per fold.
///
/// [createPipeline] must return a new pipeline, transformer AND estimator on each
/// call. Each transformer sees training rows only. [metric] receives actual
/// held-out targets first, predicted values second; its result is returned as-is
/// without averaging or checking finiteness/direction (higher/lower is better).
///
/// Throws [ArgumentError] for invalid [x]/[y], no folds, empty/duplicate/overlapping
/// indices within a fold, out-of-range indices or reused components. Different
/// folds may overlap; custom folds need not hold out every row exactly once.
/// Model/transformer/scorer exceptions propagate; previously created components
/// may already be fitted. Hyperparameter search must wrap this process without
/// using final-test rows. `kFold` and `stratifiedKFold` create standard partitions.
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
