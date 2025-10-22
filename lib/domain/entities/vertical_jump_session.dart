// lib/domain/entities/vertical_jump_session.dart

class VerticalJumpSession {
  //final String identification;
  //final int session;
  final int frame;
  final double maxY; // Posición Y más grande (punto más bajo/agachado)
  final double minY; // Posición Y más pequeña (pico del salto)
  final double heightCm; // Altura final calculada en centímetros

  VerticalJumpSession({
    //required this.identification,
    //required this.session,
    required this.frame,
    required this.maxY,
    required this.minY,
    required this.heightCm,
  });

  // Método para convertir la entidad en un mapa (útil para Firestore)
  Map<String, dynamic> toMap() {
    return {
      //  'identification': identification,
      //'session': session,
      'frame': frame,
      'maxY': maxY,
      'minY': minY,
      'heightCm': heightCm,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'VerticalJumpSession(frame: $frame, maxY: ${maxY.toStringAsFixed(2)}, minY: ${minY.toStringAsFixed(2)}, heightCm: ${heightCm.toStringAsFixed(2)})';
  }
}
