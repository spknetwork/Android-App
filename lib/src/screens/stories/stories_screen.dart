import 'dart:io';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/story_player.dart';
import 'package:acela/src/widgets/story_player_android.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  List<HomeFeedItem> items = [];
  var isLoading = false;
  // Map<String, PayoutInfo?> payout = {};
  // var isFabLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    var response =
        await get(Uri.parse('${server.domain}/apiv2/feeds/trending'));
    if (response.statusCode == 200) {
      List<HomeFeedItem> list = homeFeedItemFromString(response.body);
      setState(() {
        isLoading = false;
        items = list;
      });
      // var i = 0;
      // while (i < list.length) {
      //   if (mounted) {
      //     var info = await Communicator()
      //         .fetchHiveInfo(list[i].author, list[i].permlink);
      //     setState(() {
      //       payout["${list[i].author}/${list[i].permlink}"] = info;
      //       i++;
      //     });
      //   } else {
      //     break;
      //   }
      // }
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
    var snackBar = SnackBar(content: Text('Message: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget loadingData() {
    return const LoadingScreen(
      title: 'Loading Data',
      subtitle: 'Please wait',
    );
  }

  Widget _fullPost(HomeFeedItem item, HiveUserData data) {
    return Platform.isAndroid
        ? StoryPlayerAndroid(
            playUrl: item.getVideoUrl(data),
            thumbnail: item.images.thumbnail,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          )
        : StoryPlayer(
            playUrl: item.getVideoUrl(data),
            thumbnail: item.images.thumbnail,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          );
  }

  Widget carousel(HiveUserData data) {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          enableInfiniteScroll: false,
          viewportFraction: 1,
          scrollDirection: Axis.vertical,
          // enlargeCenterPage: true,
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
    return Scaffold(
      body: isLoading ? loadingData() : carousel(userData),
    );
  }
}
