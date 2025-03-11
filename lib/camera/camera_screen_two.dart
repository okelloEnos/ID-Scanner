import 'package:flutter/material.dart';
import 'package:id_scanner/camera/camera_screen.dart';
import 'package:id_scanner/camera/camera_viewer.dart';
import 'package:id_scanner/camera/capture_button.dart';

class CameraScreenTwo extends StatelessWidget {
  const CameraScreenTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: const [
        // CameraViewer(),
        CameraScreen(),
        CaptureButton()
      ],
    );
  }
}
