import 'dart:convert';
import 'package:acela/src/utils/safe_convert.dart';

class HivePayoutResponse {
  final String jsonrpc;
  final HivePayoutResponseResult result;

  HivePayoutResponse({
    this.jsonrpc = "",
    required this.result,
  });

  factory HivePayoutResponse.fromJson(Map<String, dynamic>? json) => HivePayoutResponse(
    jsonrpc: asString(json, 'jsonrpc'),
    result: HivePayoutResponseResult.fromJson(asMap(json, 'result')),
  );

  factory HivePayoutResponse.fromJsonString(String jsonString) => HivePayoutResponse.fromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'result': result.toJson(),
  };
}

class HivePayoutResponseResult {
  final String totalPayoutValue;
  final String curatorPayoutValue;
  final String pendingPayoutValue;

  HivePayoutResponseResult({
    this.totalPayoutValue = "",
    this.curatorPayoutValue = "",
    this.pendingPayoutValue = "",
  });

  factory HivePayoutResponseResult.fromJson(Map<String, dynamic>? json) => HivePayoutResponseResult(
    totalPayoutValue: asString(json, 'total_payout_value'),
    curatorPayoutValue: asString(json, 'curator_payout_value'),
    pendingPayoutValue: asString(json, 'pending_payout_value'),
  );

  Map<String, dynamic> toJson() => {
    'total_payout_value': totalPayoutValue,
    'curator_payout_value': curatorPayoutValue,
    'pending_payout_value': pendingPayoutValue,
  };
}

