import 'package:flutter/material.dart';
import 'package:id_scanner/back_scanning_screen.dart';
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
      home: const BackScanningScreen(),
      // home: ScannerScreen(),
    );
  }
}

