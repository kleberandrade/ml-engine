import '../../experiments/domain/experiment.dart';

class ExamplePreset {
  final String id;
  final Experiment experiment;
  final bool csv;
  const ExamplePreset(this.id, this.experiment, {this.csv = false});
}

const examplePresets = [
  ExamplePreset('linear', Experiment.regression),
  ExamplePreset('ridge', Experiment.ridge),
  ExamplePreset('tree-classification', Experiment.treeClassification),
  ExamplePreset('tree-regression', Experiment.treeRegression),
  ExamplePreset('knn-classification', Experiment.knnClassification),
  ExamplePreset('knn-regression', Experiment.knnRegression),
  ExamplePreset('binary', Experiment.classification),
  ExamplePreset('clusters', Experiment.clustering),
  ExamplePreset('csv', Experiment.regression, csv: true),
];
String linearCsvFixture() =>
    'x1,x2,y\n${List.generate(20, (i) => '$i,0,${2 * i + 1}').join('\n')}';
