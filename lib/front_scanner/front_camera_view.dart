import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FrontSideCameraView extends StatefulWidget {
  const FrontSideCameraView({
    Key? key,
    required this.onImage,
    this.initialDirection = CameraLensDirection.back,
    required this.showOverlay,
  }) : super(key: key);

  final Function(File image) onImage;
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
  void captureTheImage() async {
    await _stopStreaming();
    takePicture().then((XFile? file) {
      if (mounted) {
        setState(() {
          File imageFile = File(file!.path);
          widget.onImage(imageFile);
        });
        if (file != null) {
          showInSnackBar('Picture saved to ${file.path}');
        }
      }
    });
  }
  // void onTakePictureButtonPressed() {
  //   takePicture().then((XFile? file) {
  //     if (mounted) {
  //       setState(() {
  //         File imageFile = File(file!.path);
  //         // Take a picture and get the file path
  //         // final path = await takePicture();
  //
  //         // Navigate to the preview screen and pass the file path as an argument
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => PreviewScreen(path: file!.path)),
  //         );
  //         // widget.onImage(imageFile);
  //       });
  //       if (file != null) {
  //         showInSnackBar('Picture saved to ${file.path}');
  //       }
  //     }
  //   });
  // }

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
        return Stack(
          // fit: StackFit.expand,
          fit: StackFit.expand,
          children: <Widget>[
            CameraPreview(_controller!),
          ],
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

      _controller?.startImageStream(processingLiveImages);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _stopStreaming();
    await _controller?.dispose();
    _controller = null;
  }

  Future _stopStreaming() async {
    await _controller?.stopImageStream();
  }

  // void  captureFile(CameraImage cameraImage) async{
  //   try{
  //     if(scanning1){
  //       return;
  //     }
  //     else{
  //       await _stopStreaming();
  //       onTakePictureButtonPressed();
  //       scanning1 = true;
  //     }
  //   }
  //   catch(e){
  //     throw "Error";
  //   }
  //
  // }

  void  processingLiveImages(CameraImage cameraImage) {
    try{
      if(scanning1){
        return;
      }
      else{
        captureTheImage();
        scanning1 = true;
      }
    }
    catch(e){
      throw "Error";
    }

  }

}
