import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class MyDevices {
  final bool success;
  final List<MyDevicesDataItem> data;

  MyDevices({
    this.success = false,
    required this.data,
  });

  factory MyDevices.fromJson(Map<String, dynamic>? json) => MyDevices(
        success: asBool(json, 'success'),
        data: asList(json, 'data')
            .map((e) => MyDevicesDataItem.fromJson(e))
            .toList(),
      );

  factory MyDevices.fromString(String string) =>
      MyDevices.fromJson(json.decode(string));

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data.map((e) => e.toJson()),
      };
}

class MyDevicesDataItem {
  final String token;
  final String deviceName;

  MyDevicesDataItem({
    this.token = "",
    this.deviceName = "",
  });

  factory MyDevicesDataItem.fromJson(Map<String, dynamic>? json) =>
      MyDevicesDataItem(
        token: asString(json, 'token'),
        deviceName: asString(json, 'deviceName'),
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'deviceName': deviceName,
      };
}
