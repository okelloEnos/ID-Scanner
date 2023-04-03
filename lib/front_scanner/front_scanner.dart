import 'dart:io';

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
  }) : super(key: controller);
  final Function(File) onSuccess;
  final CameraLensDirection initialDirection;
  final bool showOverlay;
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
      // onImage: (imahe){
      //
      // },
      onImage: _processImage,
    );
  }

  // void _parseScannedText(List<String> lines) {
  //   try {
  //     final data = MRZParser.parse(lines);
  //     _isBusy = true;
  //     widget.onSuccess(data);
  //   } catch (e) {
  //     _isBusy = false;
  //   }
  // }

  Future<void> _processImage(InputImage inputImage, File image) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    img.Image? croppedFaceImage = await processImage(inputImage, image);

    if (croppedFaceImage != null) {
      // _idDetails.setIdImageFace = await convertImageToFile(croppedFaceImage);
      widget.onSuccess(image);
    }else {
      _isBusy = false;
    }
  }

  Future<img.Image?> processImage(InputImage inputImage, File imageFile) async {
    final FaceDetector faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
      ),
    );
    bool _canProcess = true;
    bool _isBusy = false;
    CustomPaint? _customPaint;

    int? noOfFaces;
    img.Image? faceImage;

    if (!_canProcess) return faceImage;
    if (_isBusy) return faceImage;
    _isBusy = true;

    final faces = await faceDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      if (faces.isNotEmpty) {
        List<Map<String, int>> faceMaps = [];
        for (Face face in faces) {
          int x = face.boundingBox.left.toInt();
          int y = face.boundingBox.top.toInt();
          int w = face.boundingBox.width.toInt();
          int h = face.boundingBox.height.toInt();
          Map<String, int> thisMap = {'x': x, 'y': y, 'w': w, 'h': h};
          faceMaps.add(thisMap);
        }

        img.Image? originalImage =
        img.decodeImage(File(imageFile.path).readAsBytesSync());

        if (originalImage != null) {
          if (faceMaps.isNotEmpty) {
            img.Image faceCrop = img.copyCrop(
                originalImage,
                x: faceMaps.first['x']!, y: faceMaps.first['y']!, width: faceMaps.first['w']!, height: faceMaps.first['h']!);
            faceImage = faceCrop;
          }
        }
      }

      noOfFaces = faces.length;
print('Number of Faces : $noOfFaces');
      _customPaint = null;
    }
    _isBusy = false;

    return faceImage;
  }

  // Future<File> convertImageToFile(Image image) async {
  //   Directory tempDir = await getTemporaryDirectory();
  //   String tempPath = tempDir.path;
  //
  //   var storagePath = "$tempPath/x.jpg";
  //   return await File(storagePath).writeAsBytes(img.encodePng(image));
  // }
}