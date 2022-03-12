import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/communities_models/request/community_details_request.dart';
import 'package:acela/src/models/communities_models/response/community_details_response_models.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/list_tile_video.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class CommunityDetailScreen extends StatefulWidget {
  const CommunityDetailScreen(
      {Key? key, required this.name, required this.title})
      : super(key: key);
  final String name;
  final String title;

  @override
  _CommunityDetailScreenState createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Tab> tabs = [
    Tab(text: 'About'),
    Tab(text: 'Videos'),
    Tab(text: 'Team')
  ];

  late Future<List<HomeFeedItem>> _loadingFeed;
  late Future<CommunityDetailsResponse> _details;

  Future<List<HomeFeedItem>> _loadHomeFeed() async {
    var uri =
        Uri.parse('https://3speak.tv/apiv2/feeds/community/${widget.name}/new');
    var response = await get(uri);
    if (response.statusCode == 200) {
      List<HomeFeedItem> list = homeFeedItemFromString(response.body);
      return list;
    } else {
      throw 'Status code ${response.statusCode}';
    }
  }

  Future<CommunityDetailsResponse> _loadDetails() async {
    var client = http.Client();
    var body = CommunityDetailsRequest.forName(widget.name).toJsonString();
    var response = await client.post(Uri.parse(server.hiveDomain), body: body);
    if (response.statusCode == 200) {
      return CommunityDetailsResponse.fromString(response.body);
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

  @override
  void initState() {
    super.initState();
    _loadingFeed = _loadHomeFeed();
    _details = _loadDetails();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void onTap(HomeFeedItem item) {
    var viewModel =
        VideoDetailsViewModel(author: item.author, permlink: item.permlink);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => VideoDetailsScreen(vm: viewModel)));
  }

  void onUserTap(HomeFeedItem item) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (c) => UserChannelScreen(owner: item.author)));
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
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
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
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _listTile(list[index], context, onTap, onUserTap);
          },
          separatorBuilder: (context, index) =>
              const Divider(thickness: 0, height: 1, color: Colors.transparent),
          itemCount: list.length,
        ));
  }

  Widget _screen() {
    return FutureBuilder(
      future: _loadingFeed,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          return RetryScreen(
              error: snapshot.error?.toString() ?? 'Something went wrong',
              onRetry: _loadHomeFeed);
        } else if (snapshot.hasData) {
          List<HomeFeedItem> items = snapshot.data! as List<HomeFeedItem>;
          return list(items, _loadHomeFeed, onTap, onUserTap);
        } else {
          return const LoadingScreen();
        }
      },
    );
  }

  String _generateMarkDown(CommunityDetailsResponse data) {
    return "## About:\n${data.result.about}\n\n## Information:\n${data.result.description}\n\n## Flags:\n${data.result.flagText}\n\n## Total Authors:\n${data.result.numAuthors}\n\n## Subscribers:\n${data.result.subscribers}\n\n## Pending Rewards:\n\$${data.result.sumPending}\n\n## Created At:\n${Utilities.parseAndFormatDateTime(data.result.createdAt)}";
  }

  Widget _descriptionMarkDown(String markDown) {
    return Markdown(
      data: Utilities.removeAllHtmlTags(markDown),
      onTapLink: (text, url, title) {
        launch(url!);
      },
    );
  }

  Widget _about() {
    return FutureBuilder(
      future: _details,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          return RetryScreen(
              error: snapshot.error?.toString() ?? 'Something went wrong',
              onRetry: _loadDetails);
        } else if (snapshot.hasData) {
          CommunityDetailsResponse data =
              snapshot.data! as CommunityDetailsResponse;
          return _descriptionMarkDown(_generateMarkDown(data));
        } else {
          return const LoadingScreen();
        }
      },
    );
  }

  Widget _team() {
    return FutureBuilder(
      future: _details,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          return RetryScreen(
              error: snapshot.error?.toString() ?? 'Something went wrong',
              onRetry: _loadDetails);
        } else if (snapshot.hasData) {
          CommunityDetailsResponse data =
              snapshot.data! as CommunityDetailsResponse;
          return ListView.separated(
            itemBuilder: (context, index) {
              return ListTile(
                leading: CustomCircleAvatar(
                  height: 40,
                  width: 40,
                  url: server.userOwnerThumb(data.result.team[index][0]),
                ),
                title: Text(data.result.team[index][0]),
                subtitle: Text(data.result.team[index][1]),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: data.result.team.length,
          );
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
        title: Row(
          children: [
            CustomCircleAvatar(
              height: 40,
              width: 40,
              url: server.communityIcon(widget.name),
            ),
            const SizedBox(width: 10),
            Text(widget.title)
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _about(),
          _screen(),
          _team(),
        ],
      ),
    );
  }
}
