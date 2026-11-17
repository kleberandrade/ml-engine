import '../data/matrix.dart';

abstract interface class Estimator {
  void fit(Matrix x, List<double> y);
  List<double> predict(Matrix x);
}
