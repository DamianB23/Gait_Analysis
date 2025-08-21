import '../entities/patient_session.dart';

abstract class PatientDataRepository {
  Future<void> savePatientSession(PatientSession session);
}
