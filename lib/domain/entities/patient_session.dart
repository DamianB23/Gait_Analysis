class PatientSession {
  final String identification;
  final int session;
  final int frame;
  final double leftAnkle;
  final double rightAnkle;
  final double leftKnee;
  final double rightKnee;

  PatientSession({
    required this.identification,
    required this.session,
    required this.frame,
    required this.leftAnkle,
    required this.rightAnkle,
    required this.leftKnee,
    required this.rightKnee,
  });
}
