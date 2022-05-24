import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class VideoUploadLoginResponse {
  final bool? banned;
  final String? memo;
  final String? userId;
  final String? network;
  final String? error;

  VideoUploadLoginResponse({
    required this.banned,
    required this.memo,
    required this.userId,
    required this.network,
    required this.error,
  });

  factory VideoUploadLoginResponse.fromJson(Map<String, dynamic>? json) =>
      VideoUploadLoginResponse(
        banned: asBool(json, 'banned'),
        memo: asString(json, 'memo'),
        userId: asString(json, 'user_id'),
        network: asString(json, 'network'),
        error: asString(json, 'error'),
      );

  factory VideoUploadLoginResponse.fromJsonString(String jsonString) =>
      VideoUploadLoginResponse.fromJson(json.decode(jsonString));
}
