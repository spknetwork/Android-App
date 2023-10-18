import 'dart:convert';

class GQLHiveCommentReponse {
  final GQLHiveCommentReponseData data;

  GQLHiveCommentReponse({
    required this.data,
  });

  factory GQLHiveCommentReponse.fromRawJson(String str) =>
      GQLHiveCommentReponse.fromJson(json.decode(str));

  factory GQLHiveCommentReponse.fromJson(Map<String, dynamic> json) =>
      GQLHiveCommentReponse(
        data: GQLHiveCommentReponseData.fromJson(json["data"]),
      );
}

class GQLHiveCommentReponseData {
  final CommentSocialPostModel socialPost;

  GQLHiveCommentReponseData({
    required this.socialPost,
  });

  factory GQLHiveCommentReponseData.fromJson(Map<String, dynamic> json) => GQLHiveCommentReponseData(
        socialPost: CommentSocialPostModel.fromJson(json["socialPost"]),
      );
}

class CommentSocialPostModel {
  final List<VideoCommentModel>? children;
  final String? body;

  CommentSocialPostModel({
    required this.children,
    required this.body,
  });

  factory CommentSocialPostModel.fromJson(Map<String, dynamic> json) => CommentSocialPostModel(
        children:json["children"]!=null ? List<VideoCommentModel>.from(
            json["children"].map((x) {
              if(x!=null){
                return VideoCommentModel.fromJson(x);
              }
            })) : [],
        body: json["body"],
      );
}

class VideoCommentModel {
  final String? body;
  final String permlink;
  final DateTime? createdAt;
  final VideoCommentAuthorModel author;
  final VideoCommentStatsModel? stats;
  final List<VideoCommentModel>? children;

  VideoCommentModel({
    required this.body,
    required this.permlink,
    required this.createdAt,
    required this.author,
    required this.stats,
    required this.children,
  });

  factory VideoCommentModel.fromJson(Map<String, dynamic> json) => VideoCommentModel(
        body: json["body"],
        permlink: json["permlink"],
        createdAt: DateTime.parse(json["created_at"]),
        author: VideoCommentAuthorModel.fromJson(json["author"]),
        stats: VideoCommentStatsModel.fromJson(json["stats"]),
        children:json["children"]!=null ? List<VideoCommentModel>.from(json["children"].map((x) {
          if (x != null) {
            return VideoCommentModel.fromJson(x);
          }
        })) : [],
      );
}

class VideoCommentAuthorModel {
  final String username;

  VideoCommentAuthorModel({
    required this.username,
  });

  factory VideoCommentAuthorModel.fromJson(Map<String, dynamic> json) => VideoCommentAuthorModel(
        username: json["username"],
      );

}

class VideoCommentStatsModel {
  final int? numVotes;

  VideoCommentStatsModel({
    required this.numVotes,
  });

  factory VideoCommentStatsModel.fromJson(Map<String, dynamic> json) => VideoCommentStatsModel(
        numVotes: json["num_votes"] ?? 0,
      );
}
