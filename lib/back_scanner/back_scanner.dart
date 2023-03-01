import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:id_scanner/back_scanner/back_camera_view.dart';
import 'package:id_scanner/mrz_helper.dart';
import 'package:mrz_parser/mrz_parser.dart';

/// this class is where the processing of images stream is done
class BackSideScanner extends StatefulWidget {
  final Function(MRZResult mrzResult) onSuccess;
  const BackSideScanner({Key? key, required this.onSuccess}) : super(key: key);

  @override
  State<BackSideScanner> createState() => BackSideScannerState();
}

class BackSideScannerState extends State<BackSideScanner> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;

  void resetScanning() => _isBusy = false;

  @override
  void dispose() {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackSideCameraView(
      onImage: _processImage,
    );
  }

  // for image recognition and processing
  _processImage(InputImage inputImage) async{
// check if you can process it
  if(!_canProcess) return;

  // check if the process is busy already
    if(_isBusy) return;

    // now am busy
    _isBusy = true;

    // text recognition
  final recognizedText = await _textRecognizer.processImage(inputImage);

  // retrieving text
  String fullText = recognizedText.text;

  // white spaces removal
  String trimmedText = fullText.replaceAll(' ', '');

// splitting per line
    List allText = trimmedText.split('\n');

    // text that is appropriate for scanning
    List<String> ableToScanText = [];

    // loop through the splitted all text to determine which lines are meant for MRZ and are scanable
    for (var e in allText) {
      if (MRZHelper.testTextLine(e).isNotEmpty) {
        ableToScanText.add(MRZHelper.testTextLine(e));
      }
    }

    // further confirmation of MRZ format
    List<String>? result = MRZHelper.getFinalListToParse([...ableToScanText]);

    if (result != null) {
      // processing of MRZ lines
      _parseScannedText([...result]);
    } else {
      _isBusy = false;
    }
  }

  // function to parse the MRZ lines
  _parseScannedText(List<String> lines) {
    try {
      final data = MRZParser.parse(lines);
      _isBusy = true;
      widget.onSuccess(data);
    } catch (e) {
      _isBusy = false;
    }
  }
}
