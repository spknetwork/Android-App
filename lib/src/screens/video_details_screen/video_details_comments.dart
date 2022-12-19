import 'package:acela/src/models/hive_comments/request/hive_comment_request.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/screens/video_details_screen/hive_comment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VideoDetailsComments extends StatefulWidget {
  const VideoDetailsComments({
    Key? key,
    required this.author,
    required this.permlink,
    required this.rpc,
  }) : super(key: key);
  final String author;
  final String permlink;
  final String rpc;

  @override
  State<VideoDetailsComments> createState() => _VideoDetailsCommentsState();
}

class _VideoDetailsCommentsState extends State<VideoDetailsComments> {
  late Future<List<HiveComment>> _loadComments;

  Future<List<HiveComment>> loadComments(String author, String permlink) async {
    var client = http.Client();
    var body =
        hiveCommentRequestToJson(HiveCommentRequest.from([author, permlink]));
    var rpc = 'https://${widget.rpc}';
    var response = await client.post(Uri.parse(rpc), body: body);
    if (response.statusCode == 200) {
      var hiveCommentsResponse = hiveCommentsFromString(response.body);
      var comments = hiveCommentsResponse.result;
      for (var i = 0; i < comments.length; i++) {
        if (comments[i].children > 0) {
          if (comments
              .where((e) => e.parentPermlink == comments[i].permlink)
              .isEmpty) {
            var newComments =
                await loadComments(comments[i].author, comments[i].permlink);
            comments.insertAll(i + 1, newComments);
          }
        }
      }
      return comments;
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

  @override
  void initState() {
    super.initState();
    _loadComments = loadComments(widget.author, widget.permlink);
  }

  Widget commentsListView(List<HiveComment> data) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListView.separated(
        itemBuilder: (context, index) {
          return HiveCommentWidget(comment: data[index]);
        },
        separatorBuilder: (context, index) => const Divider(
          height: 10,
          color: Colors.blueGrey,
        ),
        itemCount: data.length,
      ),
    );
  }

  Widget _container(Widget body, int? count) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments${count != null ? ' ($count)' : ''}'),
      ),
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadComments,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          String text =
              'Something went wrong while loading video comments - ${snapshot.error?.toString() ?? ""}';
          return _container(
              Container(margin: const EdgeInsets.all(10), child: Text(text)),
              null);
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data! as List<HiveComment>;
          return _container(commentsListView(data), data.length);
        } else {
          return _container(
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Spacer(),
                    SizedBox(child: CircularProgressIndicator(value: null)),
                    SizedBox(height: 10),
                    Text('Loading comments'),
                    Spacer(),
                  ],
                ),
              ),
              null);
        }
      },
    );
  }
}
