import 'dart:io';
import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/global_provider/image_resolution_provider.dart';
import 'package:acela/src/global_provider/video_setting_provider.dart';
import 'package:acela/src/screens/home_screen/home_screen_feed_item/widgets/home_feed_video_full_screen_button.dart';
import 'package:acela/src/screens/home_screen/home_screen_feed_item/widgets/home_feed_video_slider.dart';
import 'package:acela/src/screens/home_screen/home_screen_feed_item/widgets/home_feed_video_timer.dart';
import 'package:acela/src/screens/video_details_screen/new_video_details/video_detail_favourite_provider.dart';
import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/new_video_details/new_video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/cached_image.dart';
import 'package:acela/src/screens/home_screen/home_screen_feed_item/controller/home_feed_video_controller.dart';
import 'package:acela/src/screens/home_screen/home_screen_feed_item/widgets/mute_unmute_button.dart';
import 'package:acela/src/widgets/upvote_button.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

class _NewFeedListItemState extends State<NewFeedListItem>
    with AutomaticKeepAliveClientMixin {
  BetterPlayerController? _betterPlayerController;
  late final VideoSettingProvider videoSettingProvider;
  HomeFeedVideoController homeFeedVideoController = HomeFeedVideoController();
  final VideoFavoriteProvider favoriteProvider = VideoFavoriteProvider();

  @override
  void initState() {
    videoSettingProvider = context.read<VideoSettingProvider>();
    if (widget.showVideo) {
      _initVideo();
    }
    super.initState();
  }

  @override
  void dispose() {
    homeFeedVideoController.dispose();
    if (_betterPlayerController != null) {
      _betterPlayerController!.videoPlayerController?.dispose();
      _betterPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NewFeedListItem oldWidget) {
    if (widget.showVideo &&
        _betterPlayerController == null &&
        !homeFeedVideoController.isUserOnAnotherScreen) {
      _initVideo();
    } else if (oldWidget.showVideo && !widget.showVideo) {
      if (_betterPlayerController != null) {
        homeFeedVideoController.skippedToInitialDuartion = false;
        _betterPlayerController!.videoPlayerController!
            .removeListener(videoPlayerListener);
        homeFeedVideoController.reset();
        _betterPlayerController!.videoPlayerController?.dispose();
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
          enableFullscreen:
              true, //defaultTargetPlatform == TargetPlatform.android,
          enableSkips: true,
          enableMute: true),
      autoDetectFullscreenAspectRatio: false,
      deviceOrientationsOnFullScreen: const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp
      ],
      deviceOrientationsAfterFullScreen: const [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp
      ],
      autoDispose: false,
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
    homeFeedVideoController.changeControlsVisibility(
        _betterPlayerController!, false);
  }

  void _initVideo() async {
    setupVideo(widget.item!.videoV2M3U8(widget.appData!));
    if (videoSettingProvider.isMuted) {
      _betterPlayerController!.setVolume(0.0);
    }
    _betterPlayerController!.videoPlayerController!
        .addListener(videoPlayerListener);
  }

  void videoPlayerListener() {
    homeFeedVideoController.videoPlayerListener(
        _betterPlayerController, videoSettingProvider);
  }

  Widget listTile() {
    TextStyle titleStyle = TextStyle(color: Colors.white, fontSize: 13);
    Widget thumbnail = Selector<ImageResolution, String>(
        selector: (context, myType) => myType.resolution,
        builder: (context, value, child) {
          return CachedImage(
            imageUrl: Utilities.getProxyImage(value, widget.thumbUrl),
            imageHeight: 230,
            imageWidth: double.infinity,
          );
        });
    String timeInString =
        widget.createdAt != null ? "${timeago.format(widget.createdAt!)}" : "";
    return Stack(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Stack(
            children: [
              widget.showVideo && _betterPlayerController != null
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _videoPlayer(),
                        _thumbNailAndLoader(thumbnail),
                        _nextScreenGestureDetector(),
                        _videoSlider(),
                        _muteUnMuteButton(),
                        _fullScreenButton(),
                      ],
                    )
                  : thumbnail,
              _timer(),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 5, left: 13, right: 13),
            child: Row(
              crossAxisAlignment: isTitleOneLine(titleStyle)
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                InkWell(
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
                    _pushToUserScreen();
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          child: Row(
                            children: [
                              Text(
                                '${widget.author}',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          onTap: () {
                            widget.onUserTap();
                            _pushToUserScreen();
                          },
                        ),
                        Expanded(
                            child: Text(
                          '  •  $timeInString',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        )),
                        const SizedBox(
                          width: 15,
                        ),
                        UpvoteButton(
                          appData: widget.appData!,
                          item: widget.item!,
                          votes: widget.votes,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.5, left: 15),
                          child: Icon(
                            Icons.comment,
                            size: 14,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 1.0,
                          ),
                          child: Text(
                            '  ${widget.comments}',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                        // Padding(
                        //   padding:
                        //       const EdgeInsets.only(left: 10, top: 2.0, right: 5),
                        //   child: SizedBox(
                        //     height: 15,
                        //     width: 25,
                        //     child: FavouriteWidget(
                        //         alignment: Alignment.topCenter,
                        //         disablePadding: true,
                        //         iconSize: 15,
                        //         isLiked: favoriteProvider
                        //             .isLikedVideoPresentLocally(widget.item!),
                        //         onAdd: () {
                        //           favoriteProvider
                        //               .storeLikedVideoLocally(widget.item!);
                        //         },
                        //         onRemove: () {
                        //           favoriteProvider.storeLikedVideoLocally(
                        //               widget.item!,
                        //               forceRemove: true);
                        //           if (widget.onFavouriteRemoved != null)
                        //             widget.onFavouriteRemoved!();
                        //         },
                        //         toastType: 'Video'),
                        //   ),
                        // )
                      ],
                    ),
                  ],
                ))
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
              _pushToVideoDetailScreen();
            }
          },
        ),
      ],
    );
  }

  bool isTitleOneLine(
    TextStyle titleStyle,
  ) {
    return Utilities.textLines(widget.title, titleStyle,
            MediaQuery.of(context).size.width * 0.78, 2) ==
        1;
  }

  Positioned _nextScreenGestureDetector() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          _pushToVideoDetailScreen();
        },
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  void _pushToVideoDetailScreen() async {
    var screen = NewVideoDetailsScreen(
        betterPlayerController: _betterPlayerController,
        item: widget.item!,
        appData: widget.appData!);
    var route = MaterialPageRoute(builder: (context) => screen);
    homeFeedVideoController.isUserOnAnotherScreen = true;
    await Navigator.of(context).push(route);
    homeFeedVideoController.isUserOnAnotherScreen = false;
    if (widget.showVideo &&
        _betterPlayerController == null &&
        !homeFeedVideoController.isUserOnAnotherScreen) {
      setState(() {
        _initVideo();
      });
    }
  }

  void _pushToUserScreen() async {
    var screen = UserChannelScreen(owner: widget.author);
    var route = MaterialPageRoute(builder: (c) => screen);
    homeFeedVideoController.isUserOnAnotherScreen = true;
    await Navigator.of(context).push(route);
    homeFeedVideoController.isUserOnAnotherScreen = false;
    if (widget.showVideo &&
        _betterPlayerController == null &&
        !homeFeedVideoController.isUserOnAnotherScreen) {
      setState(() {
        _initVideo();
      });
    }
  }

  Positioned _fullScreenButton() {
    return Positioned(
        top: 5,
        left: 5,
        child: HomeFeedVideoFullScreenButton(
            betterPlayerController: _betterPlayerController!));
  }

  Positioned _timer() {
    return Positioned(
      bottom: 10,
      right: 10,
      child: HomeFeedVideoTimer(totalDuration: widget.duration!),
    );
  }

  Positioned _muteUnMuteButton() {
    return Positioned(
      right: 5,
      top: 5,
      child: MuteUnmuteButton(betterPlayerController: _betterPlayerController!),
    );
  }

  Positioned _videoSlider() {
    return Positioned(
      left: -3,
      right: -3,
      bottom: 0,
      child: HomeFeedVideoSlider(
        betterPlayerController: _betterPlayerController,
      ),
    );
  }

  Positioned _thumbNailAndLoader(Widget thumbnail) {
    return Positioned.fill(
      child: Selector<HomeFeedVideoController, bool>(
        selector: (_, myType) => myType.isInitialized,
        builder: (context, value, child) {
          return Visibility(visible: !value, child: child!);
        },
        child: Stack(
          children: [
            thumbnail,
            Positioned(
              bottom: 10,
              left: 10,
              child: SizedBox(
                height: 13,
                width: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Hero _videoPlayer() {
    return Hero(
      tag: '${widget.item?.author}/${widget.item?.permlink}',
      child: SizedBox(
        height: 230,
        child: BetterPlayer(
          controller: _betterPlayerController!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider.value(
        value: homeFeedVideoController, child: listTile());
  }

  @override
  bool get wantKeepAlive => homeFeedVideoController.currentDuration != null;
}
