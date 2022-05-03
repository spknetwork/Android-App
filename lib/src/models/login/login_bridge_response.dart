import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class LoginBridgeResponse {
  final bool valid;
  final String accountName;
  final String postingKey;
  final String error;

  LoginBridgeResponse({
    required this.valid,
    required this.accountName,
    required this.postingKey,
    required this.error,
  });

  factory LoginBridgeResponse.fromJson(Map<String, dynamic>? json) =>
      LoginBridgeResponse(
        valid: asBool(json, 'valid'),
        accountName: asString(json, 'accountName'),
        postingKey: asString(json, 'postingKey'),
        error: asString(json, 'error'),
      );

  factory LoginBridgeResponse.fromJsonString(String jsonString) =>
      LoginBridgeResponse.fromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => {
        'valid': valid,
        'accountName': accountName,
        'postingKey': postingKey,
        'error': error,
      };
}
