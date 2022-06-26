import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class VideoOpsResponse {
  final bool success;
  VideoOpsResponse({
    required this.success,
  });

  factory VideoOpsResponse.fromJson(Map<String, dynamic>? json) =>
      VideoOpsResponse(
        success: asBool(json, 'success'),
      );

  factory VideoOpsResponse.fromJsonString(String jsonString) =>
      VideoOpsResponse.fromJson(json.decode(jsonString));
}

class ErrorResponse {
  final String? error;
  ErrorResponse({
    required this.error,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic>? json) => ErrorResponse(
        error: asString(json, 'error'),
      );

  factory ErrorResponse.fromJsonString(String jsonString) =>
      ErrorResponse.fromJson(json.decode(jsonString));
}
