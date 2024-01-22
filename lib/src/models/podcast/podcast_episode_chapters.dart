import 'dart:convert';

import 'package:equatable/equatable.dart';

class PodcastEpisodeChapterResponse {
  final String? version;
  final List<PodcastEpisodeChapter> chapters;

  PodcastEpisodeChapterResponse({
    this.version,
    required this.chapters,
  });

  factory PodcastEpisodeChapterResponse.fromRawJson(String str) =>
      PodcastEpisodeChapterResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PodcastEpisodeChapterResponse.fromJson(Map<String, dynamic> json) =>
      PodcastEpisodeChapterResponse(
        version: json["version"],
        chapters: json["chapters"] == null
            ? []
            : List<PodcastEpisodeChapter>.from(json["chapters"]!
                .map((x) => PodcastEpisodeChapter.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "version": version,
        "chapters": List<PodcastEpisodeChapter>.from(
                chapters.map(
                  (x) => x.toJson(),
                ),
              ),
      };
}

class PodcastEpisodeChapter extends Equatable {
  final int? startTime;
  final String? title;
  final String? image;
  final String? url;
  final int? endTime;
  final bool? toc;

  PodcastEpisodeChapter({
    this.startTime,
    this.title,
    this.image,
    this.url,
    this.endTime,
    this.toc,
  });

  factory PodcastEpisodeChapter.fromRawJson(String str) =>
      PodcastEpisodeChapter.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PodcastEpisodeChapter.fromJson(Map<String, dynamic> json) =>
      PodcastEpisodeChapter(
        startTime: json["startTime"],
        title: json["title"],
        image: json["img"],
        url: json["url"],
        endTime: json["endTime"],
        toc: json["toc"],
      );

  Map<String, dynamic> toJson() => {
        "startTime": startTime,
        "title": title,
        "img": image,
        "url": url,
        "endTime": endTime,
        "toc": toc,
      };

  @override
  List<Object?> get props => [title, startTime, image];
}
