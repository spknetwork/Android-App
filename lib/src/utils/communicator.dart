import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/login/memo_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/models/video_upload/video_upload_complete_request.dart';
import 'package:acela/src/models/video_upload/video_upload_login_response.dart';
import 'package:acela/src/models/video_upload/video_upload_prepare_response.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Communicator {
  // static const tsServer = "http://localhost:13050";
  static const tsServer = "http://10.0.2.2:13050";

  // static const fsServer = "https://uploads.3speak.tv/files";
  static const fsServer = "http://10.0.2.2:1080/files";

  Future<PayoutInfo> fetchHiveInfo(String user, String permlink) async {
    var request = http.Request('POST', Uri.parse('https://api.hive.blog/'));
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
      var upVotes = result.activeVotes.where((e) => e.rshares > 0).length;
      var downVotes = result.activeVotes.where((e) => e.rshares < 0).length;
      return PayoutInfo(
        payout: result.payout,
        downVotes: downVotes,
        upVotes: upVotes,
      );
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase.toString();
    }
  }

  Future<String> _getAccessToken(
      HiveUserData user, String encryptedToken) async {
    const platform = MethodChannel('com.example.acela/auth');
    final String result = await platform.invokeMethod('encryptedToken', {
      'username': user.username,
      'postingKey': user.postingKey,
      'encryptedToken': encryptedToken,
    });
    var memo = MemoResponse.fromJsonString(result);
    if (memo.error.isNotEmpty) {
      throw memo.error;
    } else if (memo.decrypted.isEmpty) {
      throw 'Decrypted memo is empty';
    }
    return memo.decrypted.replaceFirst("#", '');
  }

  Future<VideoUploadPrepareResponse> prepareVideo(
      HiveUserData user, String videoInfo, String cookie) async {
    var request = http.Request('POST',
        Uri.parse('${Communicator.tsServer}/mobile/api/upload/prepare'));
    request.body = videoInfo;
    Map<String, String> map = {
      "cookie": cookie,
      "Content-Type": "application/json"
    };
    request.headers.addAll(map);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      log('Video upload prepare response is\n$string');
      return VideoUploadPrepareResponse.fromJsonString(string);
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase.toString();
    }
  }

  Future<String> getValidCookie(HiveUserData user) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            '${Communicator.tsServer}/mobile/login?username=${user.username}'));
    if (user.cookie != null) {
      Map<String, String> map = {"cookie": user.cookie!};
      request.headers.addAll(map);
    }
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var loginResponse = VideoUploadLoginResponse.fromJsonString(string);
      if (loginResponse.error != null && loginResponse.error!.isNotEmpty) {
        throw 'Error - ${loginResponse.error}';
      } else if (loginResponse.memo != null && loginResponse.memo!.isNotEmpty) {
        var token = await _getAccessToken(user, loginResponse.memo!);
        var url =
            '${Communicator.tsServer}/mobile/login?username=${user.username}&access_token=$token';
        var request = http.Request('GET', Uri.parse(url));
        http.StreamedResponse response = await request.send();
        var string = await response.stream.bytesToString();
        var tokenResponse = VideoUploadLoginResponse.fromJsonString(string);
        var cookie = response.headers['set-cookie'];
        if (tokenResponse.error != null && tokenResponse.error!.isNotEmpty) {
          throw 'Error - ${tokenResponse.error}';
        } else if (tokenResponse.network == "hive" &&
            tokenResponse.banned != true &&
            tokenResponse.userId != null &&
            cookie != null &&
            cookie.isNotEmpty) {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'cookie', value: cookie);
          var newData = HiveUserData(
            username: user.username,
            postingKey: user.postingKey,
            cookie: cookie,
          );
          server.updateHiveUserData(newData);
          return cookie;
        } else {
          log('This should never happen. No error, no user info. How?');
          throw 'Something went wrong.';
        }
      } else if (loginResponse.network == "hive" &&
          loginResponse.banned != true &&
          loginResponse.userId != null &&
          user.cookie != null) {
        return user.cookie!;
      } else {
        log('This should never happen. No error, no memo, no user info. How?');
        throw 'Something went wrong.';
      }
    } else if (response.statusCode == 500) {
      var string = await response.stream.bytesToString();
      var errorResponse = VideoUploadLoginResponse.fromJsonString(string);
      if (errorResponse.error != null &&
          errorResponse.error!.isNotEmpty &&
          errorResponse.error == 'session expired') {
        const storage = FlutterSecureStorage();
        await storage.delete(key: 'cookie');
        var newData = HiveUserData(
          username: user.username,
          postingKey: user.postingKey,
          cookie: null,
        );
        server.updateHiveUserData(newData);
        return await getValidCookie(newData);
      } else {
        throw 'Status code ${response.statusCode}';
      }
    } else {
      throw 'Status code ${response.statusCode}';
    }
  }

  Future<void> addToken(HiveUserData user, String token) async {
    var request = http.Request(
        'POST', Uri.parse('${Communicator.tsServer}/mobile/api/token/add'));
    request.body = "{\"token\": \"$token\"}";
    Map<String, String> map = {
      "cookie": user.cookie ?? "",
      "Content-Type": "application/json"
    };
    request.headers.addAll(map);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      log("Successfully registered token");
      return;
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase.toString();
    }
  }

  Future<void> removeToken(HiveUserData user, String token) async {
    var request = http.Request(
        'POST', Uri.parse('${Communicator.tsServer}/mobile/api/token/remove'));
    request.body = "{\"token\": \"$token\"}";
    Map<String, String> map = {
      "cookie": user.cookie ?? "",
      "Content-Type": "application/json"
    };
    request.headers.addAll(map);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      log("Successfully un-registered token");
      return;
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase.toString();
    }
  }

  Future<VideoUploadInfo> uploadComplete({
    required HiveUserData user,
    required String videoId,
    required String name,
    required String title,
    required String description,
    required bool isNsfwContent,
    required String tags,
    required String thumbnail,
  }) async {
    var request = http.Request('POST',
        Uri.parse('${Communicator.tsServer}/mobile/api/upload/complete'));
    request.body = VideoUploadCompleteRequest(
      videoId: videoId,
      filename: name,
      title: title,
      description: description,
      isNsfwContent: isNsfwContent,
      tags: tags,
      thumbnail: thumbnail,
    ).toJsonString();
    Map<String, String> map = {
      "cookie": user.cookie ?? "",
      "Content-Type": "application/json"
    };
    request.headers.addAll(map);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      log("Successfully sent upload complete");
      var string = await response.stream.bytesToString();
      log('Video complete response is\n$string');
      return VideoUploadInfo.fromJsonString(string);
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase.toString();
    }
  }
}
