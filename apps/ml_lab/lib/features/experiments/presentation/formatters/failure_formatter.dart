import '../../../../app/l10n/app_strings.dart';
import '../../domain/lab_failure.dart';

String formatFailure(AppStrings s, Object error) {
  if (error is LabDataException) {
    return switch (error.code) {
      LabDataError.structure => s.t('errorCsvStructure'),
      LabDataError.numericRow => s.t('errorCsvRow', {'row': error.row ?? '?'}),
      LabDataError.tooFewRows => s.t('errorFewRows'),
      LabDataError.binaryLabels => s.t('errorBinary'),
      LabDataError.magnitude => s.t('errorMagnitude'),
    };
  }
  if (error is LabTrainingException) return s.t('errorClusters');
  return s.t('errorTraining');
}
