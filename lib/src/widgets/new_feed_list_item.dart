import 'dart:io';
import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/screens/podcast/widgets/favourite.dart';
import 'package:acela/src/screens/video_details_screen/new_video_details/video_detail_favourite_provider.dart';
import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/new_video_details/new_video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/cached_image.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewFeedListItem extends StatefulWidget {
  const NewFeedListItem(
      {Key? key,
      required this.createdAt,
      required this.duration,
      required this.views,
      required this.thumbUrl,
      required this.author,
      required this.title,
      required this.permlink,
      required this.onTap,
      required this.onUserTap,
      required this.comments,
      required this.votes,
      required this.hiveRewards,
      this.item,
      this.appData,
      this.showVideo = false,
      this.onFavouriteRemoved})
      : super(key: key);

  final DateTime? createdAt;
  final double? duration;
  final int? views;
  final String thumbUrl;
  final String author;
  final String title;
  final String permlink;
  final int? votes;
  final int? comments;
  final double? hiveRewards;
  final Function onTap;
  final Function onUserTap;
  final GQLFeedItem? item;
  final HiveUserData? appData;
  final bool showVideo;
  final VoidCallback? onFavouriteRemoved;

  @override
  State<NewFeedListItem> createState() => _NewFeedListItemState();
}

class _NewFeedListItemState extends State<NewFeedListItem> {
  BetterPlayerController? _betterPlayerController;
  final VideoFavoriteProvider favoriteProvider = VideoFavoriteProvider();

  @override
  void initState() {
    if (widget.showVideo) {
      _initVideo();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant NewFeedListItem oldWidget) {
    if (widget.showVideo && _betterPlayerController == null) {
      _initVideo();
    } else if (oldWidget.showVideo && !widget.showVideo) {
      if (_betterPlayerController != null) {
        _betterPlayerController!.dispose();
        _betterPlayerController = null;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void setupVideo(
    String url,
  ) {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      fit: BoxFit.contain,
      autoPlay: true,
      fullScreenByDefault: false,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enablePip: false,
        enableFullscreen: false,
        enableSkips: true,
      ),
      autoDetectFullscreenAspectRatio: false,
      autoDetectFullscreenDeviceOrientation: false,
      autoDispose: true,
      expandToFill: true,
      allowedScreenSleep: false,
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      Platform.isAndroid
          ? url.replaceAll("/manifest.m3u8", "/480p/index.m3u8")
          : url,
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController!.setupDataSource(dataSource);
  }

  void _initVideo() async {
    setupVideo(widget.item!.videoV2M3U8(widget.appData!));
  }

  Widget listTile() {
    String timeInString = widget.createdAt != null
        ? "📝 ${timeago.format(widget.createdAt!)}"
        : "";
    String durationString = widget.duration != null
        ? " 🕚 ${Utilities.formatTime(widget.duration!.toInt())} "
        : "";
    return Stack(
      children: [
        ListTile(
          tileColor: Colors.black,
          contentPadding: EdgeInsets.zero,
          title: widget.showVideo && _betterPlayerController != null
              ? SizedBox(
                  height: 230,
                  child: BetterPlayer(
                    controller: _betterPlayerController!,
                  ),
                )
              : CachedImage(
                  imageUrl: widget.thumbUrl,
                  imageHeight: 230,
                ),
          subtitle: ListTile(
            contentPadding: EdgeInsets.all(2),
            dense: true,
            leading: InkWell(
              child: ClipOval(
                child: CachedImage(
                  imageHeight: 40,
                  imageWidth: 40,
                  loadingIndicatorSize: 25,
                  imageUrl: server.userOwnerThumb(widget.author),
                ),
              ),
              onTap: () {
                widget.onUserTap();
                var screen = UserChannelScreen(owner: widget.author);
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(context).push(route);
              },
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(widget.title),
            ),
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  child: Text('👤 ${widget.author}'),
                  onTap: () {
                    widget.onUserTap();
                    var screen = UserChannelScreen(owner: widget.author);
                    var route = MaterialPageRoute(builder: (c) => screen);
                    Navigator.of(context).push(route);
                  },
                ),
                Spacer(),
                Icon(
                  Icons.thumb_up_sharp,
                  size: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Text('  ${widget.votes ?? 0}'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.5, left: 15),
                  child: Icon(
                    Icons.comment,
                    size: 15,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Text('  ${widget.comments}'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 1.0, right: 5),
                  child: FavouriteWidget(
                      alignment: Alignment.topCenter,
                      disablePadding: true,
                      iconSize: 15,
                      isLiked: favoriteProvider
                          .isLikedVideoPresentLocally(widget.item!),
                      onAdd: () {
                        favoriteProvider.storeLikedVideoLocally(widget.item!);
                      },
                      onRemove: () {
                        favoriteProvider.storeLikedVideoLocally(widget.item!,forceRemove: true);
                        if (widget.onFavouriteRemoved != null)
                          widget.onFavouriteRemoved!();
                      },
                      toastType: 'Video'),
                )
              ],
            ),
          ),
          onTap: () {
            widget.onTap();
            if (widget.item == null || widget.appData == null) {
              var viewModel = VideoDetailsViewModel(
                author: widget.author,
                permlink: widget.permlink,
              );
              var screen = VideoDetailsScreen(vm: viewModel);
              var route = MaterialPageRoute(builder: (context) => screen);
              Navigator.of(context).push(route);
            } else {
              var screen = NewVideoDetailsScreen(
                  item: widget.item!, appData: widget.appData!);
              var route = MaterialPageRoute(builder: (context) => screen);
              Navigator.of(context).push(route);
            }
          },
        ),
        Visibility(
          visible: !widget.showVideo,
          child: Column(
            children: [
              const SizedBox(height: 208),
              Row(
                children: [
                  SizedBox(width: 5),
                  if (timeInString.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(timeInString,
                          style: TextStyle(color: Colors.white)),
                    ),
                  Spacer(),
                  if (durationString.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(durationString,
                          style: TextStyle(color: Colors.white)),
                    ),
                  SizedBox(width: 5),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return listTile();
  }
}
