// lib/presentation/pages/vertical_jump_analysis_page.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

// Importaciones de Arquitectura Limpia (adaptadas a los nombres del salto)
import '../../domain/usecases/calculate_jump_height_usecase.dart'; // NUEVO CASO DE USO
import '../../data/repositories/mlkit_pose_detection_repository_impl.dart';
import '../../data/repositories/firestore_patient_data_repository_impl.dart';
//import '../../domain/usecases/save_vertical_jump_session_usecase.dart'; // ASUMIDO
import '../../domain/entities/vertical_jump_session.dart'; // ASUMIDO
import '../../main.dart';
import '../widgets/optimized_pose_painter.dart';

class VerticalJumpAnalysisPage extends StatefulWidget {
  //final String identification;
  //final int session;
  const VerticalJumpAnalysisPage({
    Key? key,
    //required this.identification,
    //required this.session,
  }) : super(key: key);

  @override
  _VerticalJumpAnalysisPageState createState() =>
      _VerticalJumpAnalysisPageState();
}

class _VerticalJumpAnalysisPageState extends State<VerticalJumpAnalysisPage> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  String _errorMessage = '';
  late Size size;

  // Variables de Estado (Gestionadas por la Presentación)
  double _currentYPosition = 0;
  double _yMinTracker = double.infinity; // Y más pequeño = Punto más alto
  double _yMaxTracker = 0.0; // Y más grande = Punto más bajo
  double _jumpHeightInPixels = 0.0;
  double _jumpHeightInCm = 0.0;

  // 📏 CALIBRACIÓN: Factor de conversión (ejemplo, 10 píxeles por centímetro)
  static const double PIXELS_PER_CM_FACTOR = 10.0;

  late PoseDetector poseDetector;
  List<Pose>? _scanResults;
  CameraImage? img;
  bool isBusy = false;

  int _frameSkipCounter = 0;
  static const int FRAME_SKIP_COUNT = 3;
  DateTime? _lastProcessTime;
  static const int MIN_PROCESS_INTERVAL_MS = 100;

  int _frameSaveCounter = 0;
  static const int FRAME_SAVE_COUNT = 10;
  int frameCount = 1;

  // DEPENDENCIAS (Inyección simple)
  late CalculateJumpHeightUseCase _calculateJumpHeightUseCase;
  //late SaveVerticalJumpSessionUseCase _saveJumpSessionUseCase;
  late MLKitPoseDetectionRepositoryImpl _poseDetectionRepository;

  @override
  void initState() {
    super.initState();
    poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
    _poseDetectionRepository = MLKitPoseDetectionRepositoryImpl(poseDetector);
    _calculateJumpHeightUseCase = CalculateJumpHeightUseCase();
    // Asumiendo que existe un caso de uso similar para guardar los datos del salto
    //_saveJumpSessionUseCase = SaveVerticalJumpSessionUseCase(
    //  FirestorePatientDataRepositoryImpl(FirebaseFirestore.instance),
    //);
    _initializeCamera();
  }

  // --- MÉTODOS DE CÁMARA E INICIALIZACIÓN (IDÉNTICOS AL ORIGINAL) ---

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      setState(() {
        _errorMessage = 'No se encontraron cámaras disponibles.';
      });
      return;
    }

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      imageFormatGroup:
          Platform.isAndroid
              ? ImageFormatGroup.nv21
              : ImageFormatGroup.bgra8888,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });

      _controller!.startImageStream((image) {
        if (_shouldSkipFrame()) return;

        if (!isBusy) {
          isBusy = true;
          img = image;
          _processFrameAsync();
        }
      });
    } on CameraException catch (e) {
      String errorText = 'Error al inicializar la cámara: ${e.description}';
      if (e.code == 'CameraAccessDenied') {
        errorText =
            'Acceso a la cámara denegado. Por favor, otorga los permisos en la configuración.';
      }
      setState(() {
        _errorMessage = errorText;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado: $e';
      });
    }
  }

  bool _shouldSkipFrame() {
    _frameSkipCounter++;
    if (_frameSkipCounter < FRAME_SKIP_COUNT) {
      return true;
    }
    _frameSkipCounter = 0;

    final now = DateTime.now();
    if (_lastProcessTime != null) {
      final timeDiff = now.difference(_lastProcessTime!).inMilliseconds;
      if (timeDiff < MIN_PROCESS_INTERVAL_MS) {
        return true;
      }
    }
    _lastProcessTime = now;
    return false;
  }

  // --- FIN MÉTODOS DE CÁMARA E INICIALIZACIÓN ---

  // --- LÓGICA DE PROCESAMIENTO DE FRAME ---

  void _processFrameAsync() async {
    try {
      final inputImage = _inputImageFromCameraImage();
      if (inputImage == null) {
        isBusy = false;
        return;
      }

      final poses = await _poseDetectionRepository.detectPose(inputImage);

      if (poses.isNotEmpty && mounted) {
        final pose = poses.first;

        // 🚀 Delegar la lógica de cálculo al Caso de Uso
        final jumpResults = _calculateJumpHeightUseCase.execute(
          pose: pose,
          currentYMax: _yMaxTracker,
          currentYMin: _yMinTracker,
        );

        if (mounted) {
          setState(() {
            _scanResults = [pose];

            // Actualizar el estado de la Presentación con los resultados
            _currentYPosition = jumpResults.currentY;
            _yMaxTracker = jumpResults.yMax;
            _yMinTracker = jumpResults.yMin;
            _jumpHeightInPixels = jumpResults.heightInPixels;

            // Aplicar el factor de calibración en la capa de Presentación
            _jumpHeightInCm = _jumpHeightInPixels / PIXELS_PER_CM_FACTOR;
          });

          // Lógica para guardar en Firestore
          _frameSaveCounter++;
          if (_frameSaveCounter >= FRAME_SAVE_COUNT) {
            // Asume que esta Entidad existe para guardar el resultado
            final jumpSessionData = VerticalJumpSession(
              //identification: widget.identification,
              //session: widget.session,
              frame: frameCount,
              maxY: _yMaxTracker,
              minY: _yMinTracker,
              heightCm: _jumpHeightInCm,
            );
            //print("FIREBASE: Guardando datos del salto: $jumpSessionData");
            // Se asume la existencia de la Entidad y el Repositorio
            // await _saveJumpSessionUseCase.execute(jumpSessionData);
            frameCount++;
            _frameSaveCounter = 0; // Reinicia el contador de guardado
          }
        }
      } else if (mounted) {
        setState(() {
          _scanResults = null;
        });
      }
    } catch (e) {
      print('ERROR: Error processing frame (full pipeline): $e');
    } finally {
      isBusy = false;
    }
  }

  // --- FIN LÓGICA DE PROCESAMIENTO DE FRAME ---

  // --- MÉTODOS UTILITARIOS Y DE CONSTRUCCIÓN (IDÉNTICOS AL ORIGINAL) ---

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage() {
    if (img == null ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return null;
    }

    final camera = cameras[0];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) {
        return null;
      }

      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) {
      return null;
    }

    InputImageFormat? inputFormat;
    Uint8List? bytes;

    if (Platform.isAndroid) {
      if (img!.format.raw == 35 && img!.planes.length == 3) {
        inputFormat = InputImageFormat.nv21;
        bytes = _concatenatePlanes(img!.planes);
      } else if (img!.format.raw == InputImageFormat.nv21.rawValue &&
          img!.planes.length == 1) {
        inputFormat = InputImageFormat.nv21;
        bytes = img!.planes.first.bytes;
      } else {
        return null;
      }
    } else if (Platform.isIOS) {
      if (img!.format.raw == 875708020 && img!.planes.length == 1) {
        inputFormat = InputImageFormat.bgra8888;
        bytes = img!.planes.first.bytes;
      } else {
        return null;
      }
    } else {
      return null;
    }

    if (bytes == null) {
      return null;
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(img!.width.toDouble(), img!.height.toDouble()),
        rotation: rotation,
        format: inputFormat,
        bytesPerRow: img!.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final int width = img!.width;
    final int height = img!.height;
    final int totalBytes = width * height + (width * height ~/ 2);
    final Uint8List nv21Image = Uint8List(totalBytes);
    final Uint8List yPlane = planes[0].bytes;
    final int yRowStride = planes[0].bytesPerRow;
    final int uvRowStride = planes[1].bytesPerRow;
    final Uint8List uPlane = planes[1].bytes;
    final Uint8List vPlane = planes[2].bytes;
    int uvIndex = width * height;

    for (int y = 0; y < height; y++) {
      int yStart = y * yRowStride;
      nv21Image.setRange(
        y * width,
        (y + 1) * width,
        yPlane.sublist(yStart, yStart + width),
      );
      if (y % 2 == 0) {
        int uvStart = (y ~/ 2) * uvRowStride;
        for (int x = 0; x < width; x += 2) {
          nv21Image[uvIndex++] = vPlane[uvStart + x];
          nv21Image[uvIndex++] = uPlane[uvStart + x];
        }
      }
    }
    return nv21Image;
  }

  Widget buildResult() {
    if (_scanResults == null ||
        _scanResults!.isEmpty ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final Size imageSize = Size(
      _controller!.value.previewSize!.height,
      _controller!.value.previewSize!.width,
    );

    return CustomPaint(painter: OptimizedPosePainter(imageSize, _scanResults!));
  }

  @override
  void dispose() {
    _controller?.dispose();
    poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    size = MediaQuery.of(context).size;

    if (!_isCameraInitialized ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      // (Manejo de errores)
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: Center(
          child:
              _errorMessage.isNotEmpty
                  ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  )
                  : const CircularProgressIndicator(),
        ),
      );
    }

    // (CameraPreview y CustomPaint para dibujo de pose)
    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height,
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: CameraPreview(_controller!),
        ),
      ),
    );

    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height,
        child: buildResult(),
      ),
    );

    // Overlay de resultados (Actualizado para Salto)
    stackChildren.add(
      Positioned(
        bottom: 40,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "VERTICAL JUMP ANALYSIS 🚀",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Jump Height: ${_jumpHeightInCm.toStringAsFixed(2)} cm",
                style: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              /*const SizedBox(height: 8),
              Text(
                "Y Mínima (Pico): ${_yMinTracker == double.infinity ? '0.0' : _yMinTracker.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
              ),
              Text(
                "Y Máxima (Agachado/Tierra): ${_yMaxTracker.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
              const SizedBox(height: 8),*/
              Text(
                "Actual Position (Y): ${_currentYPosition.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 14,
                ),
              ),
              Text(
                "Calibration Factor: 1 cm = ${PIXELS_PER_CM_FACTOR.toStringAsFixed(2)} px",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 0),
        color: Colors.black,
        child: Stack(children: stackChildren),
      ),
    );
  }
}
