import 'dart:convert';
import 'package:acela/src/utils/safe_convert.dart';

class UserProfileResponse {
  // 2.0
  final String jsonrpc;
  final UserProfile result;
  // 1
  final int id;

  UserProfileResponse({
    this.jsonrpc = "",
    required this.result,
    this.id = 0,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic>? json) => UserProfileResponse(
    jsonrpc: asString(json, 'jsonrpc'),
    result: UserProfile.fromJson(asMap(json, 'result')),
    id: asInt(json, 'id'),
  );

  factory UserProfileResponse.fromString(String string) {
    return UserProfileResponse.fromJson(json.decode(string));
  }

  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'result': result.toJson(),
    'id': id,
  };
}

class UserProfile {
  // 2267004
  final int id;
  // sagarkothari88
  final String name;
  // 2021-11-18T17:43:36
  final String created;
  // 2022-02-23T00:27:15
  final String active;
  // 82
  final int postCount;
  // 61.36
  final double reputation;
  final UserProfileStats stats;
  final UserProfileMetadata metadata;

  UserProfile({
    this.id = 0,
    this.name = "",
    this.created = "",
    this.active = "",
    this.postCount = 0,
    this.reputation = 0.0,
    required this.stats,
    required this.metadata,
  });

  factory UserProfile.fromJson(Map<String, dynamic>? json) => UserProfile(
    id: asInt(json, 'id'),
    name: asString(json, 'name'),
    created: asString(json, 'created'),
    active: asString(json, 'active'),
    postCount: asInt(json, 'post_count'),
    reputation: asDouble(json, 'reputation'),
    stats: UserProfileStats.fromJson(asMap(json, 'stats')),
    metadata: UserProfileMetadata.fromJson(asMap(json, 'metadata')),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'created': created,
    'active': active,
    'post_count': postCount,
    'reputation': reputation,
    'stats': stats.toJson(),
    'metadata': metadata.toJson(),
  };
}

class UserProfileStats {
  // 0
  final int rank;
  // 9
  final int following;
  // 18
  final int followers;

  UserProfileStats({
    this.rank = 0,
    this.following = 0,
    this.followers = 0,
  });

  factory UserProfileStats.fromJson(Map<String, dynamic>? json) => UserProfileStats(
    rank: asInt(json, 'rank'),
    following: asInt(json, 'following'),
    followers: asInt(json, 'followers'),
  );

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'following': following,
    'followers': followers,
  };
}


class UserProfileMetadata {
  final UserProfileMetadataProfile profile;

  UserProfileMetadata({
    required this.profile,
  });

  factory UserProfileMetadata.fromJson(Map<String, dynamic>? json) => UserProfileMetadata(
    profile: UserProfileMetadataProfile.fromJson(asMap(json, 'profile')),
  );

  Map<String, dynamic> toJson() => {
    'profile': profile.toJson(),
  };
}

class UserProfileMetadataProfile {
  // sagar.kothari.88
  final String name;
  // Block chain based Social Media - Mobile App Developer
  final String about;
  final String website;
  // On Internet
  final String location;
  // https://files.peakd.com/file/peakd-hive/sagarkothari88/sagar.kothari.png
  final String coverImage;
  // https://files.peakd.com/file/peakd-hive/sagarkothari88/None_32e767de-b206-4f60-a4ca-b22f51f29d8c.jpg
  final String profileImage;
  final String blacklistDescription;
  final String mutedListDescription;

  UserProfileMetadataProfile({
    this.name = "",
    this.about = "",
    this.website = "",
    this.location = "",
    this.coverImage = "",
    this.profileImage = "",
    this.blacklistDescription = "",
    this.mutedListDescription = "",
  });

  factory UserProfileMetadataProfile.fromJson(Map<String, dynamic>? json) => UserProfileMetadataProfile(
    name: asString(json, 'name'),
    about: asString(json, 'about'),
    website: asString(json, 'website'),
    location: asString(json, 'location'),
    coverImage: asString(json, 'cover_image'),
    profileImage: asString(json, 'profile_image'),
    blacklistDescription: asString(json, 'blacklist_description'),
    mutedListDescription: asString(json, 'muted_list_description'),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'about': about,
    'website': website,
    'location': location,
    'cover_image': coverImage,
    'profile_image': profileImage,
    'blacklist_description': blacklistDescription,
    'muted_list_description': mutedListDescription,
  };
}

