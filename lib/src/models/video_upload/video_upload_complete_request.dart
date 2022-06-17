import 'dart:convert';

class VideoUploadCompleteRequest {
  final String videoId;
  final String filename;
  final String title;
  final String description;

  VideoUploadCompleteRequest({
    required this.videoId,
    required this.filename,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'filename': filename,
        'title': title,
        'description': description,
      };

  String toJsonString() => json.encode(toJson());
}
