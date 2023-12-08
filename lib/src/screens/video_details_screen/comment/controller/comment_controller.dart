import 'package:acela/src/models/hive_comments/new_hive_comment/new_hive_comment.dart';
import 'package:acela/src/utils/enum.dart';
import 'package:acela/src/utils/graphql/gql_communicator.dart';
import 'package:flutter/material.dart';

class CommentController extends ChangeNotifier {
  final GQLCommunicator _gqlCommunicator = GQLCommunicator();
  ViewState viewState = ViewState.loading;
  List<VideoCommentModel> items = [];

  final String author;
  final String permlink;

  CommentController({required this.author, required this.permlink}) {
    _init();
  }

  void _init() async {
    try {
      items = [...await _gqlCommunicator.getHiveComments(author, permlink)];
      if (items.isEmpty) {
        viewState = ViewState.empty;
      } else {
        viewState = ViewState.data;
      }
      notifyListeners();
    } catch (e) {
      viewState = ViewState.error;
      notifyListeners();
    }
  }

  void addComment(VideoCommentModel comment) {
    items = [...items, comment];
    notifyListeners();
  }

  void onUpvote(VideoCommentModel comment, int index) {
    items[index] = comment.copyWith(numVotes: comment.stats!.numVotes! + 1);
    notifyListeners();
  }

  void refreshSilently() async {
    viewState = ViewState.loading;
    notifyListeners();
    _init();
  }
}
