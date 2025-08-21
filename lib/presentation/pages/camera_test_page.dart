import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../main.dart'; // Para acceder a la variable global `cameras`

class CameraTestPage extends StatefulWidget {
  const CameraTestPage({Key? key}) : super(key: key);

  @override
  _CameraTestPageState createState() => _CameraTestPageState();
}

class _CameraTestPageState extends State<CameraTestPage> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Asegurarse de que 'cameras' esté disponible. Esto viene de main.dart
    if (cameras.isEmpty) {
      setState(() {
        _errorMessage = 'No se encontraron cámaras disponibles.';
      });
      return;
    }

    // Usar la primera cámara disponible (generalmente la trasera)
    final CameraDescription camera = cameras[0];

    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false, // No necesitamos audio para detección de pose
    );

    try {
      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } on CameraException catch (e) {
      String errorText = 'Error al inicializar la cámara: ${e.description}';
      if (e.code == 'CameraAccessDenied') {
        errorText =
            'Acceso a la cámara denegado. Por favor, otorga los permisos en la configuración de la aplicación.';
      } else if (e.code == 'CameraNotFound') {
        errorText =
            'No se pudo encontrar la cámara. Asegúrate de que tu dispositivo tenga una.';
      }
      setState(() {
        _errorMessage = errorText;
      });
      print("Camera initialization error: $e");
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado: $e';
      });
      print("Unexpected error during camera initialization: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error de Cámara')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (!_isCameraInitialized ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando Cámara')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Prueba de Cámara')),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: CameraPreview(_controller!),
      ),
    );
  }
}
