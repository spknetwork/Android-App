import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/hive_post_info/hive_user_posting_key.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/login/memo_response.dart';
import 'package:acela/src/models/my_account/video_ops.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/models/video_upload/video_upload_complete_request.dart';
import 'package:acela/src/models/video_upload/video_upload_login_response.dart';
import 'package:acela/src/models/video_upload/video_upload_prepare_response.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Communicator {
  // Production
  // static const tsServer = "https://studio.3speak.tv";
  // static const fsServer = "https://uploads.3speak.tv/files";

  // Android
  static const fsServer = "http://10.0.2.2:1080/files";
  static const tsServer = "http://10.0.2.2:13050";

  // iOS
  // static const tsServer = "http://localhost:13050";
  // static const fsServer = "http://localhost:1080/files";

  // iOS Device
  // static const tsServer = "http://192.168.1.8:13050";
  // static const fsServer = "http://192.168.1.8:1080/files";

  static const hiveApiUrl = 'https://api.hive.blog/';
  static const threeSpeakCDN = 'https://ipfs-3speak.b-cdn.net';

  Future<String> getPublicKey(String user) async {
    var request = http.Request('POST', Uri.parse(hiveApiUrl));
    request.body = json.encode({
      "id": 8,
      "jsonrpc": "2.0",
      "method": "database_api.find_accounts",
      "params": {
        "accounts": [user]
      }
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var key = HiveUserPostingKey.fromString(responseBody);
      return key.publicPostingKey;
    } else {
      log(response.reasonPhrase.toString());
      throw response.reasonPhrase.toString();
    }
  }

  Future<PayoutInfo> fetchHiveInfo(String user, String permlink) async {
    var request = http.Request('POST', Uri.parse(Communicator.hiveApiUrl));
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
      var string = await response.stream.bytesToString();
      var error = ErrorResponse.fromJsonString(string).error ??
          response.reasonPhrase.toString();
      log('Error from server is $error');
      throw error;
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
      var string = await response.stream.bytesToString();
      var error = ErrorResponse.fromJsonString(string).error ??
          response.reasonPhrase.toString();
      log('Error from server is $error');
      throw error;
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

  Future<VideoUploadInfo> uploadInfo({
    required HiveUserData user,
    required String thumbnail,
    required String oFilename,
    required int duration,
    required double size,
    required String tusFileName,
  }) async {
    var cookie = await getValidCookie(user);
    var request = http.Request(
        'POST', Uri.parse('${Communicator.tsServer}/mobile/api/upload_info'));
    request.body = NewVideoUploadCompleteRequest(
      size: size,
      thumbnail: thumbnail,
      oFilename: oFilename,
      duration: duration,
      filename: tusFileName,
      owner: user.username,
    ).toJsonString();
    Map<String, String> map = {
      "cookie": cookie,
      "Content-Type": "application/json"
    };
    request.headers.addAll(map);
    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        log("Successfully sent upload complete");
        var string = await response.stream.bytesToString();
        log('Video complete response is\n$string');
        return VideoUploadInfo.fromJsonString(string);
      } else {
        var string = await response.stream.bytesToString();
        var error = ErrorResponse.fromJsonString(string).error ??
            response.reasonPhrase.toString();
        log('Error from server is $error');
        throw error;
      }
    } catch (e) {
      log('Error from server is ${e.toString()}');
      rethrow;
    }
  }

  Future<VideoDetails> updateInfo({
    required HiveUserData user,
    required String videoId,
    required String title,
    required String description,
    required bool isNsfwContent,
    required String tags,
    required String? thumbnail,
  }) async {
    var request = http.Request(
        'POST', Uri.parse('${Communicator.tsServer}/mobile/api/update_info'));
    request.body = VideoUploadCompleteRequest(
      videoId: videoId,
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
    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        log("Successfully sent upload complete");
        var string = await response.stream.bytesToString();
        log('Video complete response is\n$string');
        return VideoDetails.fromJsonString(string);
      } else {
        var string = await response.stream.bytesToString();
        var error = ErrorResponse.fromJsonString(string).error ??
            response.reasonPhrase.toString();
        log('Error from server is $error');
        throw error;
      }
    } catch (e) {
      log('Error from server is ${e.toString()}');
      rethrow;
    }
  }

  Future<List<VideoDetails>> loadVideos(HiveUserData user) async {
    log("Starting fetch videos ${DateTime.now().toIso8601String()}");
    var cookie = await getValidCookie(user);
    var request = http.Request(
        'GET', Uri.parse('${Communicator.tsServer}/mobile/api/my-videos'));
    Map<String, String> map = {"cookie": cookie};
    request.headers.addAll(map);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      log('My videos response\n\n$string\n\n');
      var videos = videoItemsFromString(string);
      log("Ended fetch videos ${DateTime.now().toIso8601String()}");
      return videos;
    } else {
      var string = await response.stream.bytesToString();
      var error = ErrorResponse.fromJsonString(string).error ??
          response.reasonPhrase.toString();
      log('Error from server is $error');
      throw error;
    }
  }

  Future<void> updatePublishState(HiveUserData user, String videoId) async {
    var cookie = await getValidCookie(user);
    var request = http.Request('POST',
        Uri.parse('${Communicator.tsServer}/mobile/api/my-videos/iPublished'));
    request.body = "{\"videoId\": \"$videoId\"}";
    Map<String, String> map = {
      "cookie": cookie,
      "Content-Type": "application/json"
    };
    request.headers.addAll(map);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var result = VideoOpsResponse.fromJsonString(string);
      if (result.success) {
        return;
      } else {
        throw 'Error updating video status';
      }
    } else {
      var string = await response.stream.bytesToString();
      var error = ErrorResponse.fromJsonString(string).error ??
          response.reasonPhrase.toString();
      log('Error from server is $error');
      throw error;
    }
  }
}
