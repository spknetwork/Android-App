import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/screens/my_account/update_video/video_details_info.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoPrimaryInfo extends StatefulWidget {
  const VideoPrimaryInfo({
    Key? key,
    required this.item,
    required this.justForEditing,
  }) : super(key: key);
  final VideoDetails item;
  final bool justForEditing;

  @override
  State<VideoPrimaryInfo> createState() => _VideoPrimaryInfoState();
}

class _VideoPrimaryInfoState extends State<VideoPrimaryInfo> {
  var title = '';
  var description = '';
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.item.title;
    descriptionController.text = widget.item.description;
    title = widget.item.title;
    description = widget.item.description;
  }

  Widget _body() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Video title goes here',
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
                hintText: 'Video description',
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
            )
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
          subtitle: Text('Edit Video Info'),
        ),
      ),
      body: _body(),
      floatingActionButton: description.isNotEmpty && title.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                var screen = VideoDetailsInfo(
                  item: widget.item,
                  title: titleController.text,
                  subtitle: descriptionController.text,
                  justForEditing: widget.justForEditing,
                  hasKey: appData.keychainData?.hasId ?? "",
                  hasAuthKey: appData.keychainData?.hasAuthKey ?? "",
                  appData: appData,
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
