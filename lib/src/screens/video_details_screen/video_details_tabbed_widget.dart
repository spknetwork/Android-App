import 'package:flutter/material.dart';
// import 'dart:io' show Platform;
import 'package:share_plus/share_plus.dart';

class VideoDetailsTabbedWidget extends StatefulWidget {
  const VideoDetailsTabbedWidget(
      {Key? key,
      required this.children,
      required this.title,
      required this.onUserTap,
      required this.fullscreen,
      required this.routeName})
      : super(key: key);
  final List<Widget> children;
  final String title;
  final Function onUserTap;
  final bool fullscreen;
  final String routeName;

  @override
  _VideoDetailsTabbedWidgetState createState() =>
      _VideoDetailsTabbedWidgetState();
}

class _VideoDetailsTabbedWidgetState extends State<VideoDetailsTabbedWidget>
    with SingleTickerProviderStateMixin {
  static const List<Tab> tabs = [
    Tab(text: 'Video'),
    Tab(text: 'Description'),
    Tab(text: 'Comments'),
    Tab(text: 'Recommendation'),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> _buttons() {
    var channelButton = IconButton(
      onPressed: () {
        widget.onUserTap();
      },
      icon: const Icon(Icons.person),
    );
    var shareButton = IconButton(
      onPressed: () {
        Share.share(
          widget.routeName,
          subject: 'I found this video interesting ${widget.routeName}',
        );
      },
      icon: const Icon(Icons.share),
    );
    // if (Platform.isAndroid || Platform.isIOS) {
    //   return [channelButton, shareButton];
    // } else {
      return [channelButton];
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fullscreen
          ? null
          : AppBar(
              title: Text(widget.title),
              actions: _buttons(),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: tabs,
              ),
            ),
      body: TabBarView(
        controller: _tabController,
        children: widget.children,
      ),
    );
  }
}
