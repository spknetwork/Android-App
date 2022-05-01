import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class LoginResponse {
  final String jsonrpc;
  final List<LoginResponseResult> result;
  final int id;

  LoginResponse({
    this.jsonrpc = "",
    required this.result,
    this.id = 0,
  });

  factory LoginResponse.fromJson(Map<String, dynamic>? json) => LoginResponse(
        jsonrpc: asString(json, 'jsonrpc'),
        result: asList(json, 'result')
            .map((e) => LoginResponseResult.fromJson(e))
            .toList(),
        id: asInt(json, 'id'),
      );

  factory LoginResponse.fromJsonString(String jsonString) =>
      LoginResponse.fromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'result': result.map((e) => e.toJson()),
        'id': id,
      };
}

class LoginResponseResult {
  final int id;
  final String name;
  final LoginResponseResultKeyAuths owner;
  final LoginResponseResultKeyAuths active;
  final LoginResponseResultKeyAuths posting;

  LoginResponseResult({
    this.id = 0,
    this.name = "",
    required this.owner,
    required this.active,
    required this.posting,
  });

  factory LoginResponseResult.fromJson(Map<String, dynamic>? json) =>
      LoginResponseResult(
        id: asInt(json, 'id'),
        name: asString(json, 'name'),
        owner: LoginResponseResultKeyAuths.fromJson(asMap(json, 'owner')),
        active: LoginResponseResultKeyAuths.fromJson(asMap(json, 'active')),
        posting: LoginResponseResultKeyAuths.fromJson(asMap(json, 'posting')),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'owner': owner.toJson(),
        'active': active.toJson(),
        'posting': posting.toJson(),
      };
}

class LoginResponseResultKeyAuths {
  final List<String> keyAuths;

  LoginResponseResultKeyAuths({
    required this.keyAuths,
  });

  factory LoginResponseResultKeyAuths.fromJson(Map<String, dynamic>? json) =>
      LoginResponseResultKeyAuths(
        keyAuths: asList(json, 'key_auths')
            .map((e) => (e as List<dynamic>).first as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'key_auths': keyAuths.map((e) => e),
      };
}
