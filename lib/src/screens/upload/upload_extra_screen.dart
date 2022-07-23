import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:cross_file/cross_file.dart' show XFile;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tus_client/tus_client.dart';

class UploadExtraScreen extends StatefulWidget {
  const UploadExtraScreen({
    Key? key,
    required this.videoId,
    required this.title,
    required this.description,
    required this.ipfsName,
    required this.thumbUrl,
  }) : super(key: key);

  final String videoId;
  final String title;
  final String description;
  final String ipfsName;
  final String? thumbUrl;

  @override
  State<UploadExtraScreen> createState() => _UploadExtraScreenState();
}

class _UploadExtraScreenState extends State<UploadExtraScreen> {
  var isCompleting = false;
  var isPickingImage = false;
  var uploadStarted = false;
  var uploadComplete = false;
  var isNsfwContent = false;
  var thumbIpfs = '';
  var thumbUrl = '';
  var tags = '';
  var progress = 0.0;
  var processText = '';

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showMessage(String string) {
    var snackBar = SnackBar(content: Text('Message: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void initiateUpload(
    HiveUserData? data,
    XFile xFile,
  ) async {
    if (uploadStarted) return;
    setState(() {
      uploadStarted = true;
    });
    final client = TusClient(
      Uri.parse(Communicator.fsServer),
      xFile,
      store: TusMemoryStore(),
    );
    await client.upload(
      onComplete: () async {
        print("Complete!");
        print(client.uploadUrl.toString());
        var url = client.uploadUrl.toString();
        var ipfsName = url.replaceAll("${Communicator.fsServer}/", "");
        setState(() {
          thumbUrl = url;
          thumbIpfs = ipfsName;
          uploadComplete = true;
          uploadStarted = false;
        });
      },
      onProgress: (progress) {
        print("Progress: $progress");
        setState(() {
          this.progress = progress;
        });
      },
    );
  }

  void completeVideo(HiveUserData user) async {
    setState(() {
      isCompleting = true;
      processText = 'Updating video info';
    });
    try {
      var videoUploadInfo = await Communicator().uploadComplete(
        user: user,
        videoId: widget.videoId,
        name: widget.ipfsName,
        title: widget.title,
        description: widget.description,
        isNsfwContent: isNsfwContent,
        tags: tags,
        thumbnail: thumbIpfs,
      );
      print(videoUploadInfo.status);
      showMessage('Video is uploaded & moved to encoding queue');
      setState(() {
        isCompleting = false;
        processText = '';
      });
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      showError(e.toString());
    }
  }

  Widget _thumbnailPicker(HiveUserData? user) {
    return Center(
      child: Container(
        width: 320,
        height: 160,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 3,
                blurRadius: 3,
              )
            ]),
        child: InkWell(
          child: Center(
            child: isPickingImage
                ? const CircularProgressIndicator()
                : progress > 0.0 && progress < 100.0
                    ? CircularProgressIndicator(value: progress)
                    : thumbUrl.isNotEmpty
                        ? Image.network(
                            thumbUrl,
                            width: 320,
                            height: 160,
                          )
                        : const Text(
                            'Tap here to add thumbnail for your video\n\nThumbnail is MANDATORY to set.',
                            textAlign: TextAlign.center),
          ),
          onTap: () async {
            try {
              setState(() {
                isPickingImage = true;
              });
              FilePickerResult? fileResult =
                  await FilePicker.platform.pickFiles(type: FileType.image);
              if (fileResult != null && fileResult.files.single.path != null) {
                setState(() {
                  isPickingImage = false;
                });
                final xfile = XFile(fileResult.files.single.path!);
                initiateUpload(user, xfile);
              } else {
                throw 'User cancelled image picker';
              }
            } catch (e) {
              showError(e.toString());
              setState(() {
                isPickingImage = false;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _tagField() {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Comma separated tags',
          labelText: 'Tags',
        ),
        onChanged: (text) {
          setState(() {
            tags = text;
          });
        },
        maxLines: 1,
        minLines: 1,
        maxLength: 150,
      ),
    );
  }

  Widget _notSafe() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          const Text('Is this video NOT SAFE for work?'),
          const Spacer(),
          Switch(
            value: isNsfwContent,
            onChanged: (newVal) {
              setState(() {
                isNsfwContent = newVal;
              });
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<HiveUserData?>(context);
    if (user != null && thumbUrl.isEmpty && widget.thumbUrl != null) {
      initiateUpload(user, XFile(widget.thumbUrl!));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provide more info'),
      ),
      body: isCompleting
          ? Center(
              child: LoadingScreen(
                title: 'Please wait',
                subtitle: processText,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _tagField(),
                _notSafe(),
                _thumbnailPicker(user),
                const Text('Tap to change video thumbnail'),
              ],
            ),
      floatingActionButton: isCompleting
          ? null
          : thumbIpfs.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    if (user != null) {
                      completeVideo(user);
                    }
                  },
                  child: const Icon(Icons.save),
                )
              : null,
    );
  }
}
