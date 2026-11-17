import 'package:ml_engine/ml_engine.dart';

void main() {
  final x = List.generate(40, (i) => [i.toDouble()]);
  final y = x.map((r) => 3 * r[0] + 2).toList();
  final split = trainValidationTestSplit(x.length, seed: 42);
  Matrix rows(List<int> indices) => indices.map((i) => x[i]).toList();
  List<double> targets(List<int> indices) => indices.map((i) => y[i]).toList();
  Pipeline create() => Pipeline(
    StandardScaler(),
    LinearRegression(learningRate: .1, iterations: 1000),
  );
  final pipeline = create()..fit(rows(split.train), targets(split.train));
  print(
    'Test RMSE: ${rootMeanSquaredError(targets(split.test), pipeline.predict(rows(split.test)))}',
  );
  print(
    'Prediction for x=50: ${pipeline.predict([
      [50],
    ]).single} (expected 152)',
  );
  print(
    '5-fold MSE: ${crossValidate(x, y, kFold(x.length, seed: 42), create, meanSquaredError)}',
  );
  final logistic = Pipeline(StandardScaler(), LogisticRegression())
    ..fit(
      [
        [-2],
        [-1],
        [1],
        [2],
      ],
      [0, 0, 1, 1],
    );
  print(
    'Binary classes: ${logistic.predict([
      [-3],
      [3],
    ])}',
  );
  final clusters = KMeans(k: 2, seed: 7)
    ..fit([
      [0, 0],
      [0, 2],
      [10, 10],
      [10, 12],
    ]);
  print('Centroids: ${clusters.centroids}; inertia: ${clusters.inertia}');
}
