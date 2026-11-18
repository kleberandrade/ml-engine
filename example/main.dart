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
  final ridge = Pipeline(StandardScaler(), RidgeRegression(lambda: 1))
    ..fit(rows(split.train), targets(split.train));
  print(
    'Ridge validation RMSE: ${rootMeanSquaredError(targets(split.validation), ridge.predict(rows(split.validation)))}',
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
  final neighbors = Pipeline(StandardScaler(), KNNClassifier(k: 3))
    ..fit(
      [
        [0],
        [1],
        [2],
      ],
      [0, 1, 1],
    );
  print(
    'KNN classes: ${neighbors.predict([
      [1.1],
    ])}',
  );
  final localMean = KNNRegressor(k: 2)
    ..fit(
      [
        [0],
        [2],
        [8],
      ],
      [0, 10, 30],
    );
  print(
    'KNN regression at x=3: ${localMean.predict([
      [3],
    ]).single} (expected 5)',
  );
  final tree = DecisionTreeClassifier(maxDepth: 1)
    ..fit(
      [
        [0],
        [1],
        [2],
        [3],
      ],
      [0, 0, 1, 1],
    );
  print(
    'Tree split: x <= ${tree.root.threshold}; predictions ${tree.predict([
      [1],
      [2],
    ])}',
  );
  final treeRegression = DecisionTreeRegressor(maxDepth: 1)
    ..fit(
      [
        [0],
        [1],
        [2],
        [3],
      ],
      [0, 2, 10, 12],
    );
  print(
    'Tree leaf means: ${treeRegression.predict([
      [.5],
      [2.5],
    ])} (expected [1,11])',
  );
  final forest = RandomForestRegressor(nEstimators: 5, maxDepth: 0, seed: 42)
    ..fit(
      [
        [0],
        [1],
        [2],
      ],
      [2, 4, 9],
    );
  final expectedMean =
      forest.bootstrapIndices
          .map(
            (bag) =>
                bag.map((i) => [2.0, 4.0, 9.0][i]).reduce((a, b) => a + b) /
                bag.length,
          )
          .reduce((a, b) => a + b) /
      forest.nEstimators;
  final prediction = forest.predict([
    [100],
  ]).single;
  if ((prediction - expectedMean).abs() > 1e-12) {
    throw StateError('Bootstrap mean mismatch.');
  }
  print(
    'Forest: ${forest.trees.length} stumps; mean $prediction (bootstrap mean $expectedMean)',
  );
  final boost =
      GradientBoostingRegressor(nEstimators: 1, maxDepth: 1, learningRate: .5)
        ..fit(
          [
            [0],
            [1],
            [2],
            [3],
          ],
          [0, 2, 10, 12],
        );
  final boosted = boost.predict([
    [0],
    [3],
  ]);
  if ((boosted[0] - 3.5).abs() > 1e-12 || (boosted[1] - 8.5).abs() > 1e-12) {
    throw StateError('Independent boosting stage fixture failed.');
  }
  print(
    'Boosting first stage: $boosted (expected [3.5,8.5]); loss ${boost.lossHistory.last} (expected 3.625)',
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
