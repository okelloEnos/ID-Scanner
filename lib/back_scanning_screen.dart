import 'package:flutter/material.dart';
import 'package:id_scanner/back_scanner/back_scan_controller.dart';
import 'package:id_scanner/back_scanner/back_scanner.dart';
import 'package:id_scanner/front_scanner/front_scanner.dart';
import 'package:id_scanner/mrz_parser/mrz_result.dart';

class BackScanningScreen extends StatefulWidget {
  const BackScanningScreen({Key? key}) : super(key: key);

  @override
  State<BackScanningScreen> createState() => _BackScanningScreenState();
}

class _BackScanningScreenState extends State<BackScanningScreen> {
  final BackScanningController controller = BackScanningController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Back Side Scanning"),
      ),
      body: Builder(builder: (context){
        return BackIdScanner(
          controller: controller,
          onSuccess: (mrzResultInfo, fileImage) async{
            String documentType = "";
            String countryCode = "";
            String fullNames = "";
            String documentNumber = "";
            String nationalityCountryCode = "";
            String birthDate = "";
            String sex = "";
            String issueOrExpiryDate = "";
            String personalNumber = "";
            String personalNumber2 = "";
            String typeOfDate = "Expiry Date";

            if(mrzResultInfo.countryCode == "KYA"){
              typeOfDate = "Issue Date";
              documentType = mrzResultInfo.documentType;
              countryCode = mrzResultInfo.countryCode;
              fullNames = "${mrzResultInfo.surnames} ${mrzResultInfo.givenNames}";
              documentNumber = mrzResultInfo.documentNumber;
              nationalityCountryCode = mrzResultInfo.nationalityCountryCode;
              birthDate = mrzResultInfo.birthDate.toString();
              sex = mrzResultInfo.sex.name;
              issueOrExpiryDate = mrzResultInfo.expiryDate.toString();
              personalNumber = mrzResultInfo.personalNumber;
              personalNumber2 = mrzResultInfo.personalNumber2 ?? "";
              personalNumber2 = personalNumber2.replaceAll(RegExp('[^0-9]'), '');
            }
            else{
              documentType = mrzResultInfo.documentType;
              countryCode = mrzResultInfo.countryCode;
              fullNames = "${mrzResultInfo.surnames} ${mrzResultInfo.givenNames}";
              documentNumber = mrzResultInfo.documentNumber;
              nationalityCountryCode = mrzResultInfo.nationalityCountryCode;
              birthDate = mrzResultInfo.birthDate.toString();
              sex = mrzResultInfo.sex.name;
              issueOrExpiryDate = mrzResultInfo.expiryDate.toString();
              personalNumber = mrzResultInfo.personalNumber;
              personalNumber2 = mrzResultInfo.personalNumber2 ?? "";

            }
            MRZContent mrzContent = MRZContent(documentType: documentType, countryCode: countryCode,
                fullNames: fullNames, documentNumber: documentNumber,
                nationalityCountryCode: nationalityCountryCode, birthDate: birthDate,
                sex: sex, issueOrExpiryDate: issueOrExpiryDate, personalNumber: personalNumber, personalNumber2: personalNumber2);
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
                          // Navigator.pop(context);
                          // controller.currentState?.resetScanning();
                        },
                        child: const Text('Reset Scanning'),
                      ),
                      Text('Nationality : ${mrzContent.nationalityCountryCode}'),
                      Text('Personal Number : ${mrzContent.personalNumber}'),
                      Text('Personal Number 2 : ${mrzContent.personalNumber2}'),
                      Text('Document Type : ${mrzContent.documentType}'),
                      Text('Full Names : ${mrzContent.fullNames}'),
                      Text('Gender : ${mrzContent.sex}'),
                      Text('CountryCode : ${mrzContent.countryCode}'),
                      Text('Date of Birth : ${mrzContent.birthDate}'),
                      Text('$typeOfDate : ${mrzContent.issueOrExpiryDate}'),
                      Text('DocNum : ${mrzContent.documentNumber}'),
                      Image.file(fileImage, height: 300, width: 200,),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
