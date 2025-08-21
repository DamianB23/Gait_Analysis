// lib/domain/repositories/pose_detection_repository.dart

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../domain/entities/pose_data.dart';

abstract class PoseDetectionRepository {
  // La firma de la función se cambia para devolver una lista de poses.
  Future<List<Pose>> detectPose(InputImage inputImage);
}
