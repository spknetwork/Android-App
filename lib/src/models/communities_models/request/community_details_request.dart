import 'package:acela/src/utils/safe_convert.dart';
import 'dart:convert';

class CommunityDetailsRequest {
  final CommunityDetailsRequestParams params;

  // 2.0
  final String jsonrpc;

  // bridge.get_community
  final String method;

  // 1
  final int id;

  CommunityDetailsRequest({
    required this.params,
    this.jsonrpc = "",
    this.method = "",
    this.id = 0,
  });

  factory CommunityDetailsRequest.fromJson(Map<String, dynamic>? json) =>
      CommunityDetailsRequest(
        params: CommunityDetailsRequestParams.fromJson(asMap(json, 'params')),
        jsonrpc: asString(json, 'jsonrpc'),
        method: asString(json, 'method'),
        id: asInt(json, 'id'),
      );

  factory CommunityDetailsRequest.forName(String name) {
    return CommunityDetailsRequest(
      params: CommunityDetailsRequestParams.forName(name),
      jsonrpc: "2.0",
      method: "bridge.get_community",
      id: 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'params': params.toJson(),
        'jsonrpc': jsonrpc,
        'method': method,
        'id': id,
      };

  String toJsonString() => json.encode(toJson());
}

class CommunityDetailsRequestParams {
  // hive-167922
  final String name;

  // sagarkothari88
  final String observer;

  CommunityDetailsRequestParams({
    this.name = "",
    this.observer = "",
  });

  factory CommunityDetailsRequestParams.fromJson(Map<String, dynamic>? json) =>
      CommunityDetailsRequestParams(
        name: asString(json, 'name'),
        observer: asString(json, 'observer'),
      );

  factory CommunityDetailsRequestParams.forName(String name) =>
      CommunityDetailsRequestParams(name: name, observer: 'sagarkothari88');

  Map<String, dynamic> toJson() => {
        'name': name,
        'observer': observer,
      };
}
