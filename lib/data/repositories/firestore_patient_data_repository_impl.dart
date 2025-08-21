import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/patient_data_repository.dart';
import '../../domain/entities/patient_session.dart';

class FirestorePatientDataRepositoryImpl implements PatientDataRepository {
  final FirebaseFirestore _firestore;

  FirestorePatientDataRepositoryImpl(this._firestore);

  @override
  Future<void> savePatientSession(PatientSession session) async {
    final patientMap = {
      "identification": session.identification,
      "session": session.session,
      "frame": session.frame,
      "leftankle": session.leftAnkle,
      "rightankle": session.rightAnkle,
      "leftknee": session.leftKnee,
      "rightknee": session.rightKnee,
    };
    await _firestore.collection("data_patients").add(patientMap);
  }
}
