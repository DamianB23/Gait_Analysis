// lib/domain/usecases/calculate_jump_height_usecase.dart

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// El resultado se devuelve como un DTO/Entity simple
class JumpHeightResult {
  final double currentY;
  final double yMax;
  final double yMin;
  final double heightInPixels;

  JumpHeightResult({
    required this.currentY,
    required this.yMax,
    required this.yMin,
    required this.heightInPixels,
  });
}

class CalculateJumpHeightUseCase {
  /// Ejecuta el cálculo de la posición vertical clave (e.g., tobillo) y actualiza
  /// los valores máximos/mínimos para determinar la altura del salto.
  ///
  /// El estado de Y_max y Y_min debe ser mantenido por la capa de Presentación/Controller,
  /// ya que este caso de uso es puramente funcional (no guarda estado).
  ///
  /// En ML Kit, la coordenada Y es 0 en la parte superior y aumenta hacia abajo.
  /// Por lo tanto: Y más grande = Posición más baja (tierra). Y más pequeña = Posición más alta (pico del salto).
  JumpHeightResult execute({
    required Pose pose,
    required double currentYMax,
    required double currentYMin,
  }) {
    final landmarks = pose.landmarks;

    final leftAnkle = landmarks[PoseLandmarkType.leftFootIndex];
    final rightAnkle = landmarks[PoseLandmarkType.rightFootIndex];

    double currentY = 0;
    // Usamos el Tobillo para una medición más precisa del despegue y aterrizaje.
    if (leftAnkle != null && rightAnkle != null) {
      // Promedio para robustez
      currentY = (leftAnkle.y + rightAnkle.y) / 2;
    } else if (leftAnkle != null) {
      currentY = leftAnkle.y;
    } else if (rightAnkle != null) {
      currentY = rightAnkle.y;
    }

    if (currentY == 0) {
      // No se detectó ninguna pose útil, devuelve los valores actuales.
      return JumpHeightResult(
        currentY: 0,
        yMax: currentYMax,
        yMin: currentYMin,
        heightInPixels: currentYMax - currentYMin,
      );
    }

    // Actualiza la posición más baja (Y-coordenada más grande)
    final newYMax = currentY > currentYMax ? currentY : currentYMax;
    // Actualiza la posición más alta (Y-coordenada más pequeña)
    final newYMin = currentY < currentYMin ? currentY : currentYMin;

    // Calcula la altura del salto en píxeles (distancia entre el punto más bajo y el más alto)
    final heightInPixels = newYMax - newYMin;

    return JumpHeightResult(
      currentY: currentY,
      yMax: newYMax,
      yMin: newYMin,
      heightInPixels: heightInPixels,
    );
  }
}
