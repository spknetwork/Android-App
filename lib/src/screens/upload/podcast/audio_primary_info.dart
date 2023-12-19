import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/communities_screen/communities_screen.dart';
import 'package:acela/src/screens/upload/podcast/audio_details_info.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AudioPrimaryInfo extends StatefulWidget {
  const AudioPrimaryInfo({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  final String title;
  final String url;

  @override
  State<AudioPrimaryInfo> createState() => _AudioPrimaryInfoState();
}

class _AudioPrimaryInfoState extends State<AudioPrimaryInfo> {
  var title = '';
  var description = '';
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  late String selectedCommunity; //= 'hive-181335';
  late String selectedCommunityVisibleName; //= 'Threespeak';
  var isNsfwContent = false;

  @override
  void initState() {
    super.initState();
    selectedCommunity = 'hive-181335';
    selectedCommunityVisibleName = 'Three Speak';
    titleController.text = widget.title;
    title = widget.title;
  }

  Widget _notSafe() {
    return Row(
      children: [
        Text(isNsfwContent
            ? 'Video is NOT SAFE for work.'
            : 'Video is Safe for work.'),
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
    );
  }

  Widget _communityPicker() {
    return Row(
      children: [
        const Text('Select Community:'),
        Spacer(),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (c) => CommunitiesScreen(
                  withoutScaffold: false,
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
              Text(selectedCommunityVisibleName),
              SizedBox(width: 10),
              CustomCircleAvatar(
                width: 44,
                height: 44,
                url: server.communityIcon(selectedCommunity),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _body() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Audio title goes here',
                labelText: 'Title',
                suffixIcon: IconButton(
                  onPressed: () {
                    titleController.clear();
                    setState(() {
                      title = '';
                    });
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
              onChanged: (text) {
                setState(() {
                  title = text;
                });
              },
              controller: titleController,
              maxLines: 1,
              minLines: 1,
              maxLength: 150,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Audio description',
                labelText: 'Description',
                suffixIcon: IconButton(
                  onPressed: () {
                    descriptionController.clear();
                    setState(() {
                      description = '';
                    });
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
              onChanged: (text) {
                setState(() {
                  description = text;
                });
              },
              controller: descriptionController,
              maxLines: 8,
              minLines: 5,
            ),
            const SizedBox(height: 10),
            _communityPicker(),
            const SizedBox(height: 10),
            _notSafe(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<HiveUserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: CustomCircleAvatar(
            height: 36,
            width: 36,
            url: 'https://images.hive.blog/u/${appData.username ?? ''}/avatar',
          ),
          title: Text(appData.username ?? ''),
        ),
      ),
      body: _body(),
      floatingActionButton: description.isNotEmpty && title.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                var screen = AudioDetailsInfoScreen(
                  title: title,
                  description: description,
                  appData: appData,
                  selectedCommunity: selectedCommunity,
                  isNsfwContent: isNsfwContent,
                  hasKey: appData.keychainData?.hasId ?? "",
                  hasAuthKey: appData.keychainData?.hasAuthKey ?? "",
                  owner: appData.username ?? "",
                );
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(context).push(route);
              },
              child: const Text('Next'),
            )
          : null,
    );
  }
}
