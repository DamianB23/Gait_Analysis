import '../entities/patient_session.dart';
import '../repositories/patient_data_repository.dart';

class SavePatientSessionUseCase {
  final PatientDataRepository _repository;

  SavePatientSessionUseCase(this._repository);

  Future<void> execute(PatientSession session) {
    return _repository.savePatientSession(session);
  }
}
