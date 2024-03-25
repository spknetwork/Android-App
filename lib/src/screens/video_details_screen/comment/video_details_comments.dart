import 'package:acela/src/models/hive_comments/new_hive_comment/newest_comment_model.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/login/ha_login_screen.dart';
import 'package:acela/src/screens/video_details_screen/comment/controller/comment_controller.dart';
import 'package:acela/src/screens/video_details_screen/comment/hive_comment.dart';
import 'package:acela/src/screens/video_details_screen/comment/hive_comment_dialog.dart';
import 'package:acela/src/utils/enum.dart';
import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoDetailsComments extends StatefulWidget {
  const VideoDetailsComments({
    Key? key,
    required this.author,
    required this.permlink,
    required this.rpc,
    required this.item,
    required this.appData,
  }) : super(key: key);
  final String author;
  final String permlink;
  final String rpc;
  final GQLFeedItem item;
  final HiveUserData appData;

  @override
  State<VideoDetailsComments> createState() => _VideoDetailsCommentsState();
}

class _VideoDetailsCommentsState extends State<VideoDetailsComments> {
  @override
  void initState() {
    super.initState();
  }

  Widget commentsListView(CommentController controller) {
    return Selector<CommentController, List<CommentItemModel>>(
      shouldRebuild: (previous, next) => true,
      selector: (_, myType) => myType.items,
      builder: (context, items, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final CommentItemModel item = items[index];
                    return HiveCommentWidget(
                      key: ValueKey('${item.author}/${item.permlink}'),
                      comment: item,index: index,);
                  },
                  separatorBuilder: (context, index) {
                    bool commentDividerVisibility = true;
                    commentDividerVisibility = _commentDividerVisibility(
                        index, items, commentDividerVisibility);
                    return Visibility(
                      visible: commentDividerVisibility,
                      child: const Divider(
                        height: 10,
                        color: Colors.blueGrey,
                      ),
                    );
                  },
                  itemCount: items.length,
                ),
              ),
            ),
            _addCommentButton(controller),
          ],
        );
      },
    );
  }

  bool _commentDividerVisibility(
      int index, List<CommentItemModel> items, bool drawLine) {
    if (index + 1 < items.length) {
      if ((items[index + 1].depth == 1)) {
        drawLine = true;
      } else {
        drawLine = false;
      }
    }
    return drawLine;
  }

  Widget _addCommentButton(CommentController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
      child: SizedBox(
        height: 35,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(4),
              ),
            ),
          ),
          onPressed: () => commentPressed(controller),
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: Text(
            "Add a Comment",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void commentPressed(CommentController controller) {
    if (widget.appData.username == null) {
      showAdaptiveActionSheet(
        context: context,
        title: const Text('You are not logged in. Please log in to comment.'),
        androidBorderRadius: 30,
        actions: [
          BottomSheetAction(
              title: Text('Log in'),
              leading: Icon(Icons.login),
              onPressed: (c) {
                Navigator.of(c).pop();
                var screen = HiveAuthLoginScreen(appData: widget.appData);
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(c).push(route);
              }),
        ],
        cancelAction: CancelAction(title: const Text('Cancel')),
      );
      return;
    }
    var screen = HiveCommentDialog(
      author: widget.item.author?.username ?? 'sagarkothari88',
      permlink: widget.item.permlink ?? 'ctbtwcxbbd',
      username: widget.appData.username ?? "",
      hasKey: widget.appData.keychainData?.hasId ?? "",
      hasAuthKey: widget.appData.keychainData?.hasAuthKey ?? "",
      onClose: () {},
      onDone: (newComment) async {
        if (newComment != null) {
          controller.addTopLevelComment(newComment);
        }
      },
    );
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) =>
            CommentController(author: widget.author, permlink: widget.permlink),
        builder: (context, child) {
          final controller = context.read<CommentController>();
          return Selector<CommentController, ViewState>(
            selector: (_, myType) => myType.viewState,
            builder: (context, state, child) {
              return Scaffold(
                appBar: AppBar(
                    title: Selector<CommentController, int>(
                  selector: (_, myType) => myType.items.length,
                  builder: (context, numberOfComments, child) {
                    return Text(
                        'Comments${state != ViewState.loading ? ' ($numberOfComments)' : ''}');
                  },
                )),
                body: _body(state, controller),
              );
            },
          );
        });
  }

  Widget _body(ViewState state, CommentController controller) {
    if (state == ViewState.data) {
      return commentsListView(controller);
    } else if (state == ViewState.empty) {
      return Center(
        child: Text("No comments found"),
      );
    } else if (state == ViewState.error) {
      return Container(
          margin: const EdgeInsets.all(10),
          child: Text("Sorry, something went wrong"));
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(child: CircularProgressIndicator(value: null)),
            SizedBox(height: 20),
            Text('Loading comments'),
          ],
        ),
      );
    }
  }
}
