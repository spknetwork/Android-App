import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/stories/stories_feed_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/video_details_screen/video_details_comments.dart';
import 'package:acela/src/screens/video_details_screen/video_details_info.dart';
import 'package:acela/src/widgets/fab_custom.dart';
import 'package:acela/src/widgets/fab_overlay.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/story_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class StoriesFeedScreen extends StatefulWidget {
  const StoriesFeedScreen({
    Key? key,
    required this.type,
    required this.height,
    required this.fitWidth,
  }) : super(key: key);
  final String type;
  final double height;
  final bool fitWidth;

  @override
  State<StoriesFeedScreen> createState() => _StoriesFeedScreenState();
}

class _StoriesFeedScreenState extends State<StoriesFeedScreen> {
  List<StoriesFeedResponseItem> items = [];
  var isLoading = false;
  var initialPage = 0;
  CarouselController controller = CarouselController();
  bool isFilterMenuOn = false;

  @override
  void initState() {
    super.initState();
    loadData(0);
  }

  void loadData(int length) async {
    setState(() {
      isLoading = true;
    });
    var string = '${server.domain}/api/${widget.type}/more?skip=$length';
    var response = await get(Uri.parse(string));
    if (response.statusCode == 200) {
      List<StoriesFeedResponseItem> list =
          StoriesFeedResponseItem().fromJsonString(response.body, widget.type);
      setState(() {
        isLoading = false;
        items = items +
            list
                .where((element) =>
                    element.duration <= 90 || element.isReel == true)
                .toList();
        var permlinks = Set<String>();
        items.retainWhere((x) => permlinks.add(x.permlink));
        if (items.length < 15) {
          loadData(length + list.length);
        }
      });
    } else {
      showError('Status code ${response.statusCode}');
      setState(() {
        isLoading = false;
        items = [];
      });
    }
  }

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showMessage(String string) {
    var snackBar = SnackBar(content: Text(string));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget loadingData() {
    return const LoadingScreen(
      title: 'Loading Data',
      subtitle: 'Please wait',
    );
  }

  List<FabOverItemData> _fabItems(
      StoriesFeedResponseItem item, HiveUserData data) {
    List<FabOverItemData> fabItems = [
      FabOverItemData(
        displayName: 'Share',
        icon: Icons.share,
        onTap: () {
          setState(() {
            isFilterMenuOn = false;
            Share.share(
                'https://3speak.tv/watch?v=${item.owner}/${item.permlink}');
          });
        },
      ),
      FabOverItemData(
        displayName: 'Info',
        icon: Icons.info,
        onTap: () {
          setState(() {
            isFilterMenuOn = false;
            var screen = VideoDetailsInfoWidget(details: null, item: item);
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).push(route);
          });
        },
      ),
      FabOverItemData(
        displayName: 'Comments',
        icon: Icons.comment,
        onTap: () {
          setState(() {
            isFilterMenuOn = false;
            var screen = VideoDetailsComments(
              author: item.owner,
              permlink: item.permlink,
              rpc: data.rpc,
            );
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).push(route);
          });
        },
      ),
      FabOverItemData(
        displayName: 'Close',
        icon: Icons.close,
        onTap: () {
          setState(() {
            isFilterMenuOn = false;
          });
        },
      ),
    ];
    return fabItems;
  }

  Widget _fabContainer(StoriesFeedResponseItem item, HiveUserData data) {
    if (!isFilterMenuOn) {
      return FabCustom(
        icon: Icons.bolt,
        onTap: () {
          setState(() {
            isFilterMenuOn = true;
          });
        },
      );
    }
    return FabOverlay(
      items: _fabItems(item, data),
      onBackgroundTap: () {
        setState(() {
          isFilterMenuOn = false;
        });
      },
    );
  }

  Widget _fullPost(StoriesFeedResponseItem item, HiveUserData data) {
    return Stack(
      children: [
        StoryPlayer(
          playUrl: item.getVideoUrl(data),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - widget.height,
          fitWidth: widget.fitWidth,
          didFinish: () {
            setState(() {
              controller.nextPage();
            });
          },
        ),
        Container(
          child: Row(
            children: [
              const Spacer(),
              Text(
                '@${item.owner}/${item.permlink}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
            ],
          ),
        ),
        _fabContainer(item, data),
      ],
    );
  }

  Widget carousel(HiveUserData data) {
    return SafeArea(
      child: Container(
        child: CarouselSlider(
          carouselController: controller,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            enableInfiniteScroll: true,
            viewportFraction: 1,
            scrollDirection: Axis.vertical,
          ),
          items: items.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return _fullPost(item, data);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<HiveUserData>(context);
    return isLoading ? loadingData() : carousel(userData);
  }
}
