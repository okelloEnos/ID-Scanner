import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// for camera initialization and live streaming functionalities
class BackSideCameraView extends StatefulWidget {
  final Function(InputImage) onImage;
  const BackSideCameraView({Key? key, required this.onImage}) : super(key: key);

  @override
  State<BackSideCameraView> createState() => _BackSideCameraViewState();
}

class _BackSideCameraViewState extends State<BackSideCameraView> {
  CameraController? _cameraController;
  int _cameraIndex = 0;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  initCamera() async{
    // retrieving all available cameras
    cameras = await availableCameras();

    // trying to update the camera index with most suitable camera among list of cameras available
    try{
      if(cameras.any((element) => element.lensDirection == CameraLensDirection.back && element.sensorOrientation == 90)){
        _cameraIndex = cameras.indexOf(cameras.firstWhere((element) => element.lensDirection == CameraLensDirection.back && element.sensorOrientation == 90));
      }
      else{
        _cameraIndex = cameras.indexOf(cameras.firstWhere((element) => element.lensDirection == CameraLensDirection.back));
      }
    }
    catch (e){
      if (kDebugMode) {
        print(e);
      }
    }

    // start the live feed now
    _startLiveFeed();
  }

  _startLiveFeed(){
    final camera = cameras[_cameraIndex];
    _cameraController = CameraController(camera, ResolutionPreset.high, enableAudio: false);
    _cameraController?.initialize().then((_){
      if(!mounted){
        return;
      }
      _cameraController?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  _stopLiveFeed() async{
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    _cameraController = null;
  }

  _processCameraImage(CameraImage image) async{
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

    widget.onImage(inputImage);
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _liveFeedBody();
  }

  Widget _liveFeedBody(){
    if(_cameraController?.value.isInitialized == null || _cameraController?.value.isInitialized == false){
      return Container();
    }

    final size = MediaQuery.of(context).size;
    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * _cameraController!.value.aspectRatio;
    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform.scale(
                scale: scale,
                child: CameraPreview(_cameraController!)),
          ],
        ));
  }
}
