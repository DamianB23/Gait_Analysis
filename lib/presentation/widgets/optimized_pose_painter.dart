// lib/presentation/widgets/optimized_pose_painter.dart

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class OptimizedPosePainter extends CustomPainter {
  final Size absoluteImageSize;
  final List<Pose> poses;

  final Paint _leftPaint;
  final Paint _rightPaint;
  final Paint _hipPaint =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = Colors.blue
        ..strokeCap = StrokeCap.round;

  OptimizedPosePainter(this.absoluteImageSize, this.poses)
    : _leftPaint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..color = Colors.green
            ..strokeCap = StrokeCap.round,
      _rightPaint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..color = Colors.yellow
            ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty) return;

    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final pose = poses.first;

    final landmarks = pose.landmarks;
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final leftFoot = landmarks[PoseLandmarkType.leftFootIndex];
    final rightFoot = landmarks[PoseLandmarkType.rightFootIndex];

    void paintLine(
      PoseLandmark? joint1,
      PoseLandmark? joint2,
      Paint paintType,
    ) {
      if (joint1 == null || joint2 == null) return;

      canvas.drawLine(
        Offset(joint1.x * scaleX, joint1.y * scaleY),
        Offset(joint2.x * scaleX, joint2.y * scaleY),
        paintType,
      );
    }

    paintLine(leftHip, leftKnee, _leftPaint);
    paintLine(leftKnee, leftAnkle, _leftPaint);
    paintLine(rightHip, rightKnee, _rightPaint);
    paintLine(rightKnee, rightAnkle, _rightPaint);
    paintLine(leftAnkle, leftFoot, _leftPaint);
    paintLine(rightAnkle, rightFoot, _rightPaint);
    paintLine(leftHip, rightHip, _hipPaint);
  }

  @override
  bool shouldRepaint(OptimizedPosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
