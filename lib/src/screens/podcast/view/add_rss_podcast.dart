import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:acela/src/screens/podcast/controller/podcast_controller.dart';
import 'package:acela/src/utils/podcast/podcast_communicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddRssPodcast extends StatefulWidget {
  const AddRssPodcast({Key? key}) : super(key: key);

  @override
  State<AddRssPodcast> createState() => _AddRssPodcastState();
}

class _AddRssPodcastState extends State<AddRssPodcast> {
  final TextEditingController textEditingController = TextEditingController();

  bool isAdding = false;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15.0),
        child: isAdding ? _loadingBody() : _body(),
      ),
    );
  }

  Column _loadingBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: CircularProgressIndicator(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text("Adding please wait..."),
        )
      ],
    );
  }

  Column _body() {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 60.0, bottom: 30),
        child: Icon(
          Icons.podcasts,
          size: 60,
        ),
      ),
      Text(
        "Add podcast by RSS feed",
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
      const SizedBox(
        height: 8,
      ),
      Text(
        "To add a podcast to your favourites by RSS feed, paste the full RSS URL in the field",
        style: TextStyle(fontSize: 14, color: Colors.white54),
        textAlign: TextAlign.center,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: TextField(
          controller: textEditingController,
          decoration: InputDecoration(
              fillColor: Colors.grey.shade800,
              filled: true,
              hintText: "Enter URL",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none),
        ),
      ),
      SizedBox(
        width: 120,
        child: TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: onAdd,
            child: Text(
              "Add",
              style: const TextStyle(color: Colors.white),
            )),
      )
    ]);
  }

  void onAdd() async {
    if (textEditingController.text.trim().isNotEmpty) {
      try {
        setState(() {
          isAdding = true;
        });
        final controller = context.read<PodcastController>();
        PodCastFeedItem item = await PodCastCommunicator()
            .getPodcastFeedByRss(textEditingController.text.trim());
        if (!controller.isLikedPodcastPresentLocally(item)) {
          controller.storeLikedPodcastLocally(item);
        }
        Navigator.pop(context);
        showSnackBar("Podcast ${item.title} is Added");
      } catch (e) {
        setState(() {
          isAdding = false;
        });
        showSnackBar(e.toString());
        print(e);
      }
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 3),
    ));
  }
}
