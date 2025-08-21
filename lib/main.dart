import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // No necesario para esta prueba, pero se mantiene si se usa en otro lugar
import 'package:firebase_core/firebase_core.dart'; // No necesario para esta prueba
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
// import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'; // No necesario para esta prueba
import 'firebase_options.dart'; // No necesario para esta prueba
// ... (imports)
import 'presentation/pages/home_page.dart'; // Import the original home page

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GAIT ANALYSIS PROTOTYPE',
      home: MyHomePage(title: 'screen'),
    );
  }
}
