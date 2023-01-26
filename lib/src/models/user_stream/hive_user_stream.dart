import 'package:web_socket_channel/web_socket_channel.dart';

class HiveKeychainData {
  String hasId;
  String hasExpiry;
  String hasAuthKey;
  HiveKeychainData({
    required this.hasId,
    required this.hasExpiry,
    required this.hasAuthKey,
  });
}
class HiveUserData {
  String? username;
  String? postingKey;
  String? cookie;
  HiveKeychainData? keychainData;
  String resolution;
  String rpc;
  WebSocketChannel? socket;
  String? hiveAuthLoginQR;

  HiveUserData({
    required this.username,
    required this.postingKey,
    required this.keychainData,
    required this.cookie,
    required this.resolution,
    required this.rpc,
    required this.socket,
    required this.hiveAuthLoginQR,
  });
}
