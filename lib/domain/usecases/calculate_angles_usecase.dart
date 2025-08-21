// lib/domain/usecases/calculate_angles_usecase.dart

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';
import '../entities/angles.dart';

class CalculateAnglesUseCase {
  Future<AngleData> execute(Pose pose) async {
    final landmarks = pose.landmarks;

    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

    double leftKneeAngle = 0;
    if (leftHip != null && leftKnee != null && leftAnkle != null) {
      leftKneeAngle = _calculateAngle(leftHip, leftKnee, leftAnkle);
    }

    double rightKneeAngle = 0;
    if (rightHip != null && rightKnee != null && rightAnkle != null) {
      rightKneeAngle = _calculateAngle(rightHip, rightKnee, rightAnkle);
    }
    double leftAnkleAngle = 0;
    // Lógica para calcular el ángulo del tobillo izquierdo
    if (leftKnee != null &&
        leftAnkle != null &&
        landmarks[PoseLandmarkType.leftHeel] != null) {
      final leftHeel = landmarks[PoseLandmarkType.leftHeel]!;
      leftAnkleAngle = _calculateAngle(leftKnee, leftAnkle, leftHeel);
    }

    double rightAnkleAngle = 0;
    // Lógica para calcular el ángulo del tobillo derecho
    if (rightKnee != null &&
        rightAnkle != null &&
        landmarks[PoseLandmarkType.rightHeel] != null) {
      final rightHeel = landmarks[PoseLandmarkType.rightHeel]!;
      rightAnkleAngle = _calculateAngle(rightKnee, rightAnkle, rightHeel);
    }

    double hipDropAngle = 0;
    if (leftHip != null && rightHip != null) {
      // Usamos un punto "vertical" para calcular la inclinación de la línea de la cadera.
      // Un punto imaginario directamente debajo de una de las caderas.
      final verticalHipPoint = PoseLandmark(
        type: PoseLandmarkType.leftHip,
        x: leftHip.x,
        y: leftHip.y + 100,
        z: leftHip.z,
        likelihood: leftHip.likelihood,
      );

      // El ángulo entre la línea de la cadera (leftHip, rightHip) y la vertical
      hipDropAngle = 90 - _calculateAngle(verticalHipPoint, leftHip, rightHip);
    }

    return AngleData(
      leftKnee: leftKneeAngle,
      rightKnee: rightKneeAngle,
      leftAnkle: leftAnkleAngle,
      rightAnkle: rightAnkleAngle,
      hipDrop: hipDropAngle,
    );
  }

  double _calculateAngle(
    PoseLandmark joint1,
    PoseLandmark joint2,
    PoseLandmark joint3,
  ) {
    // Lógica para calcular el ángulo
    final double angle = degrees(
      atan2(joint3.y - joint2.y, joint3.x - joint2.x) -
          atan2(joint1.y - joint2.y, joint1.x - joint2.x),
    );

    // Asegura que el ángulo esté en el rango [0, 360]
    return (angle.abs() > 180 ? 360.0 - angle.abs() : angle.abs()).toDouble();
  }
}

// Función de ayuda para convertir radianes a grados
double degrees(double radians) {
  return radians * 180 / pi;
}
