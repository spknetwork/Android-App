import 'dart:convert';

import 'package:acela/src/models/login/login_bridge_response.dart';
import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewVideoDetailsInfo extends StatefulWidget {
  const NewVideoDetailsInfo({
    Key? key,
    required this.appData,
    required this.item,
  }) : super(key: key);
  final GQLFeedItem item;
  final HiveUserData appData;

  @override
  State<NewVideoDetailsInfo> createState() => _NewVideoDetailsInfoState();
}

class _NewVideoDetailsInfoState extends State<NewVideoDetailsInfo> {
  late final WebViewController controller;

  @override
  void initState() {
    controller = WebViewController();
    getHtmlAndLoad();
    super.initState();
  }

  void getHtmlAndLoad() async {
    String markdownText =
        widget.item.spkvideo?.body ?? widget.item.body ?? "No content";
    const platform = MethodChannel('com.example.acela/auth');
    var markdownTextData = base64.encode(utf8.encode(markdownText));
    final String markdownTextDataResponse =
        await platform.invokeMethod('getHTMLStringForContent', {
      'string': markdownTextData,
    });
    var bridgeResponseForMarkDown =
        LoginBridgeResponse.fromJsonString(markdownTextDataResponse);
    var resultedString =
        utf8.decode(base64.decode(bridgeResponseForMarkDown.data ?? ""));
    var color = true ? 'white' : 'black';
    var htmlString =
        resultedString.replaceAll("<img src", "<img width='100%' src");
    htmlString = "<body text='white' link='#FF5722'>$htmlString</body>";
    setState(() {
      controller.loadHtmlString(resultedString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title ?? ""),
      ),
      body: SafeArea(
          child: WebViewWidget(
        controller: controller,
      )
          ),
    );
  }
}
