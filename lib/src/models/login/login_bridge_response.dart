import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class LoginBridgeResponse {
  final bool valid;
  final String? accountName;
  final String error;
  final String? data;

  LoginBridgeResponse({
    required this.valid,
    required this.accountName,
    required this.error,
    required this.data,
  });

  factory LoginBridgeResponse.fromJson(Map<String, dynamic>? json) =>
      LoginBridgeResponse(
        valid: asBool(json, 'valid'),
        accountName: asString(json, 'accountName'),
        error: asString(json, 'error'),
        data: asString(json, 'data'),
      );

  factory LoginBridgeResponse.fromJsonString(String jsonString) =>
      LoginBridgeResponse.fromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => {
        'valid': valid,
        'accountName': accountName,
        'error': error,
        'data': data,
      };
}

class ChallengeResponse {
  final String key_type;
  final String challenge;

  ChallengeResponse({
    required this.key_type,
    required this.challenge,
  });

  factory ChallengeResponse.fromJson(Map<String, dynamic>? json) =>
      ChallengeResponse(
        key_type: asString(json, 'key_type'),
        challenge: asString(json, 'challenge'),
      );

  factory ChallengeResponse.fromJsonString(String jsonString) =>
      ChallengeResponse.fromJson(json.decode(jsonString));
}