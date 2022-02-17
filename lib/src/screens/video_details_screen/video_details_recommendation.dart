import 'dart:developer';
import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/video_recommendation_models/video_recommendation.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/widgets/list_tile_video.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';

class VideoDetailsRecommendationWidget extends StatefulWidget {
  const VideoDetailsRecommendationWidget({Key? key, required this.vm})
      : super(key: key);
  final VideoDetailsViewModel vm;

  @override
  _VideoDetailsRecommendationWidgetState createState() =>
      _VideoDetailsRecommendationWidgetState();
}

class _VideoDetailsRecommendationWidgetState
    extends State<VideoDetailsRecommendationWidget>
    with AutomaticKeepAliveClientMixin<VideoDetailsRecommendationWidget> {
  @override
  bool get wantKeepAlive => true;

  Widget listTile(VideoRecommendationItem item) {
    return ListTile(
      title: ListTileVideo(
        placeholder: 'assets/branding/three_speak_logo.png',
        url: item.image,
        userThumbUrl: server.userOwnerThumb(item.owner),
        title: item.title,
        subtitle: "",
        onUserTap: () {
          Navigator.of(context).pushNamed("/userChannel/${item.owner}");
        },
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed(VideoDetailsScreen.routeName(item.owner, item.mediaid));
      },
    );
  }

  Widget recommendationsListView(List<VideoRecommendationItem> videos) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListView.separated(
          itemBuilder: (context, index) {
            return listTile(videos[index]);
          },
          separatorBuilder: (context, index) => const Divider(
                height: 10,
                color: Colors.blueGrey,
              ),
          itemCount: videos.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: widget.vm.getRecommendedVideos(),
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          String text =
              'Something went wrong - ${snapshot.error?.toString() ?? ""}';
          return Text(text);
        } else if (snapshot.hasData) {
          var data = snapshot.data! as List<VideoRecommendationItem>;
          return recommendationsListView(data);
        } else {
          return const LoadingScreen();
        }
      },
    );
  }
}
