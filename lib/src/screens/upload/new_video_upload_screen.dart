import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:cross_file/cross_file.dart' show XFile;
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tus_client/tus_client.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class NewVideoUploadScreen extends StatefulWidget {
  const NewVideoUploadScreen({Key? key}) : super(key: key);

  @override
  State<NewVideoUploadScreen> createState() => _NewVideoUploadScreenState();
}

class _NewVideoUploadScreenState extends State<NewVideoUploadScreen> {
  var didShowFilePicker = false;
  var didPickFile = false;
  var didCompress = false;
  var didUpload = false;
  var didTakeDefaultThumbnail = false;
  var didUploadThumbnail = false;
  var didMoveToQueue = false;

  var didStartPickFile = false;
  var didStartCompress = false;
  var didStartUpload = false;
  var didStartTakeDefaultThumbnail = false;
  var didStartUploadThumbnail = false;
  var didStartMoveToQueue = false;

  var progress = 0.0;
  var thumbnailUploadProgress = 0.0;
  var compressionProgress = 0.0;
  late Subscription _subscription;
  HiveUserData? user;

  @override
  void initState() {
    super.initState();
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
      setState(() {
        compressionProgress = progress;
      });
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      timer.cancel();
      videoPickerFunction();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
  }

  void videoPickerFunction() async {
    try {
      if (user == null) {
        throw 'User not logged in';
      }
      // Step 1. Select Video
      setState(() {
        didStartPickFile = true;
        didShowFilePicker = true;
      });
      FilePickerResult? fileResult =
          await FilePicker.platform.pickFiles(type: FileType.video);
      if (fileResult != null && fileResult.files.single.path != null) {
        setState(() {
          didPickFile = true;
        });
        PlatformFile file = fileResult.files.single;
        var originalFileName = file.name;
        log(file.name);
        log("bytes - ${file.bytes ?? 0}");
        log("size - ${file.size}");
        log("Extension - ${file.extension}");
        log("path - ${file.path}");
        // ---- Step 1. Select Video

        // Step 2. Compress Video
        setState(() {
          didStartCompress = true;
        });
        final compressInfo = await VideoCompress.compressVideo(
          file.path!,
          quality: VideoQuality.Res640x480Quality,
          deleteOrigin: false,
          includeAudio: true,
        );
        setState(() {
          didCompress = true;
        });
        // --- Step 2. Compress Video

        // Step 3. Video upload
        setState(() {
          didStartUpload = true;
        });
        var fileSize = compressInfo?.filesize ?? file.size;
        var sizeInMb = fileSize / 1000 / 1000;
        if (sizeInMb > 500) {
          throw 'Video is too big to be uploaded from mobile (exceeding 500 mb)';
        }
        var path = compressInfo?.file?.path ?? file.path!;
        MediaInformationSession session =
            await FFprobeKit.getMediaInformation(path);
        var info = session.getMediaInformation();
        var duration =
            (double.tryParse(info?.getDuration() ?? "0.0") ?? 0.0).toInt();
        log('Video duration is $duration');
        var name = await initiateUpload(path, false);
        setState(() {
          didUpload = true;
        });
        // --- Step 3. Video upload

        // Step 4. Generate Thumbnail
        setState(() {
          didStartTakeDefaultThumbnail = true;
        });
        var thumbPath = await getThumbnail(path);
        setState(() {
          didTakeDefaultThumbnail = true;
        });
        // --- Step 4. Generate Thumbnail

        // Step 5. Upload Thumbnail
        setState(() {
          didStartUploadThumbnail = true;
        });
        var thumbName = await initiateUpload(thumbPath, true);
        setState(() {
          didUploadThumbnail = true;
        });
        // --- Step 5. Upload Thumbnail
        log('Uploaded file name is $name');
        log('Uploaded thumbnail file name is $thumbName');

        // Step 6. Move Video to Queue
        setState(() {
          didStartMoveToQueue = true;
        });
        var videoUploadInfo = await Communicator().newUploadComplete(
          user: user!,
          thumbnail: thumbName,
          oFilename: originalFileName,
          duration: duration,
          size: fileSize.toDouble(),
          tusFileName: name,
        );
        log(videoUploadInfo.status);
        setState(() {
          didMoveToQueue = true;
          showMessage('Video is uploaded & moved to encoding queue');
        });
        // Step 6. Move Video to Queue

        throw 'compression, upload done';
      } else {
        throw 'User cancelled the video picker';
      }
    } catch (e) {
      if (e.toString() == "User cancelled the video picker") {
        setState(() {
          Navigator.of(context).pop();
        });
      }
      rethrow;
    }
  }

  void showMessage(String string) {
    var snackBar = SnackBar(content: Text('Message: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<String> initiateUpload(String path, bool isThumbnail) async {
    final xfile = XFile(path);
    final client = TusClient(
      Uri.parse(Communicator.fsServer),
      xfile,
      store: TusMemoryStore(),
    );
    var name = "";
    await client.upload(
      onComplete: () async {
        log("Complete!");
        // Prints the uploaded file URL
        log(client.uploadUrl.toString());
        var url = client.uploadUrl.toString();
        var ipfsName = url.replaceAll("${Communicator.fsServer}/", "");
        // var pathImageThumb = await getThumbnail(xfile.path);
        setState(() {
          // this.ipfsName = ipfsName;
          // this.thumbUrl = pathImageThumb;
          if (isThumbnail) {
            didUploadThumbnail = true;
          } else {
            didUpload = true;
          }
        });
        name = ipfsName;
      },
      onProgress: (progress) {
        log("Progress: $progress");
        setState(() {
          if (isThumbnail) {
            thumbnailUploadProgress = progress / 100.0;
          } else {
            this.progress = progress / 100.0;
          }
        });
      },
    );
    return name;
  }

  Future<String> getThumbnail(String path) async {
    try {
      Directory tempDir = Directory.systemTemp;
      var imagePath = await VideoThumbnail.thumbnailFile(
        video: path,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 320,
        quality: 100,
      );
      if (imagePath == null) {
        throw 'Could not generate video thumbnail';
      }
      return imagePath;
    } catch (e) {
      throw 'Error generating video thumbnail ${e.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<HiveUserData?>(context);
    if (user != null && this.user == null) {
      this.user = user;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Upload Process'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Selecting & processing video'),
            trailing: !didPickFile
                ? !didStartPickFile
                    ? const Icon(Icons.pending)
                    : const CircularProgressIndicator()
                : const Icon(Icons.check),
          ),
          ListTile(
            title: Text(
                'Compressing video (${didCompress ? 100.0 : compressionProgress.toStringAsFixed(2)}%)'),
            trailing: !didStartCompress
                ? const Icon(Icons.pending)
                : !didCompress
                    ? SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                            value: compressionProgress / 100.0),
                      )
                    : const Icon(Icons.check),
          ),
          ListTile(
            title: Text(
                'Uploading video (${didUpload ? 100.0 : (progress * 100).toStringAsFixed(2)}%)'),
            trailing: !didStartUpload
                ? const Icon(Icons.pending)
                : !didUpload
                    ? SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(value: progress),
                      )
                    : const Icon(Icons.check),
          ),
          ListTile(
            title: const Text('Taking video thumbnail'),
            subtitle: const Text('You can edit thumbnail later'),
            trailing: !didStartTakeDefaultThumbnail
                ? const Icon(Icons.pending)
                : !didTakeDefaultThumbnail
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.check),
          ),
          ListTile(
            title: Text(
                'Uploading thumbnail (${didUpload ? 100.0 : (thumbnailUploadProgress * 100).toStringAsFixed(2)}%)'),
            trailing: !didStartUploadThumbnail
                ? const Icon(Icons.pending)
                : !didUploadThumbnail
                    ? SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                            value: thumbnailUploadProgress),
                      )
                    : const Icon(Icons.check),
          ),
          ListTile(
            title: const Text('Move video to Encoding Queue'),
            trailing: !didStartMoveToQueue
                ? const Icon(Icons.pending)
                : !didMoveToQueue
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}
