import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import '../services/vision_service.dart';
import 'camera_result_page.dart';

class CameraPage extends StatefulWidget {
  final String id; // Changed type to String

  const CameraPage({Key? key, required this.id}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  late Future<void> _initializeControllerFuture;
  ServiceAccountCredentials? credentials;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadCredentials();
  }

Future<void> _initializeCamera() async {
  final cameras = await availableCameras();
  if (cameras.isNotEmpty) {
    controller = CameraController(cameras.first, ResolutionPreset.high);
    _initializeControllerFuture = controller!.initialize();
    setState(() {});
  } else {
    debugPrint('No cameras available');
  }
}

  Future<void> _loadCredentials() async {
    credentials = await VisionService.loadCredentials('assets/credentials/vision_api_key.json');
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await controller!.takePicture();
      final imageFile = File(image.path);

      if (credentials != null) {
        final visionService = VisionService(credentials!);
        final labels = await visionService.detectLabels(imageFile);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraResultPage(image: imageFile, labels: labels, id: widget.id), // Pass id as String
            ),
          );
        }
      } else {
        debugPrint('Credentials are not loaded.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Camera', style: Theme.of(context).appBarTheme.titleTextStyle),
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    backgroundColor: Colors.white,
    body: FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(controller!);
        } else if (snapshot.hasError) {
          return Center(child: Text('Error initializing camera: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _takePicture,
      backgroundColor: Colors.white,
      child: const Icon(Icons.camera, color: Colors.black),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );
}
}
