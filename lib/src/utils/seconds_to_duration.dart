
class Utilities {
  static String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  static String parseAndFormatDateTime(String dateTime) {
    var dt = DateTime.parse(dateTime);
    return "${dt.year}-${dt.month}-${dt.year}";
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );

    return htmlText.replaceAll(exp, '');
  }
}