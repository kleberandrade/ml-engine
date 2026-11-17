import '../data/matrix.dart';

abstract interface class Transformer {
  void fit(Matrix x);
  Matrix transform(Matrix x);
}
