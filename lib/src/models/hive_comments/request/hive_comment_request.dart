import 'package:acela/src/utils/safe_convert.dart';
import 'dart:convert';

String hiveCommentRequestToJson(HiveCommentRequest data) =>
    json.encode(data.toJson());

class HiveCommentRequest {
  final List<String> params;

  // 2.0
  final String jsonrpc;

  // condenser_api.get_content_replies
  final String method;

  // 1
  final int id;

  HiveCommentRequest({
    required this.params,
    this.jsonrpc = "",
    this.method = "",
    this.id = 0,
  });

  factory HiveCommentRequest.from(List<String> params) {
    return HiveCommentRequest(
      params: params,
      method: "condenser_api.get_content_replies",
      jsonrpc: "2.0",
      id: 1,
    );
  }

  factory HiveCommentRequest.fromJson(Map<String, dynamic>? json) =>
      HiveCommentRequest(
        params: asList(json, 'params').map((e) => e.toString()).toList(),
        jsonrpc: asString(json, 'jsonrpc'),
        method: asString(json, 'method'),
        id: asInt(json, 'id'),
      );

  Map<String, dynamic> toJson() => {
        'params': params.map((e) => e).toList(),
        'jsonrpc': jsonrpc,
        'method': method,
        'id': id,
      };
}
