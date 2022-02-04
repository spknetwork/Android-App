// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_comments_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HiveCommentsRequest _$HiveCommentsRequestFromJson(Map<String, dynamic> json) =>
    HiveCommentsRequest(
      params:
          (json['params'] as List<dynamic>).map((e) => e as String).toList(),
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      method: json['method'] as String? ?? 'condenser_api.get_content_replies',
      id: json['id'] as int? ?? 1,
    );

Map<String, dynamic> _$HiveCommentsRequestToJson(
        HiveCommentsRequest instance) =>
    <String, dynamic>{
      'params': instance.params,
      'jsonrpc': instance.jsonrpc,
      'method': instance.method,
      'id': instance.id,
    };
