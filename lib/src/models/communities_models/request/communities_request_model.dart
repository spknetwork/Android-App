import 'package:acela/src/utils/safe_convert.dart';
import 'dart:convert';

String communitiesRequestModelToJson(CommunitiesRequestModel data) =>
    json.encode(data.toJson());

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
}

class CommunitiesRequestParams {
  // 100
  final int limit;

  CommunitiesRequestParams({
    this.limit = 100,
  });

  factory CommunitiesRequestParams.fromJson(Map<String, dynamic>? json) =>
      CommunitiesRequestParams(
        limit: asInt(json, 'limit'),
      );

  Map<String, dynamic> toJson() => {
        'limit': limit,
      };
}
