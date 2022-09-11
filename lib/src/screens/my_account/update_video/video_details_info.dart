import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/login/login_bridge_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/screens/communities_screen/communities_screen.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tus_client/tus_client.dart';

class VideoDetailsInfo extends StatefulWidget {
  const VideoDetailsInfo({
    Key? key,
    required this.item,
    required this.title,
    required this.subtitle,
  }) : super(key: key);
  final VideoDetails item;
  final String title;
  final String subtitle;

  @override
  State<VideoDetailsInfo> createState() => _VideoDetailsInfoState();
}

class _VideoDetailsInfoState extends State<VideoDetailsInfo> {
  var isCompleting = false;
  var isPickingImage = false;
  var uploadStarted = false;
  var uploadComplete = false;
  var isNsfwContent = false;
  var thumbIpfs = '';
  var thumbUrl = '';
  var tags = 'threespeak,mobile';
  var progress = 0.0;
  var processText = '';
  TextEditingController tagsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  var selectedCommunity = 'hive-181335';
  var selectedCommunityVisibleName = 'Threespeak';

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showMessage(String string) {
    var snackBar = SnackBar(content: Text('Message: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    tagsController.text = "threespeak,mobile";
  }

  void initiateUpload(
    HiveUserData data,
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
        log("Progress: $progress");
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
      var doesPostNotExist = await Communicator()
          .doesPostNotExist(widget.item.owner, widget.item.permlink);
      if (doesPostNotExist != true) {
        await Communicator().updatePublishState(user, widget.item.id);
        setState(() {
          isCompleting = false;
          processText = '';
          showMessage('Your video was already published.');
          showMyDialog();
        });
      } else {
        var v = await Communicator().updateInfo(
          user: user,
          videoId: widget.item.id,
          title: widget.title,
          description: widget.subtitle,
          isNsfwContent: isNsfwContent,
          tags: tags,
          thumbnail: thumbIpfs.isEmpty ? null : thumbIpfs,
        );
        const platform = MethodChannel('com.example.acela/auth');
        var title = base64.encode(utf8.encode(widget.title));
        var description = base64.encode(utf8.encode(widget.subtitle));
        final String response = await platform.invokeMethod('newPostVideo', {
          'thumbnail': v.thumbnailValue,
          'video_v2': v.videoValue,
          'description': description,
          'title': title,
          'tags': v.tags,
          'username': user.username,
          'permlink': v.permlink,
          'duration': v.duration,
          'size': v.size,
          'originalFilename': v.originalFilename,
          'firstUpload': v.firstUpload,
          'bene': v.benes[0],
          'beneW': v.benes[1],
          'postingKey': user.postingKey,
          'community': selectedCommunity,
        });
        log('Response from platform $response');
        var bridgeResponse = LoginBridgeResponse.fromJsonString(response);
        if (bridgeResponse.error == "success") {
          await Communicator().updatePublishState(user, v.id);
          setState(() {
            isCompleting = false;
            processText = '';
            showMessage('Congratulations. Your video is published.');
            showMyDialog();
          });
        } else {
          throw bridgeResponse.error;
        }
      }
    } catch (e) {
      showError(e.toString());
      setState(() {
        isCompleting = false;
        processText = '';
      });
    }
  }

  void showMyDialog() {
    Widget okButton = TextButton(
      child: Text("Okay"),
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("🎉 Congratulations 🎉"),
      content: Text("Your Video is published on Hive."),
      actions: [
        okButton,
      ],
    );
    showDialog(context: context, builder: (c) => alert);
  }

  Widget _thumbnailPicker(HiveUserData user) {
    return Center(
      child: Container(
        width: 320,
        height: 160,
        margin: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
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
                        : widget.item.thumbUrl.isNotEmpty
                            ? Image.network(
                                widget.item.thumbUrl,
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
              final XFile? file =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (file != null) {
                setState(() {
                  isPickingImage = false;
                });
                initiateUpload(user, file);
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
      margin: const EdgeInsets.all(10),
      child: TextField(
        controller: tagsController,
        decoration: const InputDecoration(
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
      margin: const EdgeInsets.all(10),
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

  Widget _communityPicker() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          const Text('Post to:'),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (c) => CommunitiesScreen(
                    didSelectCommunity: (name, id) {
                      setState(() {
                        selectedCommunity = id;
                        selectedCommunityVisibleName = name;
                      });
                    },
                  ),
                ),
              );
            },
            child: Row(
              children: [
                CustomCircleAvatar(
                  width: 44,
                  height: 44,
                  url: server.communityIcon(selectedCommunity),
                ),
                SizedBox(width: 10),
                Text(selectedCommunityVisibleName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<HiveUserData>(context);
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
                _communityPicker(),
                _thumbnailPicker(user),
                const Text('Tap to change video thumbnail'),
              ],
            ),
      floatingActionButton: isCompleting
          ? null
          : thumbIpfs.isNotEmpty || widget.item.thumbUrl.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    if (user.username != null) {
                      completeVideo(user);
                    }
                  },
                  child: const Icon(Icons.save),
                )
              : null,
    );
  }
}
