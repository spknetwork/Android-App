import 'package:uuid/uuid.dart';
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

class HiveSocketData {
  WebSocketChannel? channel;
  String? hiveAuthQr;
  bool isLoadingQr;
  final appData = {
    "name": "3Speak Mobile iOS App",
    "description": "3Speak Mobile iOS App with HAS Integration",
  };
  String? appKey;
  String? authUuid;
  String? authKey;
  String? token;
  String? expire;

  HiveSocketData({
    required this.channel,
    required this.hiveAuthQr,
    required this.isLoadingQr,
    required this.appKey,
    required this.authUuid,
    required this.authKey,
    required this.token,
    required this.expire,
  });
}

class HiveUserData {
  String? username;
  String? postingKey;
  String? cookie;
  HiveKeychainData? keychainData;
  String resolution;
  String rpc;
  HiveSocketData? socketData;

  HiveUserData({
    required this.username,
    required this.postingKey,
    required this.keychainData,
    required this.cookie,
    required this.resolution,
    required this.rpc,
    required this.socketData,
  });
}
