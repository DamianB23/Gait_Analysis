// lib/data/repositories/mlkit_pose_detection_repository_impl.dart

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../domain/repositories/pose_detection_repository.dart';

class MLKitPoseDetectionRepositoryImpl implements PoseDetectionRepository {
  final PoseDetector _poseDetector;

  MLKitPoseDetectionRepositoryImpl(this._poseDetector);

  @override
  Future<List<Pose>> detectPose(InputImage inputImage) async {
    // Procesa la imagen y devuelve la lista de poses detectadas por ML Kit.
    final poses = await _poseDetector.processImage(inputImage);
    return poses;
  }
}
