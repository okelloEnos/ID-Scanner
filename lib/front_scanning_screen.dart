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
      body: FrontIdScanner(onSuccess: (mrzResult) async{
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
                      controller.currentState?.resetScanning();
                    },
                    child: const Text('Reset Scanning'),
                  ),
                  Card(
                    child: Center(
                      child: SizedBox(
                          height: 150,
                          width: 200,
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
                                                    mrzResult),
                                              ),
                                            )),
                                      ))))),
                    ),
                  )
                  // Card(
                  //   child: Center(
                  //     child: SizedBox(
                  //         height: 150,
                  //         width: 200,
                  //         child: Image.file(
                  //           mrzResult,
                  //           fit: BoxFit.contain,
                  //         )),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        );
      }
        ,),
    );
  }
}
