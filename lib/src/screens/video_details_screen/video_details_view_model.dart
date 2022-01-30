import 'dart:convert';

import 'package:acela/src/models/hive_comments/request/hive_comments_request.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';
import 'package:acela/src/models/video_details_model/video_details_description.dart';
import 'package:http/http.dart' show get;
import 'package:http/http.dart' as http;
import 'package:acela/src/bloc/server.dart';

class VideoDetailsViewModel {
  HomeFeed item;
  List<HiveComment> list = [];

  VideoDetailsViewModel({required this.item});

  Future<String> loadVideoInfo() async {
    final endPoint = "${server.domain}/apiv2/@${item.owner}/${item.permlink}";
    final response = await get(Uri.parse(endPoint));
    if (response.statusCode == 200) {
      VideoDetailsDescription desc =
      videoDetailsDescriptionFromJson(response.body);
      return desc.description;
    } else {
      throw 'Something went wrong.\nStatus code is ${response.statusCode} for $endPoint';
    }
  }

  Future<void> loadComments(String author, String permlink) async {
    var client = http.Client();
    var request = http.Request('POST', Uri.parse(server.hiveDomain));
    request.body =
        hiveCommentsRequestToJson(HiveCommentsRequest.from(author, permlink));
    client
        .send(request)
        .then((response) => response.stream.bytesToString())
        .then((value) {
      HiveComments hiveComments = hiveCommentsFromJson(value);
      list = hiveComments.result;
      scanComments();
      return;
    }).catchError((error) {
      throw error.toString();
    });
  }

  Future<void> childrenComments(String author, String permlink, int index) async {
    var client = http.Client();
    var request = http.Request('POST', Uri.parse(server.hiveDomain));
    request.body =
        hiveCommentsRequestToJson(HiveCommentsRequest.from(author, permlink));
    client
        .send(request)
        .then((response) => response.stream.bytesToString())
        .then((value) {
      HiveComments hiveComments = hiveCommentsFromJson(value);
      list.insertAll(index + 1, hiveComments.result);
      scanComments();
      return;
    }).catchError((error) {
      throw error.toString();
    });
  }

  Future<void> scanComments() async {
    for(var i=0; i < list.length; i++) {
      if (list[i].children > 0) {
        if (list.where((e) => e.parentPermlink == list[i].permlink).isEmpty) {
          await childrenComments(list[i].author, list[i].permlink, i);
          break;
        }
      }
    }
  }
}
