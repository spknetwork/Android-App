import 'dart:convert';
import 'package:acela/src/utils/safe_convert.dart';

class Followers {
  // 2.0
  final String jsonrpc;
  final List<FollowerItem> result;
  // 1
  final int id;

  Followers({
    this.jsonrpc = "",
    required this.result,
    this.id = 0,
  });

  factory Followers.fromJson(Map<String, dynamic>? json) => Followers(
    jsonrpc: asString(json, 'jsonrpc'),
    result: asList(json, 'result').map((e) => FollowerItem.fromJson(e)).toList(),
    id: asInt(json, 'id'),
  );

  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'result': result.map((e) => e.toJson()),
    'id': id,
  };
}

class FollowerItem {
  // lepe
  final String follower;
  // madefrance
  final String following;
  final List<String> what;

  FollowerItem({
    this.follower = "",
    this.following = "",
    required this.what,
  });

  factory FollowerItem.fromJson(Map<String, dynamic>? json) => FollowerItem(
    follower: asString(json, 'follower'),
    following: asString(json, 'following'),
    what: asList(json, 'what').map((e) => e.toString()).toList(),
  );

  Map<String, dynamic> toJson() => {
    'follower': follower,
    'following': following,
    'what': what.map((e) => e),
  };
}

