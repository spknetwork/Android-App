import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'hive_comments_request.g.dart';

String hiveCommentsRequestToJson(HiveCommentsRequest data) =>
    json.encode(data.toJson());

@JsonSerializable()
class HiveCommentsRequest {
  HiveCommentsRequest(
      {required this.params,
      required this.jsonrpc,
      required this.method,
      required this.id});

  List<String> params;

  @JsonKey(defaultValue: "2.0")
  String jsonrpc;

  @JsonKey(defaultValue: "condenser_api.get_content_replies")
  String method;

  @JsonKey(defaultValue: 1)
  int id;

  Map<String, dynamic> toJson() => _$HiveCommentsRequestToJson(this);

  factory HiveCommentsRequest.from(String author, String permlink) {
    return HiveCommentsRequest(
        params: [author, permlink],
        jsonrpc: "2.0",
        method: "condenser_api.get_content_replies",
        id: 1);
  }
}