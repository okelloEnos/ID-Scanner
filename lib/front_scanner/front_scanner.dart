import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:id_scanner/front_scanner/front_camera_view.dart';
import 'package:id_scanner/mrz_helper.dart';
import 'package:id_scanner/painters/face_detector_painter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class FrontIdScanner extends StatefulWidget {
  const FrontIdScanner({
    Key? controller,
    required this.onSuccess,
    this.initialDirection = CameraLensDirection.back,
    this.showOverlay = true,
    required this.resetScanning,
  }) : super(key: controller);
  final Function(File) onSuccess;
  final CameraLensDirection initialDirection;
  final bool showOverlay;
  final VoidCallback resetScanning;
  @override
  // ignore: library_private_types_in_public_api
  FrontIdScannerState createState() => FrontIdScannerState();
}

class FrontIdScannerState extends State<FrontIdScanner> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;

  void resetScanning() => _isBusy = false;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FrontSideCameraView(
      showOverlay: widget.showOverlay,
      initialDirection: widget.initialDirection,
      resetScanning: widget.resetScanning,
      onImage: capturedImage,
    );
  }

  void capturedImage(File image){
    widget.onSuccess(image);
  }

}