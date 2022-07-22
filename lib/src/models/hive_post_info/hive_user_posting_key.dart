import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class HiveUserPostingKey {
  final String publicPostingKey;

  HiveUserPostingKey({
    required this.publicPostingKey,
  });

  factory HiveUserPostingKey.fromJson(Map<String, dynamic>? json) {
    var resultMap = asMap(json, 'result');
    var accounts = asList(resultMap, 'accounts');
    if (accounts.isEmpty) throw 'accounts is empty';
    var postingMap = asMap(accounts[0], 'posting');
    var keyAuthsTopLevel = asList(postingMap, 'key_auths');
    if (keyAuthsTopLevel.isEmpty) throw 'Posting Key auths top level empty';
    var firstKeyAuth = keyAuthsTopLevel[0] as List<dynamic>;
    var postingPublicKey = firstKeyAuth[0] as String;
    return HiveUserPostingKey(publicPostingKey: postingPublicKey);
  }

  factory HiveUserPostingKey.fromString(String string) =>
      HiveUserPostingKey.fromJson(json.decode(string));
}
