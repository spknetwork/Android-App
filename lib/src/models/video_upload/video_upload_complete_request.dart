import 'dart:convert';

class VideoUploadCompleteRequest {
  final String videoId;
  final String filename;
  VideoUploadCompleteRequest({
    required this.videoId,
    required this.filename,
  });

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'filename': filename,
      };

  String toJsonString() => json.encode(toJson());
}
