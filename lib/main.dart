import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:id_scanner/back_scanning_screen.dart';
import 'package:id_scanner/camera/camera_screen.dart';
import 'package:id_scanner/camera/camera_screen_two.dart';
import 'package:id_scanner/camera_example.dart';
import 'package:id_scanner/front_scanner/front_scanner.dart';
import 'package:id_scanner/front_scanning_screen.dart';
import 'package:id_scanner/scan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ID SCANNER!!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BackScanningScreen(),
      // home: const FrontScanningScreen(),
      // home: const CameraScreenTwo(),
    );
  }
}

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
//
// late List<CameraDescription> _cameras;
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   _cameras = await availableCameras();
//   runApp(const CameraApp());
// }
//
// typedef CameraScanningController = GlobalKey<_CameraAppState>;
//
// /// CameraApp is the Main Application.
// class CameraApp extends StatefulWidget {
//   /// Default Constructor
//   const CameraApp({Key? key}) : super(key: key);
//
//   @override
//   State<CameraApp> createState() => _CameraAppState();
// }
//
// class _CameraAppState extends State<CameraApp> {
//   late CameraController controller;
//
//   @override
//   void initState() {
//     super.initState();
//     controller = CameraController(_cameras[0], ResolutionPreset.max);
//     controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//
//       // controller.startImageStream((image) {
//       //   print(DateTime.now().millisecondsSinceEpoch.toString());
//       // });
//     }).catchError((Object e) {
//       if (e is CameraException) {
//         switch (e.code) {
//           case 'CameraAccessDenied':
//           // Handle access errors here.
//             break;
//           default:
//           // Handle other errors here.
//             break;
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!controller.value.isInitialized) {
//       return Container();
//     }
//     return MaterialApp(
//       home: CameraPreview(controller),
//       // home: CameraScreenTwo(),
//     );
//   }
//
//   void capture(){}
// }
