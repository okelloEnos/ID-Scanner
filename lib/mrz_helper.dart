class MRZHelper {
  static List<String>? getFinalListToParse(List<String> ableToScanTextList) {
    if (ableToScanTextList.length < 2) {
      // minimum length of any MRZ format is 2 lines
      return null;
    }
// passport have 2 lines for mrz of 44 characters each
// national ids have 3 lines for mrz of 30 characters each

    int lineLength = ableToScanTextList.first.length;
    for (var e in ableToScanTextList) {
      if (e.length != lineLength) {
        return null;
      }
      // to make sure that all lines are the same in length
    }

    List<String> firstLineChars = ableToScanTextList.first.split('');
    List<String> supportedDocTypes = ['A', 'C', 'P', 'V', 'I'];
    String fChar = firstLineChars[0];
    String sChar = firstLineChars[1];
    if ((sChar == '<' || sChar  == 'D') && supportedDocTypes.contains(fChar)) {
      return [...ableToScanTextList];
    }
    return null;
  }

  static String testTextLine(String text) {
    // remove white spaces on each line
    String res = text.replaceAll(' ', '');

    //
    List<String> list = res.split('');

    // to check if the text belongs to any MRZ format or not
    if (list.length != 44 && list.length != 30 && list.length != 36) {
      return '';
    }

    for (int i = 0; i < list.length; i++) {
      if (RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i])) {
        list[i] = list[i].toUpperCase();
        // to ensure that every letter is uppercase
      }
      if (double.tryParse(list[i]) == null &&
          !(RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i]))) {
        list[i] = '<';
        // sometimes < sign not recognized well
      }
    }
    String result = list.join('');
    return result;
  }
}
