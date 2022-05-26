import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class PlatformVideoInfo {
  final int? size;
  final String path;
  final String? oFilename;
  final int? duration;

  PlatformVideoInfo({
    required this.size,
    required this.path,
    required this.oFilename,
    required this.duration,
  });

  factory PlatformVideoInfo.fromJson(Map<String, dynamic>? json) =>
      PlatformVideoInfo(
        size: asInt(json, 'size'),
        path: asString(json, 'path'),
        oFilename: asString(json, 'oFilename'),
        duration: asInt(json, 'duration'),
      );

  factory PlatformVideoInfo.fromJsonString(String jsonString) =>
      PlatformVideoInfo.fromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => {
        'size': size,
        'path': path,
        'oFilename': oFilename,
        'duration': duration,
      };
}
