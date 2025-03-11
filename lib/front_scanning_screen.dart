import 'package:flutter/material.dart';
import 'package:id_scanner/front_scanner/front_scan_controller.dart';
import 'package:id_scanner/front_scanner/front_scanner.dart';

class FrontScanningScreen extends StatefulWidget {
  const FrontScanningScreen({Key? key}) : super(key: key);

  @override
  State<FrontScanningScreen> createState() => _FrontScanningScreenState();
}

class _FrontScanningScreenState extends State<FrontScanningScreen> {
  final FrontScanningController controller = FrontScanningController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Front Side Scanning"),
      ),
      body: FrontIdScanner(
        onSuccess: (mrzResult) async{
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      // controller.currentState?.resetScanning();
                      resetScanning();
                    },
                    child: const Text('Reset Scanning'),
                  ),
                  Image.file(mrzResult, height: 300, width: 200,),
                ],
              ),
            ),
          ),
        );
      }, resetScanning: (){},),
    );
  }

  void resetScanning() {
    Navigator.pop(context);
  }
}
