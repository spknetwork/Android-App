import 'dart:convert';
import 'package:acela/src/utils/safe_convert.dart';

class UserProfileRequest {
  // 2.0
  final String jsonrpc;

  // bridge.get_profile
  final String method;
  final UserProfileRequestParams params;

  // 1
  final int id;

  UserProfileRequest({
    this.jsonrpc = "",
    this.method = "",
    required this.params,
    this.id = 0,
  });

  factory UserProfileRequest.fromJson(Map<String, dynamic>? json) =>
      UserProfileRequest(
        jsonrpc: asString(json, 'jsonrpc'),
        method: asString(json, 'method'),
        params: UserProfileRequestParams.fromJson(asMap(json, 'params')),
        id: asInt(json, 'id'),
      );

  factory UserProfileRequest.forOwner(String owner) => UserProfileRequest(
      jsonrpc: "2.0",
      method: "bridge.get_profile",
      params: UserProfileRequestParams(account: owner),
      id: 1);

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'method': method,
        'params': params.toJson(),
        'id': id,
      };

  String toJsonString() => json.encode(toJson());
}

class UserProfileRequestParams {
  // sagarkothari88
  final String account;

  UserProfileRequestParams({
    this.account = "",
  });

  factory UserProfileRequestParams.fromJson(Map<String, dynamic>? json) =>
      UserProfileRequestParams(
        account: asString(json, 'account'),
      );

  Map<String, dynamic> toJson() => {
        'account': account,
      };
}
