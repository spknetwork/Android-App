import 'dart:developer';

import 'package:acela/src/models/hive_comments/new_hive_comment/newest_comment_model.dart';
import 'package:acela/src/utils/enum.dart';
import 'package:acela/src/utils/graphql/gql_communicator.dart';
import 'package:flutter/material.dart';

class CommentController extends ChangeNotifier {
  final GQLCommunicator _gqlCommunicator = GQLCommunicator();
  ViewState viewState = ViewState.loading;
  List<CommentItemModel> disPlayedItems = [];
  List<CommentItemModel> items = [];
  bool _commentHighlighterTrigger = false;

  bool get commentHighlighterTrigger => _commentHighlighterTrigger;

  set commentHighlighterTrigger(value) {
    _commentHighlighterTrigger = value;
    notifyListeners();
  }

  int? animateToCommentIndex = null;

  final String author;
  final String permlink;

  CommentController({required this.author, required this.permlink}) {
    _init();
  }

  void _init() async {
    try {
      disPlayedItems = [
        ...await _gqlCommunicator.getComments(author, permlink)
      ];
      disPlayedItems = refactorComments(disPlayedItems, permlink);
      items = disPlayedItems;
      if (disPlayedItems.isEmpty) {
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

  void addTopLevelComment(CommentItemModel comment, String searchKey) {
    if (viewState == ViewState.empty) {
      viewState = ViewState.data;
    }
    items = [
      comment,
      ...items,
    ];
    items = refactorComments(items, permlink);
    if (searchKey.isEmpty) {
      disPlayedItems = items;
    } else {
      animateToCommentIndex = 0;
      if (_isSearchedKeyPresent(comment, searchKey)) {
        disPlayedItems = [comment, ...disPlayedItems];
      }
    }
    notifyListeners();
  }

  void addSubLevelComment(
      CommentItemModel comment, int index, String searchKey) {
    if (searchKey.isNotEmpty) {
      var item = disPlayedItems[index];
      var newIndex = items.indexWhere((element) => element == item);
      if (newIndex != -1) {
        items[newIndex] =
            items[newIndex].copyWith(children: items[newIndex].children + 1);
        items = [...items, comment];
        items = refactorComments(items, permlink);
        animateToCommentIndex = newIndex + 1;
        if (_isSearchedKeyPresent(comment, searchKey)) {
          disPlayedItems = [comment, ...disPlayedItems];
        }
      }
    } else {
      disPlayedItems[index] = disPlayedItems[index]
          .copyWith(children: disPlayedItems[index].children + 1);
      disPlayedItems = [...disPlayedItems, comment];
      disPlayedItems = refactorComments(disPlayedItems, permlink);
      items = disPlayedItems;
    }
    notifyListeners();
  }

  void onUpvote(
      CommentItemModel comment, int index, String userName, String searchKey) {
    CommentItemModel mutatedComment = comment.copyWith(activeVotes: [
      ...comment.activeVotes,
      CommentActiveVote(voter: userName)
    ]);
    if (comment.stats != null) {
      mutatedComment = mutatedComment.copyWith(
          stats: mutatedComment.stats!.copyWith(
              totalVotes: (mutatedComment.stats!.totalVotes ?? 0) + 1));
    }

    if (searchKey.isNotEmpty) {
      var item = disPlayedItems[index];
      disPlayedItems[index] = mutatedComment;
      var newIndex = items.indexWhere((element) => element == item);
      if (newIndex != -1) {
        items[newIndex] = mutatedComment;
      }
    } else {
      disPlayedItems[index] = mutatedComment;
      items = disPlayedItems;
    }

    notifyListeners();
  }

  void refreshSilently() async {
    viewState = ViewState.loading;
    notifyListeners();
    _init();
  }

  static List<CommentItemModel> refactorComments(
      List<CommentItemModel> content, String parentPermlink) {
    List<CommentItemModel> refactoredComments = [];
    var newContent = List<CommentItemModel>.from(content);
    for (var e in newContent) {
      e.visited = false;
    }
    newContent.sort((a, b) {
      var bTime = b.created;
      var aTime = a.created;
      if (aTime.isAfter(bTime)) {
        return -1;
      } else if (bTime.isAfter(aTime)) {
        return 1;
      } else {
        return 0;
      }
    });
    refactoredComments.addAll(
        newContent.where((e) => e.parentPermlink == parentPermlink).toList());
    while (refactoredComments.where((e) => e.visited == false).isNotEmpty) {
      var firstComment =
          refactoredComments.where((e) => e.visited == false).first;
      var indexOfFirstElement = refactoredComments.indexOf(firstComment);
      if (firstComment.children != 0) {
        List<CommentItemModel> children = newContent
            .where((e) => e.parentPermlink == firstComment.permlink)
            .toList();
        children.sort((a, b) {
          var aTime = a.created;
          var bTime = b.created;
          if (aTime.isAfter(bTime)) {
            return -1;
          } else if (bTime.isAfter(aTime)) {
            return 1;
          } else {
            return 0;
          }
        });
        refactoredComments.insertAll(indexOfFirstElement + 1, children);
      }
      firstComment.visited = true;
    }
    log('Returning ${refactoredComments.length} elements');
    return refactoredComments;
  }

  void onSearch(String keyword) {
    Set<CommentItemModel> data = {};
    if (keyword.isNotEmpty) {
      for (CommentItemModel item in items) {
        if (_isSearchedKeyPresent(item, keyword)) {
          data.add(item);
        }
      }
      disPlayedItems = data.toList();
      notifyListeners();
    } else {
      disPlayedItems = items;
      notifyListeners();
    }
  }

  bool _isSearchedKeyPresent(CommentItemModel item, String keyword) {
    if (item.body.toLowerCase().contains(keyword.toLowerCase())) {
      return true;
    }
    if (item.author.toLowerCase().contains(keyword.toLowerCase())) {
      return true;
    }
    return false;
  }
}
