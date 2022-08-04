import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:acela/src/utils/communicator.dart';
import 'package:cross_file/cross_file.dart' show XFile;
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  var progress = 0.0;
  var compressionProgress = 0.0;
  late Subscription _subscription;

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
    setState(() {
      didShowFilePicker = true;
    });
    try {
      FilePickerResult? fileResult =
          await FilePicker.platform.pickFiles(type: FileType.video);
      if (fileResult != null && fileResult.files.single.path != null) {
        setState(() {
          didPickFile = true;
        });
        PlatformFile file = fileResult.files.single;
        log(file.name);
        log("bytes - ${file.bytes ?? 0}");
        log("size - ${file.size}");
        log("Extension - ${file.extension}");
        log("path - ${file.path}");
        final compressInfo = await VideoCompress.compressVideo(
          file.path!,
          quality: VideoQuality.Res960x540Quality,
          deleteOrigin: false,
          includeAudio: true,
        );
        setState(() {
          didCompress = true;
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
        var name = await initiateUpload(path);
        log('Uploaded file name is $name');
        throw 'compression, upload done';
      } else {
        throw 'User cancelled the video picker';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> initiateUpload(String path) async {
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
          didUpload = true;
        });
        name = ipfsName;
      },
      onProgress: (progress) {
        log("Progress: $progress");
        setState(() {
          this.progress = progress / 100.0;
        });
      },
    );
    return name;
  }

  Future<String?> getThumbnail(String path) async {
    Directory tempDir = Directory.systemTemp;
    var imagePath = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.PNG,
      maxWidth: 320,
      quality: 100,
    );
    return imagePath;
  }

  @override
  Widget build(BuildContext context) {
    // if (!didShowFilePicker) {
    //   videoPickerFunction();
    // }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Selecting video'),
            trailing: !didPickFile
                ? const CircularProgressIndicator()
                : const Icon(Icons.check),
          ),
          ListTile(
            title: Text(
                'Compressing video (${compressionProgress.toStringAsFixed(2)}%)'),
            trailing: !didCompress
                ? SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                        value: compressionProgress / 100.0),
                  )
                : const Icon(Icons.check),
          ),
          ListTile(
            title: Text(
                'Uploading video (${(progress * 100).toStringAsFixed(2)}%)'),
            trailing: !didUpload
                ? SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(value: progress),
                  )
                : const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}
