import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraViewer extends StatefulWidget {
  const CameraViewer({Key? key}) : super(key: key);

  @override
  State<CameraViewer> createState() => _CameraViewerState();
}

class _CameraViewerState extends State<CameraViewer> {
  late CameraController controller;
  late List<CameraDescription> cameras;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async{
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      // controller.startImageStream((image) {
      //   print(DateTime.now().millisecondsSinceEpoch.toString());
      // });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(isInitialized){
      if (!controller.value.isInitialized) {
        return Container();
      }
      return SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CameraPreview(controller));
    }
    else{
      return Container();
    }
  }
}

typedef ScanningViewController = GlobalKey<_CameraViewerState>;