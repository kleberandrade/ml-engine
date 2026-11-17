enum LabDataError { structure, numericRow, tooFewRows, binaryLabels, magnitude }

class LabDataException extends FormatException {
  final LabDataError code;
  final int? row;
  const LabDataException(this.code, {this.row})
    : super('Invalid laboratory data.');
}

class LabTrainingException extends ArgumentError {
  LabTrainingException() : super('k exceeds distinct points.');
}
