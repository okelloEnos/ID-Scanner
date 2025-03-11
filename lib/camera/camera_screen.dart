import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:id_scanner/main.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late List<CameraDescription> cameras;
  late CameraImage _cameraImage;
  bool isInitialized = false;
  Uint8List? imageCaptured ;
  // List<Uint8List> imageList => [];

  @override
  void initState() {
    super.initState();
initialization();
  }

//   Future<List<int>> convertImageToPng(CameraImage image) async {
//     imglib.Image? img;
//     if (image.format.group == ImageFormatGroup.yuv420) {
//       img = _convertYUV420(image);
//     } else if (image.format.group == ImageFormatGroup.bgra8888) {
//       img = _convertBGRA8888(image);
//     }
//
//     imglib.PngEncoder pngEncoder = imglib.PngEncoder();
//
//     // Convert to png
//     List<int> png = pngEncoder.encodeImage(img!);
//     return png;
//   }
//
// // CameraImage BGRA8888 -> PNG
// // Color
//   imglib.Image _convertBGRA8888(CameraImage image) {
//     return imglib.Image.fromBytes(
//       image.width,
//       image.height,
//       image.planes[0].bytes,
//       format: imglib.Format.bgra,
//     );
//   }
//
// // CameraImage YUV420_888 -> PNG -> Image (compression:0, filter: none)
// // Black
//   imglib.Image _convertYUV420(CameraImage image) {
//     var img = imglib.Image(image.width, image.height); // Create Image buffer
//
//     Plane plane = image.planes[0];
//     const int shift = (0xFF << 24);
//
//     // Fill image buffer with plane[0] from YUV420_888
//     for (int x = 0; x < image.width; x++) {
//       for (int planeOffset = 0;
//       planeOffset < image.height * image.width;
//       planeOffset += image.width) {
//         final pixelColor = plane.bytes[planeOffset + x];
//         // color: 0x FF  FF  FF  FF
//         //           A   B   G   R
//         // Calculate pixel color
//         var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
//
//         img.data[planeOffset + x] = newVal;
//       }
//     }
//
//     return img;
//   }


//   void capture(){
// img.Image image = img.Image.fromBytes(
//     width: _cameraImage.width,
//     height: _cameraImage.height,
//     bytes: _cameraImage.planes[0].bytes, format: img.Format.bgra);
//   }

  Uint8List? capture() {
    if (_cameraImage != null) {
      img.Image image = img.Image.fromBytes(
          _cameraImage.width, _cameraImage.height,
          _cameraImage.planes[0].bytes, format: img.Format.bgra);
      Uint8List list = Uint8List.fromList(img.encodeJpg(image));
      imageCaptured = list;
      // _imageList.add(list);
      // _imageList.refresh();
      return list;
    }
    return null;
  }

  void initialization() async{
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high, imageFormatGroup: ImageFormatGroup.bgra8888);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        isInitialized = true;
      });

      controller.startImageStream((image) {
        _cameraImage = image;
        // print(DateTime.now().millisecondsSinceEpoch.toString());
      });
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

typedef ScanningController = GlobalKey<_CameraScreenState>;