import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:id_scanner/camera/camera_screen.dart';
import 'package:id_scanner/main.dart';

class CaptureButton extends StatefulWidget {
  const CaptureButton({Key? key}) : super(key: key);

  @override
  State<CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton> {
  Uint8List? image;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      child: Column(
        children: [
         image == null ? Text('data is empty') : Card(
            child: SizedBox(
                height: 100,
                width: 75,
                child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(
                              3, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: RepaintBoundary(
                          child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(
                                      image!),
                                ),
                              )),
                        )))),
          ),
          GestureDetector(
            onTap: (){
              final ScanningController controller = ScanningController();
              image = controller.currentState?.capture();
              // image = controller.currentState?.imageCaptured;
              setState(() {

              });
            },
            child: Container(
              height: 80,
              width: 80,
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white60, width: 5)
              ),
              child: Container(
decoration: const BoxDecoration(
  shape: BoxShape.circle,
  color: Colors.white
),
                  child: const Center(child: Icon(Icons.camera, size: 60.0,))),
            ),
          ),
        ],
      ),
    );
  }
}
