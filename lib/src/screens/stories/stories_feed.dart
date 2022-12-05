import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/story_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class StoriesFeedScreen extends StatefulWidget {
  const StoriesFeedScreen({Key? key, required this.type, required this.height})
      : super(key: key);
  final String type;
  final double height;

  @override
  State<StoriesFeedScreen> createState() => _StoriesFeedScreenState();
}

class _StoriesFeedScreenState extends State<StoriesFeedScreen> {
  List<HomeFeedItem> items = [];
  var isLoading = false;
  var initialPage = 0;
  CarouselController controller = CarouselController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    var response = await get(
        Uri.parse('${server.domain}/apiv2/feeds/${widget.type}?isReel=true'));
    if (response.statusCode == 200) {
      List<HomeFeedItem> list = homeFeedItemFromString(response.body);
      setState(() {
        isLoading = false;
        items = list.where((element) => element.duration <= 90).toList();
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

  Widget _fullPost(HomeFeedItem item, HiveUserData data) {
    return Stack(
      children: [
        StoryPlayer(
          playUrl: item.getVideoUrl(data),
          thumbnail: item.images.thumbnail,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - widget.height,
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
                '@${item.author}/${item.permlink}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
            ],
          ),
        )
      ],
    );
  }

  Widget carousel(HiveUserData data) {
    return Container(
      child: CarouselSlider(
        carouselController: controller,
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          enableInfiniteScroll: false,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<HiveUserData>(context);
    return isLoading ? loadingData() : carousel(userData);
  }
}
