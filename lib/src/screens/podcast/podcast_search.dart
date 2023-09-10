import 'dart:async';

import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/podcasts_feed.dart';
import 'package:acela/src/utils/podcast/podcast_communicator.dart';
import 'package:flutter/material.dart';

class PodCastSearch extends StatefulWidget {
  const PodCastSearch({Key? key,
    required this.appData,
  });

  final HiveUserData appData;

  @override
  State<PodCastSearch> createState() => _PodCastSearchState();
}

class _PodCastSearchState extends State<PodCastSearch> {
  var text = '';
  late TextEditingController _controller;
  Timer? _timer;
  var loading = false;
  List<PodCastFeedItem> items = [];

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

  void search(String term) async {
    setState(() {
      loading = true;
      items = [];
    });
    var result = await PodCastCommunicator().getSearchResults(term);
    setState(() {
      loading = false;
      items = result.feeds ?? [];
    });
  }

  Widget getList() {
    return ListView.separated(
      itemBuilder: (c, i) {
        var title = items[i].title ?? 'No title';
        // title = "$title by ${items[i].author ?? ''}";
        var desc = ''; // items[i].description ?? '';
        desc = "$desc${(items[i].categories?.values ?? []).join(", ")}";
        return ListTile(
          dense: true,
          leading: Image.network(items[i].image ?? ''),
          title: Text(title),
          subtitle: Text(desc),
          onTap: () {
            var screen =
            PodcastFeedScreen(appData: widget.appData, item: items[i]);
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).push(route);
          },
        );
      },
      separatorBuilder: (c, i) => const Divider(height: 0),
      itemCount: items.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: (value) {
            var timer = Timer(const Duration(seconds: 2), () {
              if (value.trim().length > 3) {
                var searchTerm = value.trim();
                search(searchTerm);
              }
            });
            setState(() {
              _timer?.cancel();
              _timer = timer;
            });
          },
        ),
      ),
      body: loading ? Center(child: CircularProgressIndicator()) : getList(),
    );
  }
}
