import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

CommunitiesResponseModel communitiesResponseModelFromString(String string) {
  return CommunitiesResponseModel.fromJson(json.decode(string));
}

class CommunitiesResponseModel {
  // 2.0
  final String jsonrpc;
  final List<CommunityItem> result;
  // 1
  final int id;

  CommunitiesResponseModel({
    this.jsonrpc = "",
    required this.result,
    this.id = 0,
  });

  factory CommunitiesResponseModel.fromJson(Map<String, dynamic>? json) =>
      CommunitiesResponseModel(
        jsonrpc: asString(json, 'jsonrpc'),
        result: asList(json, 'result')
            .map((e) => CommunityItem.fromJson(e))
            .toList(),
        id: asInt(json, 'id'),
      );

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'result': result.map((e) => e.toJson()),
        'id': id,
      };
}

class CommunityItem {
  // 1341662
  final int id;
  // hive-167922
  final String name;
  // LeoFinance
  final String title;
  // LeoFinance is a community for crypto & finance. Powered by Hive and the LEO token economy.
  final String about;
  // 1
  final int typeId;
  // false
  final bool isNsfw;
  // 11475
  final int subscribers;
  // 29860
  final int sumPending;
  final int numAuthors;
  final List<String> admins;

  CommunityItem({
    this.id = 0,
    this.name = "",
    this.title = "",
    this.about = "",
    this.typeId = 0,
    this.isNsfw = false,
    this.subscribers = 0,
    this.sumPending = 0,
    this.numAuthors = 0,
    required this.admins,
  });

  factory CommunityItem.fromJson(Map<String, dynamic>? json) => CommunityItem(
        id: asInt(json, 'id'),
        name: asString(json, 'name'),
        title: asString(json, 'title'),
        about: asString(json, 'about'),
        typeId: asInt(json, 'type_id'),
        isNsfw: asBool(json, 'is_nsfw'),
        subscribers: asInt(json, 'subscribers'),
        sumPending: asInt(json, 'sum_pending'),
        numAuthors: asInt(json, 'num_authors'),
        admins: asList(json, 'admins').map((e) => e.toString()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'about': about,
        'type_id': typeId,
        'is_nsfw': isNsfw,
        'subscribers': subscribers,
        'sum_pending': sumPending,
        'num_authors': numAuthors,
        'admins': admins.map((e) => e),
      };
}
