import 'dart:convert';

class ActionResponse<T> {
  final String? type;
  final String data;
  final bool valid;
  final String error;

  ActionResponse({
    this.type,
    required this.data,
    required this.valid,
    required this.error,
  });

  factory ActionResponse.fromJsonString(String string,) =>
      ActionResponse.fromJson(json.decode(string),);

  factory ActionResponse.fromJson(
      Map<String, dynamic> json,) {
    return ActionResponse(
      type: json['type'] as String,
      data: (json['data'] ),
      valid: json['valid'] as bool,
      error: json['error'] as String,
    );
  }
}
