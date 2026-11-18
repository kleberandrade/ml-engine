import '../data/dataset.dart';
import '../data/matrix.dart';
import 'estimator.dart';

/// Uniform-vote nearest-neighbor classification with finite numeric class labels.
///
/// Uses Euclidean distance. Equal distances are ordered by original training row
/// index; equal class vote counts choose the smallest numeric label. Duplicated
/// locations remain separate, equally weighted observations, even at distance 0.
/// Fit copies training data; no iterative optimization or probabilities are used.
/// Scale features on training rows only, ideally with a `Pipeline`.
class KNNClassifier extends _KNN {
  /// Creates an unfitted model using exactly [k] uniformly weighted neighbors.
  ///
  /// Throws [ArgumentError] when k < 1; [fit] also requires k <= training row count.
  /// See the class documentation for label/distance ties and weighting conventions.
  KNNClassifier({super.k = 5});

  @override
  double _aggregate(List<double> targets) {
    final votes = <double, int>{};
    for (final target in targets) {
      votes.update(target, (count) => count + 1, ifAbsent: () => 1);
    }
    return votes.keys.reduce(
      (a, b) =>
          votes[a]! > votes[b]! || (votes[a] == votes[b] && a < b) ? a : b,
    );
  }
}

/// Uniform-mean nearest-neighbor regression; see [KNNClassifier] for tie rules.
///
/// K must be in 1..training row count. Prediction brute-forces distances and
/// sorts neighbors: O(n*d + n*log(n)) time and O(n) extra memory per query.
/// No KD-tree, distance weighting, extrapolation model or iterative cost exists.
class KNNRegressor extends _KNN {
  /// Creates an unfitted model using exactly [k] uniformly weighted neighbors.
  ///
  /// Throws [ArgumentError] when k < 1; [fit] also requires k <= training row count.
  /// See the class documentation for label/distance ties and weighting conventions.
  KNNRegressor({super.k = 5});

  @override
  double _aggregate(List<double> targets) {
    // Divide first to avoid overflowing an otherwise representable mean.
    final mean = targets.fold(0.0, (sum, y) => sum + y / targets.length);
    if (!mean.isFinite) {
      throw StateError('Prediction overflow. Rescale targets.');
    }
    return mean;
  }
}

abstract class _KNN implements Estimator {
  /// Positive neighbor count; fitting additionally requires k <= training row count.
  final int k;
  Dataset? _training;
  _KNN({required this.k}) {
    if (k < 1) throw ArgumentError.value(k, 'k', 'Must be positive.');
  }

  /// Validates and owns copies of finite rectangular [x] and aligned targets [y].
  ///
  /// Throws [ArgumentError] for invalid shapes/values or k greater than row count.
  /// Classification accepts arbitrary finite numeric labels, not just 0/1.
  /// Rejected fits preserve the previous training set. Successful fitting replaces
  /// stored samples; it performs no iterative optimization.
  @override
  void fit(Matrix x, List<double> y) {
    validateTargets(x, y);
    if (k > x.length) throw ArgumentError('k exceeds training row count.');
    // Install only after all validation and copying succeeds.
    _training = Dataset(x, y);
  }

  double _aggregate(List<double> targets);

  /// Returns the uniform label vote or target mean of the k closest stored rows.
  ///
  /// Throws [StateError] before fitting, [ArgumentError] for invalid feature
  /// shape/values or distance overflow, and [StateError] for an overflowing
  /// regression mean. Equal distances follow training row order; vote ties prefer
  /// the smallest numeric label. Queries never mutate the stored training set.
  @override
  List<double> predict(Matrix x) {
    final training = _training;
    if (training == null) throw StateError('Fit the model first.');
    validateMatrix(x, columns: training.x.first.length);
    return x.map((query) {
      final neighbors =
          List.generate(training.x.length, (index) {
            var distance = 0.0;
            for (var j = 0; j < query.length; j++) {
              final difference = query[j] - training.x[index][j];
              distance += difference * difference;
            }
            if (!distance.isFinite) {
              throw ArgumentError('Distance overflow. Scale input magnitudes.');
            }
            return (distance: distance, index: index);
          })..sort((a, b) {
            final order = a.distance.compareTo(b.distance);
            return order == 0 ? a.index.compareTo(b.index) : order;
          });
      return _aggregate(
        neighbors.take(k).map((n) => training.y[n.index]).toList(),
      );
    }).toList();
  }
}
