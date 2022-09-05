import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class CommunitiesRequestModel {
  final CommunitiesRequestParams params;

  // 2.0
  final String jsonrpc;

  // bridge.list_communities
  final String method;

  // 1
  final int id;

  CommunitiesRequestModel({
    required this.params,
    this.jsonrpc = "2.0",
    this.method = "bridge.list_communities",
    this.id = 1,
  });

  factory CommunitiesRequestModel.fromJson(Map<String, dynamic>? json) =>
      CommunitiesRequestModel(
        params: CommunitiesRequestParams.fromJson(asMap(json, 'params')),
        jsonrpc: asString(json, 'jsonrpc'),
        method: asString(json, 'method'),
        id: asInt(json, 'id'),
      );

  Map<String, dynamic> toJson() => {
        'params': params.toJson(),
        'jsonrpc': jsonrpc,
        'method': method,
        'id': id,
      };

  String toJsonString() => json.encode(toJson());
}

class CommunitiesRequestParams {
  // 100
  final int limit;
  final String? query;

  CommunitiesRequestParams({
    this.limit = 100,
    this.query,
  });

  factory CommunitiesRequestParams.fromJson(Map<String, dynamic>? json) =>
      CommunitiesRequestParams(
        limit: asInt(json, 'limit'),
      );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'limit': limit,
    };
    if (query != null && query!.isNotEmpty) {
      map['query'] = query;
    }
    return map;
  }
}
