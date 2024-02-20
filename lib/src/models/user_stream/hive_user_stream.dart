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
  String union;
  bool loaded;
  String? accessToken;
  late bool postingAuthority;

  HiveUserData(
      {required this.username,
      required this.postingKey,
      required this.keychainData,
      required this.accessToken,
      required this.cookie,
      required this.resolution,
      required this.rpc,
      required this.union,
      required this.loaded,
      required this.language,
      required String? postingAuthority,}) {
    if (postingAuthority != null) {
      this.postingAuthority = postingAuthority == 'true';
    } else {
      this.postingAuthority = false;
    }
  }
}
