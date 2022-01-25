import 'dart:convert';

String hiveCommentsRequestToJson(HiveCommentsRequest data) => json.encode(data.toJson());

class HiveCommentsRequest {
  HiveCommentsRequest({required this.params});
  List<String> params;
  var jsonrpc = "2.0";
  var method = "condenser_api.get_content_replies";
  var id = 1;

  factory HiveCommentsRequest.from(String author, String permlink) {
    return HiveCommentsRequest(params: [author, permlink]);
  }

  Map<String, dynamic> toJson() => {
    "jsonrpc": jsonrpc,
    "method": method,
    "id": id,
    "params": List<dynamic>.from(params.map((x) => x)),
  };
}

// {"jsonrpc":"2.0", "method":"condenser_api.get_content_replies", "params":["hiveio", "firstpost"], "id":1}