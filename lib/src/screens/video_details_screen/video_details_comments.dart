import 'package:acela/src/models/hive_comments/new_hive_comment/new_hive_comment.dart';
import 'package:acela/src/screens/video_details_screen/hive_comment.dart';
import 'package:acela/src/utils/graphql/gql_communicator.dart';
import 'package:flutter/material.dart';

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
  late Future<List<VideoCommentModel>> _loadComments;

  Future<List<VideoCommentModel>> loadComments(String author, String permlink) async {
      return await GQLCommunicator.getHiveComments(author,permlink);
    
  }

  @override
  void initState() {
    super.initState();
    _loadComments = loadComments(widget.author, widget.permlink);
  }

  Widget commentsListView(List<VideoCommentModel> data) {
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
          var data = snapshot.data! as List<VideoCommentModel>;
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
