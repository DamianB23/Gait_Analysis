// Si la estructura del documento en Firestore fuera más compleja
// y necesitara un modelo intermedio para el mapeo.
/*
import '../../domain/entities/patient_session.dart';

class PatientSessionModel {
  final String identification;
  final int session;
  final int frame;
  final double leftAnkle;
  final double rightAnkle;
  final double leftKnee;
  final double rightKnee;

  PatientSessionModel({
    required this.identification,
    required this.session,
    required this.frame,
    required this.leftAnkle,
    required this.rightAnkle,
    required this.leftKnee,
    required this.rightKnee,
  });

  factory PatientSessionModel.fromEntity(PatientSession entity) {
    return PatientSessionModel(
      identification: entity.identification,
      session: entity.session,
      frame: entity.frame,
      leftAnkle: entity.leftAnkle,
      rightAnkle: entity.rightAnkle,
      leftKnee: entity.leftKnee,
      rightKnee: entity.rightKnee,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "identification": identification,
      "session": session,
      "frame": frame,
      "leftankle": leftAnkle,
      "rightankle": rightAnkle,
      "leftknee": leftKnee,
      "rightknee": rightKnee,
    };
  }
}
*/
