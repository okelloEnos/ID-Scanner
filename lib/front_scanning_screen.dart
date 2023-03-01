import 'package:flutter/material.dart';
import 'package:id_scanner/front_scanner/front_scanner.dart';

class FrontScanningScreen extends StatelessWidget {
  const FrontScanningScreen({Key? key}) : super(key: key);

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
                  // Text('Nationality : ${mrzResult.nationalityCountryCode}'),
                  // Text('Personal Number : ${mrzResult.personalNumber}'),
                  // Text('Personal Number 2 : ${mrzResult.personalNumber2}'),
                  // Text('Document Type : ${mrzResult.documentType}'),
                  // Text('Surname : ${mrzResult.surnames}'),
                  // Text('Name : ${mrzResult.givenNames}'),
                  // Text('Gender : ${mrzResult.sex.name}'),
                  // Text('CountryCode : ${mrzResult.countryCode}'),
                  // Text('Date of Birth : ${mrzResult.birthDate}'),
                  // Text('Expiry Date : ${mrzResult.expiryDate}'),
                  // Text('DocNum : ${mrzResult.documentNumber}'),
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
