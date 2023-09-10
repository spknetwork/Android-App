import 'dart:convert';

class TrendingTagResponse {
  TrendingTagResponseData? data;

  TrendingTagResponse({
    this.data,
  });

  factory TrendingTagResponse.fromRawJson(String str) => TrendingTagResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TrendingTagResponse.fromJson(Map<String, dynamic> json) => TrendingTagResponse(
    data: json["data"] == null ? null : TrendingTagResponseData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
  };
}

class TrendingTagResponseData {
  TrendingTagResponseDataTrendingTags? trendingTags;

  TrendingTagResponseData({
    this.trendingTags,
  });

  factory TrendingTagResponseData.fromRawJson(String str) => TrendingTagResponseData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TrendingTagResponseData.fromJson(Map<String, dynamic> json) => TrendingTagResponseData(
    trendingTags: json["trendingTags"] == null ? null : TrendingTagResponseDataTrendingTags.fromJson(json["trendingTags"]),
  );

  Map<String, dynamic> toJson() => {
    "trendingTags": trendingTags?.toJson(),
  };
}

class TrendingTagResponseDataTrendingTags {
  List<TrendingTagResponseDataTrendingTag>? tags;

  TrendingTagResponseDataTrendingTags({
    this.tags,
  });

  factory TrendingTagResponseDataTrendingTags.fromRawJson(String str) => TrendingTagResponseDataTrendingTags.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TrendingTagResponseDataTrendingTags.fromJson(Map<String, dynamic> json) => TrendingTagResponseDataTrendingTags(
    tags: json["tags"] == null ? [] : List<TrendingTagResponseDataTrendingTag>.from(json["tags"]!.map((x) => TrendingTagResponseDataTrendingTag.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x.toJson())),
  };
}

class TrendingTagResponseDataTrendingTag {
  int score;
  String tag;

  TrendingTagResponseDataTrendingTag({
    required this.score,
    required this.tag,
  });

  factory TrendingTagResponseDataTrendingTag.fromRawJson(String str) => TrendingTagResponseDataTrendingTag.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TrendingTagResponseDataTrendingTag.fromJson(Map<String, dynamic> json) => TrendingTagResponseDataTrendingTag(
    score: json["score"],
    tag: json["tag"],
  );

  Map<String, dynamic> toJson() => {
    "score": score,
    "tag": tag,
  };
}
