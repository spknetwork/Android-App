import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class LoginBridgeResponse {
  final bool valid;
  final String? accountName;
  final String error;

  LoginBridgeResponse({
    required this.valid,
    required this.accountName,
    required this.error,
  });

  factory LoginBridgeResponse.fromJson(Map<String, dynamic>? json) =>
      LoginBridgeResponse(
        valid: asBool(json, 'valid'),
        accountName: asString(json, 'accountName'),
        error: asString(json, 'error'),
      );

  factory LoginBridgeResponse.fromJsonString(String jsonString) =>
      LoginBridgeResponse.fromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => {
        'valid': valid,
        'accountName': accountName,
        'error': error,
      };
}
