import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:tus_client/tus_client.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UploadedItem {
  String fileName;
  String filePath;
  UploadedItem({required this.fileName, required this.filePath});
  toJSONEncodable() {
    Map<String, dynamic> m = new Map();
    m['fileName'] = fileName;
    m['filePath'] = filePath;
    return m;
  }
}

class UploadedItemList {
  List<UploadedItem> items = [];

  toJSONEncodable() {
    return items.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}

class NewVideoUploadScreen extends StatefulWidget {
  const NewVideoUploadScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);
  final bool camera;

  @override
  State<NewVideoUploadScreen> createState() => _NewVideoUploadScreenState();
}

class _NewVideoUploadScreenState extends State<NewVideoUploadScreen> {
  var didShowFilePicker = false;
  var didPickFile = false;
  // var didCompress = false;
  var didUpload = false;
  var didTakeDefaultThumbnail = false;
  var didUploadThumbnail = false;
  var didMoveToQueue = false;

  var timeShowFilePicker = '0.5 seconds';
  var timePickFile = '';
  // var timeCompress = '';
  var timeUpload = '';
  var timeTakeDefaultThumbnail = '';
  var timeUploadThumbnail = '';
  var timeMoveToQueue = '';

  var didStartPickFile = false;
  // var didStartCompress = false;
  var didStartUpload = false;
  var didStartTakeDefaultThumbnail = false;
  var didStartUploadThumbnail = false;
  var didStartMoveToQueue = false;

  var progress = 0.0;
  var thumbnailUploadProgress = 0.0;
  var compressionProgress = 0.0;
  late Subscription _subscription;
  HiveUserData? user;
  final ImagePicker _picker = ImagePicker();
  final LocalStorage storage = LocalStorage('uploaded_data');
  final UploadedItemList list = UploadedItemList();

  @override
  void initState() {
    super.initState();
    var items = storage.getItem('uploads');
    if (items != null) {
      setState(() {
        list.items = List<UploadedItem>.from(
          (items as List).map(
            (item) => UploadedItem(
              fileName: item['fileName'],
              filePath: item['filePath'],
            ),
          ),
        );
      });
    }
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress: $progress');
      setState(() {
        compressionProgress = progress;
      });
    });
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      timer.cancel();
      videoPickerFunction();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
  }

  void _addItem(String fileName, String filePath) {
    setState(() {
      final item = new UploadedItem(fileName: fileName, filePath: filePath);
      list.items.add(item);
      _saveToStorage();
    });
  }

  void _saveToStorage() {
    storage.setItem('uploads', list.toJSONEncodable());
  }

  void videoPickerFunction() async {
    try {
      if (user?.username == null) {
        throw 'User not logged in';
      }
      // Step 1. Select Video
      var dateStartGettingVideo = DateTime.now();
      setState(() {
        didStartPickFile = true;
        didShowFilePicker = true;
      });

      final XFile? file = await _picker.pickVideo(
          source: widget.camera ? ImageSource.camera : ImageSource.gallery);
      if (file != null) {
        setState(() {
          didPickFile = true;
        });

        var originalFileName = file.name;
        var fileToSave = File(file.path);
        log(originalFileName);
        // log("bytes - ${videoFile.bytes ?? 0}");
        // log("size - ${file.size}");
        log("path - ${file.path}");
        var alreadyUploaded = list.items.contains((e) {
          return e.fileName == originalFileName || e.filePath == file.path;
        });
        if (alreadyUploaded) {
          throw 'This video is already uploaded by you';
        }
        var size = await file.length();
        // var size = file.size;
        // ---- Step 1. Select Video

        /*
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }

        List<Directory>? storage = await getExternalStorageDirectories();
        if (storage == null) {
          throw 'Storage null';
        }

        var externalDirPath = storage.first.path;

        var pathOfDir = file.path.replaceAll(file.name, "");
        var resultOfFfmpeg = await FFmpegKit.execute(
            "-i ${file.path} -codec: copy -bsf:v h264_mp4toannexb -start_number 0 -hls_time 10 -hls_list_size 0 -f hls $externalDirPath/index.m3u8");
        log('Result is ${resultOfFfmpeg.toString()}');
        var code = await resultOfFfmpeg.getReturnCode();
        final output = await resultOfFfmpeg.getOutput();
        log('code is ${(code?.isValueSuccess() ?? false) ? 'Success' : 'Failure'}');
        log('output is ${output.toString()}');
        throw 'Throwing error now';
*/
        if (widget.camera) {
          await ImagesPicker.saveVideoToAlbum(fileToSave);
        }
        var dateEndGettingVideo = DateTime.now();
        var diff = dateEndGettingVideo.difference(dateStartGettingVideo);
        setState(() {
          timePickFile = '${diff.inSeconds} seconds';
          didPickFile = true;
        });

        // Step 3. Video upload
        var dateStartUploadVideo = DateTime.now();
        setState(() {
          didStartUpload = true;
        });
        var fileSize = size;
        var sizeInMb = fileSize / 1000 / 1000;
        log("Compressed video file size in mb is - $sizeInMb");
        if (sizeInMb > 1024) {
          throw 'Video is too big to be uploaded from mobile (exceeding 500 mb)';
        }
        var path = file.path;
        MediaInformationSession session =
            await FFprobeKit.getMediaInformation(path);
        var info = session.getMediaInformation();
        var duration =
            (double.tryParse(info?.getDuration() ?? "0.0") ?? 0.0).toInt();
        log('Video duration is $duration');
        var name = await initiateUpload(path, false);
        var dateEndUploadVideo = DateTime.now();
        diff = dateEndUploadVideo.difference(dateStartUploadVideo);
        setState(() {
          timeUpload = '${diff.inSeconds} seconds';
          didUpload = true;
        });
        // --- Step 3. Video upload

        // Step 4. Generate Thumbnail
        var dateStartTakingThumbnail = DateTime.now();
        setState(() {
          didStartTakeDefaultThumbnail = true;
        });
        var thumbPath = await getThumbnail(path);
        var dateEndTakingThumbnail = DateTime.now();
        diff = dateEndTakingThumbnail.difference(dateStartTakingThumbnail);
        setState(() {
          timeTakeDefaultThumbnail = '${diff.inSeconds} seconds';
          didTakeDefaultThumbnail = true;
        });
        // --- Step 4. Generate Thumbnail

        // Step 5. Upload Thumbnail
        var dateStartUploadThumbnail = DateTime.now();
        setState(() {
          didStartUploadThumbnail = true;
        });
        var thumbName = await initiateUpload(thumbPath, true);
        var dateEndUploadThumbnail = DateTime.now();
        diff = dateEndUploadThumbnail.difference(dateStartUploadThumbnail);
        setState(() {
          timeUploadThumbnail = '${diff.inSeconds} seconds';
          didUploadThumbnail = true;
        });
        // --- Step 5. Upload Thumbnail
        log('Uploaded file name is $name');
        log('Uploaded thumbnail file name is $thumbName');

        // Step 6. Move Video to Queue
        var dateStartMoveToQueue = DateTime.now();
        setState(() {
          didStartMoveToQueue = true;
        });
        var videoUploadInfo = await Communicator().uploadInfo(
          user: user!,
          thumbnail: thumbName,
          oFilename: originalFileName,
          duration: duration,
          size: fileSize.toDouble(),
          tusFileName: name,
        );
        _addItem(originalFileName, file.path);
        log(videoUploadInfo.status);
        var dateEndMoveToQueue = DateTime.now();
        diff = dateEndMoveToQueue.difference(dateStartMoveToQueue);
        setState(() {
          timeMoveToQueue = '${diff.inSeconds} seconds';
          didMoveToQueue = true;
          showMessage('Video is uploaded & moved to encoding queue');
          showMyDialog();
        });
        // Step 6. Move Video to Queue
      } else {
        throw 'User cancelled the video picker';
      }
    } catch (e) {
      setState(() {
        Navigator.of(context).pop();
      });
      rethrow;
    }
  }

  void showMyDialog() {
    Widget okButton = TextButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("🎉 Congratulations 🎉"),
      content: Text(
          "✅ Your Video is uploaded.\n✅It is also moved to encoding queue.\n- Don't forget to check your video status from My Account section."),
      actions: [
        okButton,
      ],
    );
    showDialog(context: context, builder: (c) => alert);
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
    var user = Provider.of<HiveUserData>(context);
    if (user.username != null && this.user == null) {
      this.user = user;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Upload Process'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Launching Video Picker'),
            trailing: didShowFilePicker
                ? const Icon(Icons.check, color: Colors.lightGreen)
                : const Icon(Icons.pending),
            subtitle: didShowFilePicker ? Text(timeShowFilePicker) : null,
          ),
          ListTile(
            title: const Text('Getting/Compressing the Video'),
            trailing: !didPickFile
                ? !didStartPickFile
                    ? const Icon(Icons.pending)
                    : const CircularProgressIndicator()
                : const Icon(Icons.check, color: Colors.lightGreen),
            subtitle: didPickFile ? Text(timePickFile) : null,
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
                    : const Icon(Icons.check, color: Colors.lightGreen),
            subtitle: didUpload ? Text(timeUpload) : null,
          ),
          ListTile(
            title: const Text('Taking video thumbnail'),
            trailing: !didStartTakeDefaultThumbnail
                ? const Icon(Icons.pending)
                : !didTakeDefaultThumbnail
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.check, color: Colors.lightGreen),
            subtitle:
                didTakeDefaultThumbnail ? Text(timeTakeDefaultThumbnail) : null,
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
                    : const Icon(Icons.check, color: Colors.lightGreen),
            subtitle: didUploadThumbnail ? Text(timeUploadThumbnail) : null,
          ),
          ListTile(
            title: const Text('Move video to Encoding Queue'),
            trailing: !didStartMoveToQueue
                ? const Icon(Icons.pending)
                : !didMoveToQueue
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.check, color: Colors.lightGreen),
            subtitle: didMoveToQueue ? Text(timeMoveToQueue) : null,
          ),
        ],
      ),
    );
  }
}
