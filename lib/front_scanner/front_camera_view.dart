import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:id_scanner/front_scanner/front_camera_overlay.dart';
import 'package:id_scanner/widget/scanner_widget.dart';
import 'package:path_provider/path_provider.dart';

class FrontSideCameraView extends StatefulWidget {
  const FrontSideCameraView({
    Key? key,
    required this.onImage,
    this.initialDirection = CameraLensDirection.back,
    required this.showOverlay,
  }) : super(key: key);

  // final Function(InputImage inputImage, File fileImage) onImage;
  final Function(Uint8List image) onImage;
  final CameraLensDirection initialDirection;
  final bool showOverlay;

  @override
  _FrontSideCameraViewState createState() => _FrontSideCameraViewState();
}

class _FrontSideCameraViewState extends State<FrontSideCameraView> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  int _cameraIndex = 0;
  List<CameraDescription> cameras = [];

  late AnimationController _animationController;
  bool _animationStopped = false;
  String scanText = "Scan";
  bool scanning = false;
  bool scanning1 = false;

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
      //     ? FrontSideCameraOverlay(child: _liveFeedBody())
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
      // _controller?.startImageStream(_processCameraImage);
      _controller?.startImageStream(capture);
      // cameraController.startImageStream((image) {
      //   // Convert the image to a Uint8List
      //   final bytes = image.planes.first.bytes;
      //
      //   // Create an Image widget from the Uint8List
      //   final imageWidget = Image.memory(bytes);
      //
      //   // Display the image widget in your UI
      // });

      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

 void  capture(CameraImage cameraImage) {
    try{
     if(scanning1){
       return;
     }
     else{
       img.Image image = img.Image.fromBytes(
           cameraImage.width, cameraImage.height,
           cameraImage.planes[0].bytes, format: img.Format.bgra);
       Uint8List list = Uint8List.fromList(img.encodeJpg(image));
       widget.onImage(list);
       scanning1 = true;
     }
    }
    catch(e){
      throw "Error";
    }

  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
    InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat =
    InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
    InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

File sFile = await transformImageToFile(bytes);
// print('fffffffffffffffffffffffffffsssssssssssssssssssssssssssss :: ${sFile}');
//     File sFile = await File("POPPPPP.jpg");
//     widget.onImage(inputImage, sFile);
  }

}

Future<File> transformImageToFile(Uint8List imageList) async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  String uniquePath = timestamp.toString();
  var storagePath = "$tempPath/$uniquePath.jpg";
  File imageFile = File(storagePath);
  if (!await imageFile.exists()) {
    imageFile.create(recursive: true);
  }
  imageFile.writeAsBytes(imageList);

  return imageFile;
}