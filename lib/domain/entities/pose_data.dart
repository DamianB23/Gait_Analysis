// lib/domain/entities/pose_data.dart
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseData {
  final DateTime timestamp;
  final Map<PoseLandmarkType, PoseLandmark> landmarks;
  final double leftKneeAngle;
  final double rightKneeAngle;
  final double leftAnkleAngle;
  final double rightAnkleAngle;

  PoseData({
    required this.timestamp,
    required this.landmarks,
    required this.leftKneeAngle,
    required this.rightKneeAngle,
    required this.leftAnkleAngle,
    required this.rightAnkleAngle,
  });
}
