import 'package:flutter/material.dart';
import 'package:id_scanner/front_scanner/front_scanner.dart';

class FrontScanningScreen extends StatefulWidget {
  const FrontScanningScreen({Key? key}) : super(key: key);

  @override
  State<FrontScanningScreen> createState() => _FrontScanningScreenState();
}

class _FrontScanningScreenState extends State<FrontScanningScreen> {
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
                      Navigator.pop(context);
                      // controller.currentState?.resetScanning();
                    },
                    child: const Text('Reset Scanning'),
                  ),
                  Card(
                    child: Center(
                      child: SizedBox(
                          height: 150,
                          width: 200,
                          child: Image.file(
                            mrzResult,
                            fit: BoxFit.contain,
                          )),
                    ),
                  )
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
