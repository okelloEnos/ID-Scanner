import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:id_scanner/back_scanner/back_camera_overlay.dart';
import 'package:id_scanner/front_scanner/front_camera_overlay.dart';
import 'package:id_scanner/mrz_helper.dart';
import 'package:id_scanner/mrz_parser/mrz_parser.dart';
import 'package:id_scanner/mrz_parser/mrz_result.dart';
import 'package:id_scanner/widget/scanner_widget.dart';
import 'package:path_provider/path_provider.dart';

class BackSideCameraView extends StatefulWidget {
  const BackSideCameraView({
    Key? key,
    required this.onImage,
    this.initialDirection = CameraLensDirection.back,
    required this.showOverlay,
  }) : super(key: key);

  // final Function(InputImage inputImage) onImage;
  final Function(MRZResult, File) onImage;
  final CameraLensDirection initialDirection;
  final bool showOverlay;

  @override
  _BackSideCameraViewState createState() => _BackSideCameraViewState();
}

class _BackSideCameraViewState extends State<BackSideCameraView> with SingleTickerProviderStateMixin {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;
  CameraController? _controller;
  int _cameraIndex = 0;
  List<CameraDescription> cameras = [];

  late AnimationController _animationController;
  bool _animationStopped = false;
  String scanText = "Scan";
  bool scanning = false;

  @override
  void initState() {
    super.initState();
    initCamera();

    _animationController = AnimationController(
        duration: const Duration(seconds: 1), vsync: this);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animateScanAnimation(true);
      } else if (status == AnimationStatus.dismissed) {
        animateScanAnimation(false);
      }
    });

    // onPressed: () {
      if (!scanning) {
        animateScanAnimation(false);
        setState(() {
          _animationStopped = false;
          scanning = true;
          scanText = "Stop";
        });
      } else {
        setState(() {
          _animationStopped = true;
          scanning = false;
          scanText = "Scan";
        });
      }
    // },
  }

  initCamera() async {
    cameras = await availableCameras();

    try {
      if (cameras.any((element) =>
      element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90)) {
        _cameraIndex = cameras.indexOf(
          cameras.firstWhere(
                (element) =>
            element.lensDirection == widget.initialDirection &&
                element.sensorOrientation == 90,
          ),
        );
      } else {
        _cameraIndex = cameras.indexOf(
          cameras.firstWhere(
                (element) => element.lensDirection == widget.initialDirection,
          ),
        );
      }
    } catch (e) {
      print(e);
    }

    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      // widget.showOverlay
      //     ? BackSideCameraOverlay(child: _liveFeedBody())
      //     :
          _liveFeedBody(),
    );
  }

  void animateScanAnimation(bool reverse) {
    if (reverse) {
      _animationController.reverse(from: 1.0);
    } else {
      _animationController.forward(from: 0.0);
    }
  }

  void captureTheImage() async {
    await _stopStreaming();
    XFile? file = await takePicture();
    if(file != null) {
      File imageFile = File(file!.path);

      /// process the image for face detection
      InputImage inputImage = InputImage.fromFilePath(file!.path);
      MRZResult? mrzResult = await _processImage(inputImage);
      print("Mrz Info captured: $mrzResult");

      if(mrzResult != null) {
        widget.onImage(mrzResult, imageFile);
      } else {
        startStreaming();
      }
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    // _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }


  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false ||
        _controller?.value.isInitialized == null) {
      return Container();
    }
    if (_controller?.value.isInitialized == false) {
      return Container();
    }

    final size = MediaQuery.of(context).size;
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;
    return LayoutBuilder(
      builder: (_, c) {
        final overlayRect =
        _calculateOverlaySize(Size(c.maxWidth, c.maxHeight));
        return Container(
          color: Colors.black,
          child: Stack(
            // fit: StackFit.expand,
            fit: StackFit.expand,
            children: <Widget>[
              Transform.scale(
                scale: scale,
                child: CameraPreview(_controller!),
              ),
              ImageScannerAnimation(
                _animationStopped,
                overlayRect.width,
                animation: _animationController,
              )
            ],
          ),
        );
      },
    );
  }
  static const _documentFrameRatio =
  1.42;
  RRect _calculateOverlaySize(Size size) {
    double width, height;
    if (size.height > size.width) {
      width = size.width * 0.9;
      height = width / _documentFrameRatio;
    } else {
      height = size.height * 0.75;
      width = height * _documentFrameRatio;
    }
    final topOffset = (size.height - height) / 2;
    final leftOffset = (size.width - width) / 2;

    final rect = RRect.fromLTRBR(leftOffset, topOffset, leftOffset + width,
        topOffset + height, const Radius.circular(8));
    return rect;
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.setFlashMode(FlashMode.off);
      // _controller?.startImageStream(_processCameraImage);
      startStreaming();
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    // await _controller?.stopImageStream();
    await _stopStreaming();
    await _controller?.dispose();
    _controller = null;
  }

  // Future _processCameraImage(CameraImage image) async {
  //   final WriteBuffer allBytes = WriteBuffer();
  //   for (final Plane plane in image.planes) {
  //     allBytes.putUint8List(plane.bytes);
  //   }
  //   final bytes = allBytes.done().buffer.asUint8List();
  //
  //   final Size imageSize =
  //   Size(image.width.toDouble(), image.height.toDouble());
  //
  //   final camera = cameras[_cameraIndex];
  //   final imageRotation =
  //   InputImageRotationValue.fromRawValue(camera.sensorOrientation);
  //   if (imageRotation == null) return;
  //
  //   final inputImageFormat =
  //   InputImageFormatValue.fromRawValue(image.format.raw);
  //   if (inputImageFormat == null) return;
  //
  //   final planeData = image.planes.map(
  //         (Plane plane) {
  //       return InputImagePlaneMetadata(
  //         bytesPerRow: plane.bytesPerRow,
  //         height: plane.height,
  //         width: plane.width,
  //       );
  //     },
  //   ).toList();
  //
  //   final inputImageData = InputImageData(
  //     size: imageSize,
  //     imageRotation: imageRotation,
  //     inputImageFormat: inputImageFormat,
  //     planeData: planeData,
  //   );
  //
  //   final inputImage =
  //   InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  //
  //   // widget.onImage(inputImage);
  // }

  MRZResult? _parseScannedText(List<String> lines) {
    try {
      final data = MRZParser.parse(lines);
      _isBusy = true;
      return data;
      // widget.onSuccess(data);
    } catch (e) {
      _isBusy = false;
      return null;
    }
  }

  Future<MRZResult?> _processImage(InputImage inputImage) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
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
      return _parseScannedText([...result]);
    } else {
      _isBusy = false;
      return null;
    }
  }

  Future _stopStreaming() async {
    await _controller?.stopImageStream();
  }

  void startStreaming() {
    _controller?.startImageStream(processingLiveImages);
  }

  void processingLiveImages(CameraImage cameraImage) {
    ///step 1 take a picture
    ///step 2 process the picture for any faces
    ///step 3 if face is found then stop the stream and return the image
    ///step 4 if face is not found then start the stream again

    try{
      captureTheImage();
    }
    catch(e){
      throw "Error";
    }

  }

  // Future<int> processImage(InputImage inputImage) async {
  //   final FaceDetector faceDetector = FaceDetector(
  //     options: FaceDetectorOptions(
  //       enableContours: true,
  //       enableClassification: true,
  //     ),
  //   );
  //   bool canProcess = true;
  //   bool isBusy = false;
  //   int numberOfFaces = 0;
  //
  //   int? noOfFaces;
  //   img.Image? faceImage;
  //
  //   if (!canProcess) return 0;
  //   if (isBusy) return 0;
  //   isBusy = true;
  //
  //   final faces = await faceDetector.processImage(inputImage);
  //   if (inputImage.inputImageData?.size != null &&
  //       inputImage.inputImageData?.imageRotation != null) {
  //     final painter = FaceDetectorPainter(
  //         faces,
  //         inputImage.inputImageData!.size,
  //         inputImage.inputImageData!.imageRotation);
  //   } else {
  //     if (faces.isNotEmpty) {
  //       List<Map<String, int>> faceMaps = [];
  //       for (Face face in faces) {
  //         int x = face.boundingBox.left.toInt();
  //         int y = face.boundingBox.top.toInt();
  //         int w = face.boundingBox.width.toInt();
  //         int h = face.boundingBox.height.toInt();
  //         Map<String, int> thisMap = {'x': x, 'y': y, 'w': w, 'h': h};
  //         faceMaps.add(thisMap);
  //       }
  //
  //       // img.Image? originalImage =
  //       // img.decodeImage(File(imageFile.path).readAsBytesSync());
  //
  //       // if (originalImage != null) {
  //       //   if (faceMaps.isNotEmpty) {
  //       //     // img.Image faceCrop = img.copyCrop(
  //       //     //     originalImage,
  //       //     //     x: faceMaps.first['x']!, y: faceMaps.first['y']!, width: faceMaps.first['w']!, height: faceMaps.first['h']!);
  //       //     // faceImage = faceCrop;
  //       //   }
  //       // }
  //     }
  //
  //     noOfFaces = faces.length;
  //     numberOfFaces = noOfFaces;
  //     print('Number of Faces : $noOfFaces');
  //   }
  //   isBusy = false;
  //
  //   return numberOfFaces;
  // }

  void reset(){
    startStreaming();
  }
}
