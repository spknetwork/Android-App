import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/search/search_response_models.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/widgets/list_tile_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var text = '';
  late TextEditingController _controller;
  Timer? _timer;
  List<SearchResponseResultsItem> results = [];
  var loading = false;
  Map<String, PayoutInfo?> payout = {};

  Future<void> search(String term, HiveUserData appData) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': dotenv.env['HIVE_SEARCHER_AUTH_KEY'] ?? ''
    };
    var request =
        http.Request('POST', Uri.parse('https://api.hivesearcher.com/search'));
    request.body =
        json.encode({"q": "$term Watch on 3speak type:post", "sort": "newest"});
    request.headers.addAll(headers);
    setState(() {
      loading = true;
    });
    http.StreamedResponse response = await request.send();
    setState(() {
      loading = false;
    });
    if (response.statusCode == 200) {
      var result = SearchResponseModels.fromJsonString(
          await response.stream.bytesToString());
      setState(() {
        results = result.results;
      });
      var i = 0;
      Timer.periodic(const Duration(seconds: 1), (timer) {
        fetchHiveInfo(results[i].author, results[i].permlink, appData.rpc);
        i += 1;
        if (i == results.length) {
          timer.cancel();
        }
      });
    } else {
      log(response.reasonPhrase.toString());
      setState(() {
        results = [];
      });
    }
  }

  // fetch hive info
  void fetchHiveInfo(String user, String permlink, String hiveApiUrl) async {
    var request = http.Request('POST', Uri.parse('https://$hiveApiUrl'));
    request.body = json.encode({
      "id": 1,
      "jsonrpc": "2.0",
      "method": "bridge.get_discussion",
      "params": {"author": user, "permlink": permlink, "observer": ""}
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var result = HivePostInfo.fromJsonString(string)
          .result
          .resultData
          .where((element) => element.permlink == permlink)
          .first;
      setState(() {
        var upVotes = result.activeVotes.where((e) => e.rshares > 0).length;
        var downVotes = result.activeVotes.where((e) => e.rshares < 0).length;
        payout["$user/$permlink"] = PayoutInfo(
          payout: result.payout,
          downVotes: downVotes,
          upVotes: upVotes,
        );
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  PreferredSizeWidget _appBar(HiveUserData appData) {
    return AppBar(
      title: TextField(
        controller: _controller,
        onChanged: (value) {
          var timer = Timer(const Duration(seconds: 2), () {
            log('Text changed to $value');
            if (value.trim().length > 3) {
              search(value.trim(), appData);
            }
          });
          setState(() {
            _timer?.cancel();
            _timer = timer;
          });
        },
      ),
    );
  }

  Widget _searchResultListItem(SearchResponseResultsItem item) {
    var created = DateTime.tryParse(item.createdAt);
    String timeInString =
        created != null ? "📆 ${timeago.format(created)}" : "";
    // double? payoutAmount = payout["${item.author}/${item.permlink}"]?.payout;
    // int? upVotes = payout["${item.author}/${item.permlink}"]?.upVotes;
    // int? downVotes = payout["${item.author}/${item.permlink}"]?.downVotes;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      title: ListTileVideo(
        placeholder: 'assets/branding/three_speak_logo.png',
        url: item.imgUrl,
        userThumbUrl: server.userOwnerThumb(item.author),
        title: item.title,
        subtitle: "$timeInString ",
        isAlternate: false,
        onUserTap: () {
          var channel = UserChannelScreen(owner: item.author);
          var route = MaterialPageRoute(builder: (_) => channel);
          Navigator.of(context).push(route);
        },
        user: item.author,
        permlink: item.permlink,
        shouldResize: false,
        isIpfs: false,
      ),
      onTap: () {
        var vm =
            VideoDetailsViewModel(author: item.author, permlink: item.permlink);
        var details = VideoDetailsScreen(vm: vm);
        var route = MaterialPageRoute(builder: (_) => details);
        Navigator.of(context).push(route);
      },
    );
  }

  Widget _searchResultListView() {
    if (results.isEmpty && !loading) {
      return const Center(
        child: Text('No search result found'),
      );
    } else if (loading) {
      return const Center(
        child: Text('Loading search results....'),
      );
    }
    return ListView.separated(
        itemBuilder: (context, index) {
          return _searchResultListItem(results[index]);
        },
        separatorBuilder: (_, index) =>
            const Divider(thickness: 0, height: 15, color: Colors.transparent),
        itemCount: results.length);
  }

  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<HiveUserData>(context);
    return Scaffold(
      appBar: _appBar(appData),
      body: _searchResultListView(),
    );
  }
}
