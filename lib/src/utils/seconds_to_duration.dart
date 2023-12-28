class Utilities {
  static String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  static String parseAndFormatDateTime(String dateTime) {
    var dt = DateTime.parse(dateTime);
    return "${dt.year}-${dt.month}-${dt.day}";
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  static Duration doubleToDuration(double value) {
    int seconds = value.toInt();
    int milliseconds = ((value - seconds) * 1000).round();
    return Duration(seconds: seconds, milliseconds: milliseconds);
  }

  static double durationToDouble(Duration duration) {
    return duration.inMilliseconds / 1000.0;
  }
}
