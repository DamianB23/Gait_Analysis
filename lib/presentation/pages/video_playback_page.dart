// lib/presentation/pages/video_playback_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../domain/entities/pose_data.dart';
import '../widgets/optimized_pose_painter.dart';

class VideoPlaybackPage extends StatefulWidget {
  final String videoPath;
  final List<PoseData> recordedPoses;

  const VideoPlaybackPage({
    Key? key,
    required this.videoPath,
    required this.recordedPoses,
  }) : super(key: key);

  @override
  _VideoPlaybackPageState createState() => _VideoPlaybackPageState();
}

class _VideoPlaybackPageState extends State<VideoPlaybackPage> {
  late VideoPlayerController _controller;
  PoseData? _currentPoseData;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        _controller.setPlaybackSpeed(0.5);
        _controller.play();
        _controller.addListener(_videoListener);
        setState(() {});
      });
  }

  void _videoListener() {
    if (!mounted ||
        widget.recordedPoses.isEmpty ||
        !_controller.value.isInitialized) {
      return;
    }

    final currentVideoPosition = _controller.value.position;
    final closestPose = widget.recordedPoses.firstWhere(
      (pose) {
        final poseDurationFromStart = pose.timestamp.difference(
          widget.recordedPoses.first.timestamp,
        );
        return (poseDurationFromStart - currentVideoPosition).abs() <
            const Duration(milliseconds: 50);
      },
      orElse:
          () => PoseData(
            timestamp: DateTime.now(),
            landmarks: {},
            leftKneeAngle: 0,
            rightKneeAngle: 0,
            leftAnkleAngle: 0,
            rightAnkleAngle: 0,
          ),
    );

    if (closestPose.landmarks.isNotEmpty && closestPose != _currentPoseData) {
      setState(() {
        _currentPoseData = closestPose;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definir la pose para el pintor
    final List<Pose> posesToDraw =
        _currentPoseData?.landmarks.isNotEmpty == true
            ? [Pose(landmarks: _currentPoseData!.landmarks)]
            : [];

    return Scaffold(
      appBar: AppBar(title: const Text('Reproducción en cámara lenta')),
      body: Center(
        child:
            _controller.value.isInitialized
                ? Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    Positioned.fill(
                      child: Builder(
                        builder: (BuildContext context) {
                          if (_controller.value.size.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return CustomPaint(
                            painter: OptimizedPosePainter(
                              _controller
                                  .value
                                  .size, // Usamos el tamaño real del video
                              posesToDraw,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _currentPoseData == null ||
                                _currentPoseData!.landmarks.isEmpty
                            ? "Cargando..."
                            : "Rodilla Izquierda: ${_currentPoseData!.leftKneeAngle.toStringAsFixed(1)}° | Rodilla Derecha: ${_currentPoseData!.rightKneeAngle.toStringAsFixed(1)}°",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
