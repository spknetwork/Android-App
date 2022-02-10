import 'dart:convert';
import 'package:acela/src/utils/safe_convert.dart';

VideoDetails videoDetailsFromJson(String str) =>
    VideoDetails.fromJson(json.decode(str));

String videoDetailsToJson(VideoDetails data) => json.encode(data.toJson());

class VideoDetails {
  // 2022-02-08T19:17:10.065Z
  final String created;

  // false
  final bool paid;

  // 5
  final int views;
  final List<String> tagsV2;

  // 6202bef63df91fd29d7cbd2d
  final String id;

  // iOS Development
  final String community;

  // gqbffyah
  final String permlink;

  // 203.333333
  final double duration;

  // 98062751
  final int size;

  // sagarkothari88
  final String owner;

  // URL - https://acela-9c624.web.app/### What did I do?* Research & Experiments for 	* iOS App Deployment	* Android App Deployment	* Web-app Deployment* Deployed web-app on firebase hosting* Why App as an web-app?	* With the features we've built - It's 99% same experience for web-app or app.	* For now, we're deploying it as web-app so that we do not have to worry about Apple's approval process or Google's Play Store approval process.### What's next?* User's Channel Home page### Previous UpdatesIf you've not checked my previous videos, please check those.* Updates in 3 mins - 3Speak.tv app for iOS, Android & Web    * https://3speak.tv/watch?v=sagarkothari88/nzvezwzc* Updates in 5 mins - 3Speak.tv App for iOS, Android & Web    * https://3speak.tv/watch?v=sagarkothari88/hawmmhlq* How do I install 3Speak.tv app on my Android Device?    * https://3speak.tv/watch?v=sagarkothari88/xtdlszgb* 3Speak App Update    * https://3speak.tv/watch?v=sagarkothari88/mfmakjwp* 3Speak App Update    * https://3speak.tv/watch?v=sagarkothari88/canucyoa* iOS App Update in 6 mins    * https://3speak.tv/watch?v=sagarkothari88/bfvgzkkl* iOS App Update in 3 mins    * https://3speak.tv/watch?v=sagarkothari88/xtlyduch* iOS App Update in 2 mins    * https://3speak.tv/watch?v=sagarkothari88/iwdnghrnPlease please please up-vote my videos to keep me motivated.
  final String description;

  // ipfs://bafybeieh2ylatpwqaoah7ztbwwj43bm3v3v76ymb732tkzxyr4fq4ea3aq
  final String thumbnail;

  // How do I install app on my iPhone or on my Android?
  final String title;

  // https://images.hive.blog/p/99pyU5Ga1kwr5bsMXthzYLbcngN4W2P8NtU9TWTdHC3HaQbjuuRfKKVdjVfWMw2cQWSAejpKRAqR2gj56yBNVYN6UkvLX7djqZAu5a3HuWPbdhvhtLqLkUTqPszx6T1CMU?format=jpeg&mode=cover&width=340&height=191
  final String thumbUrl;

  // https://ipfs-3speak.b-cdn.net/ipfs/bafybeieh2ylatpwqaoah7ztbwwj43bm3v3v76ymb732tkzxyr4fq4ea3aq/
  final String baseThumbUrl;

  // https://threespeakvideo.b-cdn.net/gqbffyah/default.m3u8
  final String playUrl;

  VideoDetails({
    this.created = "",
    this.paid = false,
    this.views = 0,
    required this.tagsV2,
    this.id = "",
    this.community = "",
    this.permlink = "",
    this.duration = 0.0,
    this.size = 0,
    this.owner = "",
    this.description = "",
    this.thumbnail = "",
    this.title = "",
    this.thumbUrl = "",
    this.baseThumbUrl = "",
    this.playUrl = "",
  });

  factory VideoDetails.fromJson(Map<String, dynamic>? json) => VideoDetails(
        created: asString(json, 'created'),
        paid: asBool(json, 'paid'),
        views: asInt(json, 'views'),
        tagsV2: asList(json, 'tags_v2').map((e) => e.toString()).toList(),
        id: asString(json, '_id'),
        community: asString(json, 'community'),
        permlink: asString(json, 'permlink'),
        duration: asDouble(json, 'duration'),
        size: asInt(json, 'size'),
        owner: asString(json, 'owner'),
        description: asString(json, 'description'),
        thumbnail: asString(json, 'thumbnail'),
        title: asString(json, 'title'),
        thumbUrl: asString(json, 'thumbUrl'),
        baseThumbUrl: asString(json, 'baseThumbUrl'),
        playUrl: asString(json, 'playUrl'),
      );

  Map<String, dynamic> toJson() => {
        'created': created,
        'paid': paid,
        'views': views,
        'tags_v2': tagsV2.map((e) => e),
        '_id': id,
        'community': community,
        'permlink': permlink,
        'duration': duration,
        'size': size,
        'owner': owner,
        'description': description,
        'thumbnail': thumbnail,
        'title': title,
        'thumbUrl': thumbUrl,
        'baseThumbUrl': baseThumbUrl,
        'playUrl': playUrl,
      };
}
