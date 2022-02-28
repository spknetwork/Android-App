import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/list_tile_video.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommunityDetailScreen extends StatefulWidget {
  const CommunityDetailScreen({Key? key, required this.name, required this.title}) : super(key: key);
  final String name;
  final String title;

  @override
  _CommunityDetailScreenState createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  late Future<List<HomeFeedItem>> _loadingFeed;

  Future<List<HomeFeedItem>> loadHomeFeed() async {
    var uri = Uri.parse(
        'https://3speak.tv/apiv2/feeds/community/${widget.name}/new');
    var response = await get(uri);
    if (response.statusCode == 200) {
      List<HomeFeedItem> list = homeFeedItemFromString(response.body);
      return list;
    } else {
      throw 'Status code ${response.statusCode}';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadingFeed = loadHomeFeed();
  }

  void onTap(HomeFeedItem item) {
    Navigator.of(context)
        .pushNamed(VideoDetailsScreen.routeName(item.author, item.permlink));
  }

  void onUserTap(HomeFeedItem item) {
    Navigator.of(context).pushNamed("/userChannel/${item.author}");
  }

  Widget _tileTitle(HomeFeedItem item, BuildContext context,
      Function(HomeFeedItem) onUserTap) {
    String timeInString =
    item.createdAt != null ? "📆 ${timeago.format(item.createdAt!)}" : "";
    String owner = "👤 ${item.author}";
    String duration = "🕚 ${Utilities.formatTime(item.duration.toInt())}";
    String views = "▶ ${item.views}";
    return ListTileVideo(
      placeholder: 'assets/branding/three_speak_logo.png',
      url: item.images.thumbnail,
      userThumbUrl: server.userOwnerThumb(item.author),
      title: item.title,
      subtitle: "$timeInString $owner $duration $views",
      onUserTap: () {
        onUserTap(item);
      },
    );
  }

  Widget _listTile(HomeFeedItem item, BuildContext context,
      Function(HomeFeedItem) onTap, Function(HomeFeedItem) onUserTap) {
    return ListTile(
      title: _tileTitle(item, context, onUserTap),
      onTap: () {
        onTap(item);
      },
    );
  }

  Widget list(List<HomeFeedItem> list, Future<void> Function() onRefresh,
      Function(HomeFeedItem) onTap, Function(HomeFeedItem) onUserTap) {
    return RefreshIndicator(
        onRefresh: onRefresh,
        child:ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _listTile(list[index], context, onTap, onUserTap);
          },
          separatorBuilder: (context, index) => const Divider(
              thickness: 0, height: 1, color: Colors.transparent),
          itemCount: list.length,
        )
    );
  }

  Widget _screen() {
    return FutureBuilder(
      future: _loadingFeed,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          return RetryScreen(
              error: snapshot.error?.toString() ?? 'Something went wrong',
              onRetry: loadHomeFeed);
        } else if (snapshot.hasData) {
          List<HomeFeedItem> items = snapshot.data! as List<HomeFeedItem>;
          return list(items, loadHomeFeed, onTap, onUserTap);
        } else {
          return const LoadingScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _screen(),
    );
  }
}
