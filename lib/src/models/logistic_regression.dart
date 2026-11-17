import '../data/matrix.dart';
import 'gradient_model.dart';

class LogisticRegression extends GradientModel {
  LogisticRegression({super.learningRate = .1, super.iterations = 1000})
    : super(logistic: true);
  List<double> probabilities(Matrix x) => rawPredictions(x);
}
