import 'dart:async';
import 'dart:io';

import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/upload/upload_extra_screen.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:cross_file/cross_file.dart' show XFile;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tus_client/tus_client.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({
    Key? key,
    required this.videoId,
    required this.xFile,
  }) : super(key: key);

  final String videoId;
  final XFile xFile;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showMessage(String string) {
    var snackBar = SnackBar(content: Text('Message: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  var progress = 0.0;
  var title = '';
  var description = '';
  var ipfsName = '';
  var uploadStarted = false;
  var uploadComplete = false;
  String? thumbUrl;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      timer.cancel();
      initiateUpload();
    });
  }

  void initiateUpload() async {
    if (uploadStarted) return;
    setState(() {
      uploadStarted = true;
    });
    final client = TusClient(
      Uri.parse(Communicator.fsServer),
      widget.xFile,
      store: TusMemoryStore(),
    );
    await client.upload(
      onComplete: () async {
        print("Complete!");
        // Prints the uploaded file URL
        print(client.uploadUrl.toString());
        var url = client.uploadUrl.toString();
        var ipfsName = url.replaceAll("${Communicator.fsServer}/", "");
        var pathImageThumb = await getThumbnail(widget.xFile.path);
        setState(() {
          this.ipfsName = ipfsName;
          this.thumbUrl = pathImageThumb;
          uploadComplete = true;
        });
      },
      onProgress: (progress) {
        print("Progress: $progress");
        setState(() {
          this.progress = progress / 100.0;
        });
      },
    );
  }

  Widget _body() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Upload Progress'),
            SizedBox(height: 15),
            LinearProgressIndicator(value: progress),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                hintText: 'Video title goes here',
                labelText: 'Title',
              ),
              onChanged: (text) {
                setState(() {
                  title = text;
                });
              },
              maxLines: 1,
              minLines: 1,
              maxLength: 150,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Video description',
                labelText: 'Description',
              ),
              onChanged: (text) {
                setState(() {
                  description = text;
                });
              },
              maxLines: 8,
              minLines: 5,
            )
          ],
        ),
      ),
    );
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
    var user = Provider.of<HiveUserData?>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Info'),
      ),
      body: _body(),
      floatingActionButton: user != null && uploadComplete && title.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                var screen = UploadExtraScreen(
                  videoId: widget.videoId,
                  title: title,
                  description: description,
                  ipfsName: ipfsName,
                  thumbUrl: thumbUrl,
                );
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(context).push(route);
              },
              child: Text('Next'),
            )
          : null,
    );
  }
}
