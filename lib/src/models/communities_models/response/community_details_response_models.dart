import 'dart:developer';

import 'package:acela/src/utils/safe_convert.dart';
import 'dart:convert';

class CommunityDetailsResponse {
  // 2.0
  final String jsonrpc;
  final CommunityDetailsResponseResult result;

  // 1
  final int id;

  CommunityDetailsResponse({
    this.jsonrpc = "",
    required this.result,
    this.id = 0,
  });

  factory CommunityDetailsResponse.fromJson(Map<String, dynamic>? json) =>
      CommunityDetailsResponse(
        jsonrpc: asString(json, 'jsonrpc'),
        result: CommunityDetailsResponseResult.fromJson(asMap(json, 'result')),
        id: asInt(json, 'id'),
      );

  factory CommunityDetailsResponse.fromString(String string) =>
      CommunityDetailsResponse.fromJson(json.decode(string));

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'result': result.toJson(),
        'id': id,
      };
}

class CommunityDetailsResponseResult {
  // 1341662
  final int id;

  // hive-167922
  final String name;

  // LeoFinance
  final String title;

  // LeoFinance is a community for crypto & finance. Powered by Hive and the LEO token economy.
  final String about;

  // en
  final String lang;

  // 1
  final int typeId;

  // false
  final bool isNsfw;

  // 12009
  final int subscribers;

  // 2019-11-26 17:25:27
  final String createdAt;

  // 22177
  final int sumPending;

  // 12112
  final int numPending;

  // 1435
  final int numAuthors;
  final String avatarUrl;

  // Using our Hive-based token (LEO) we reward content creators and users for engaging on our platform at https://leofinance.io and within our community on the Hive blockchain. Blogging is just the beginning of what's possible in the LeoFinance community and with the LEO token:1). Trade LEO and other Hive-based tokens on our exchange: https://leodex.io2). Track your Hive account statistics at https://hivestats.io3). Opt-in to ads on LEO Apps which drives value back into the LEO token economy from ad buybacks.4). Learn & contribute to our crypto-educational resource at https://leopedia.io5). Wrap LEO onto the Ethereum blockchain with our cross-chain token bridge: https://wleo.io (coming soon)Learn more about us at https://leopedia.io/faq
  final String description;

  // Content should be related to the financial space (i.e. crypto, equities, etc. etc.)Posts created from our interface (https://leofinance.io) are eligible for upvotes from @leo.voter and will automatically be posted to our Hive community, our front end and other Hive front ends as wellPosts in our community are also eligible to earn our native token (LEO) in conjunction with HIVE post rewardsIf you have any questions or need help with anything, feel free to reach out to us on twitter (@financeleo) or head over to our discord server (https://discord.gg/KgcVDKQ)
  final String flagText;
  final List<List<String>> team;

  CommunityDetailsResponseResult({
    this.id = 0,
    this.name = "",
    this.title = "",
    this.about = "",
    this.lang = "",
    this.typeId = 0,
    this.isNsfw = false,
    this.subscribers = 0,
    this.createdAt = "",
    this.sumPending = 0,
    this.numPending = 0,
    this.numAuthors = 0,
    this.avatarUrl = "",
    this.description = "",
    this.flagText = "",
    required this.team,
  });

  factory CommunityDetailsResponseResult.fromJson(Map<String, dynamic>? json) =>
      CommunityDetailsResponseResult(
        id: asInt(json, 'id'),
        name: asString(json, 'name'),
        title: asString(json, 'title'),
        about: asString(json, 'about'),
        lang: asString(json, 'lang'),
        typeId: asInt(json, 'type_id'),
        isNsfw: asBool(json, 'is_nsfw'),
        subscribers: asInt(json, 'subscribers'),
        createdAt: asString(json, 'created_at'),
        sumPending: asInt(json, 'sum_pending'),
        numPending: asInt(json, 'num_pending'),
        numAuthors: asInt(json, 'num_authors'),
        avatarUrl: asString(json, 'avatar_url'),
        description: asString(json, 'description'),
        flagText: asString(json, 'flag_text'),
        team: asList(json, 'team').map((e) {
          log("Console message goes here");
          return (e as List<dynamic>).map((s) => asDynamicString(s)).toList();
        }).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'about': about,
        'lang': lang,
        'type_id': typeId,
        'is_nsfw': isNsfw,
        'subscribers': subscribers,
        'created_at': createdAt,
        'sum_pending': sumPending,
        'num_pending': numPending,
        'num_authors': numAuthors,
        'avatar_url': avatarUrl,
        'description': description,
        'flag_text': flagText,
        'team': team.map((e) => e),
      };
}
