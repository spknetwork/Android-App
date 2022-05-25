import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class MemoResponse {
  final String error;
  final String accountName;
  final String decrypted;

  MemoResponse({
    this.error = "",
    this.accountName = "",
    this.decrypted = "",
  });

  factory MemoResponse.fromJson(Map<String, dynamic>? json) => MemoResponse(
        error: asString(json, 'error'),
        accountName: asString(json, 'accountName'),
        decrypted: asString(json, 'decrypted'),
      );

  factory MemoResponse.fromJsonString(String jsonString) =>
      MemoResponse.fromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => {
        'error': error,
        'accountName': accountName,
        'decrypted': decrypted,
      };
}
