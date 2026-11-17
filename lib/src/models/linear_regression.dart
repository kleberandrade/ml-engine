import 'gradient_model.dart';

class LinearRegression extends GradientModel {
  LinearRegression({super.learningRate = .05, super.iterations = 1000})
    : super(logistic: false);
}
