import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class NewVideoDetailScreenNavigationParameter {
  final BetterPlayerController? betterPlayerController;
  final GQLFeedItem? item;
  final VoidCallback? onPop;

  NewVideoDetailScreenNavigationParameter(
      {this.betterPlayerController, this.item,this.onPop});
}
