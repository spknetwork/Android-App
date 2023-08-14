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
  String authKey;
  String encryptedData;

  HiveSocketData({
    required this.authKey,
    required this.encryptedData,
  });
}

class HiveUserData {
  String? username;
  String? postingKey;
  String? cookie;
  String? language;
  HiveKeychainData? keychainData;
  String resolution;
  String rpc;
  bool loaded;

  HiveUserData({
    required this.username,
    required this.postingKey,
    required this.keychainData,
    required this.cookie,
    required this.resolution,
    required this.rpc,
    required this.loaded,
    required this.language,
  });
}
