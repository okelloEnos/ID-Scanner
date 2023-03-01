import 'package:flutter/material.dart';
import 'package:id_scanner/front_scanner/front_scanner.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // home: ScannerScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
