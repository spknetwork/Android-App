import 'dart:convert';

class VideoUploadCompleteRequest {
  final String videoId;
  final String title;
  final String description;
  final bool isNsfwContent;
  final String tags;
  final String? thumbnail;

  VideoUploadCompleteRequest({
    required this.videoId,
    required this.title,
    required this.description,
    required this.isNsfwContent,
    required this.tags,
    required this.thumbnail,
  });

  Map<String, dynamic> toJson() {
    var map = {
      'videoId': videoId,
      'title': title,
      'description': description,
      'isNsfwContent': isNsfwContent,
      'tags': tags,
    };
    if (thumbnail != null && thumbnail!.isNotEmpty) {
      map['thumbnail'] = thumbnail!;
    }
    return map;
  }

  String toJsonString() => json.encode(toJson());
}

class VideoThumbUpdateRequest {
  final String videoId;
  final String thumbnail;

  VideoThumbUpdateRequest({
    required this.videoId,
    required this.thumbnail,
  });

  Map<String, dynamic> toJson() {
    return {'videoId': videoId, 'thumbnail': thumbnail};
  }

  String toJsonString() => json.encode(toJson());
}

class NewVideoUploadCompleteRequest {
  final String oFilename;
  final int duration;
  final double size;
  final String filename;
  final String thumbnail;
  final String owner;
  final bool isReel;
  final String? parent_author;
  final String? parent_permlink;

  NewVideoUploadCompleteRequest({
    required this.oFilename,
    required this.duration,
    required this.size,
    required this.filename,
    required this.thumbnail,
    required this.owner,
    required this.isReel,
    required this.parent_author,
    required this.parent_permlink,
  });

  Map<String, dynamic> toJson() => {
        'filename': filename,
        'oFilename': oFilename,
        'size': size,
        'duration': duration,
        'thumbnail': thumbnail,
        'owner': owner,
        'isReel': isReel,
        'parent_author': parent_author,
        'parent_permlink': parent_permlink,
      };

  String toJsonString() => json.encode(toJson());
}
