import 'package:acela/src/global_provider/image_resolution_provider.dart';
import 'package:flutter/material.dart';

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

  static int textLines(
      String text, TextStyle style, double maxWidth, int? maxLines) {
    TextSpan textSpan = TextSpan(text: text, style: style);
    TextPainter textPainter = TextPainter(
      text: textSpan,
      maxLines: maxLines,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);

    return textPainter.computeLineMetrics().length;
  }

  static getProxyImage(String resolution, String imageUrl) {
    String actualResolution = Resolution.removePFromResolution(resolution);
    return 'https://images.hive.blog/${actualResolution}x0/$imageUrl';
  }
}
