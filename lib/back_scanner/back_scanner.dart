import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:id_scanner/back_scanner/back_camera_view.dart';
import 'package:id_scanner/front_scanner/front_camera_view.dart';
import 'package:id_scanner/mrz_helper.dart';
import 'package:id_scanner/painters/face_detector_painter.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class BackIdScanner extends StatefulWidget {
  const BackIdScanner({
    Key? controller,
    required this.onSuccess,
    this.initialDirection = CameraLensDirection.back,
    this.showOverlay = true,
  }) : super(key: controller);
  final Function(MRZResult) onSuccess;
  final CameraLensDirection initialDirection;
  final bool showOverlay;
  @override
  // ignore: library_private_types_in_public_api
  BackIdScannerState createState() => BackIdScannerState();
}

class BackIdScannerState extends State<BackIdScanner> {
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
    return BackSideCameraView(
      showOverlay: widget.showOverlay,
      initialDirection: widget.initialDirection,
      onImage: _processImage,
    );
  }

  void _parseScannedText(List<String> lines) {
    try {
      final data = MRZParser.parse(lines);
      _isBusy = true;
      widget.onSuccess(data);
    } catch (e) {
      _isBusy = false;
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final recognizedText = await _textRecognizer.processImage(inputImage);
    // text recognition
    String fullText = recognizedText.text;
    // white spaces removal
    String trimmedText = fullText.replaceAll(' ', '');
// splitting per line
    List allText = trimmedText.split('\n');

    List<String> ableToScanText = [];
    for (var e in allText) {
      if (MRZHelper.testTextLine(e).isNotEmpty) {
        ableToScanText.add(MRZHelper.testTextLine(e));
      }
    }
    List<String>? result = MRZHelper.getFinalListToParse([...ableToScanText]);

    if (result != null) {
      _parseScannedText([...result]);
    } else {
      _isBusy = false;
    }
  }
}