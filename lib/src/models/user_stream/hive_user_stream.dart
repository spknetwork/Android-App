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

  HiveUserData({
    required this.username,
    required this.postingKey,
    required this.keychainData,
    required this.cookie,
    required this.resolution,
    required this.rpc,
  });
}
