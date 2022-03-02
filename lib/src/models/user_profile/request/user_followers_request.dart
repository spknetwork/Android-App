import 'dart:convert';
import 'package:acela/src/utils/safe_convert.dart';

class UserFollowerRequest {
  // 2.0
  final String jsonrpc;

  // bridge.get_profile
  final String method;
  final List<String?> params;

  // 1
  final int id;

  UserFollowerRequest({
    this.jsonrpc = "",
    this.method = "",
    required this.params,
    this.id = 0,
  });

  factory UserFollowerRequest.fromJson(Map<String, dynamic>? json) =>
      UserFollowerRequest(
        jsonrpc: asString(json, 'jsonrpc'),
        method: asString(json, 'method'),
        params: asList(json, 'params').map((e) => e.toString()).toList(),
        id: asInt(json, 'id'),
      );

  factory UserFollowerRequest.followers(String owner) => UserFollowerRequest(
      jsonrpc: "2.0",
      method: "condenser_api.get_followers",
      params: [owner, null, "blog"],
      id: 1);

  factory UserFollowerRequest.following(String owner) => UserFollowerRequest(
      jsonrpc: "2.0",
      method: "condenser_api.get_following",
      params: [owner, null, "blog"],
      id: 1);

  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'method': method,
    'params': params.map((e) => e).toList(),
    'id': id,
  };

  String toJsonString() => json.encode(toJson());
}