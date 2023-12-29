import 'package:acela/src/widgets/box_loading/video_item_loader.dart';
import 'package:flutter/material.dart';

class VideoFeedLoader extends StatelessWidget {
  const VideoFeedLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top : 10.0),
      child: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom : 10.0),
            child: VideoItemLoader(),
          ),
        ),
      ),
    );
  }
}
