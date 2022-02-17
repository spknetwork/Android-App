import 'package:flutter/material.dart';

class VideoDetailsTabbedWidget extends StatefulWidget {
  const VideoDetailsTabbedWidget({
    Key? key,
    required this.children,
    required this.title,
    required this.onUserTap,
    required this.fullscreen,
  }) : super(key: key);
  final List<Widget> children;
  final String title;
  final Function onUserTap;
  final bool fullscreen;

  @override
  _VideoDetailsTabbedWidgetState createState() =>
      _VideoDetailsTabbedWidgetState();
}

class _VideoDetailsTabbedWidgetState extends State<VideoDetailsTabbedWidget>
    with SingleTickerProviderStateMixin {
  static const List<Tab> tabs = [
    Tab(text: 'Video'),
    Tab(text: 'Info'),
    Tab(text: 'Comments'),
    Tab(text: 'More'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fullscreen
          ? null
          : AppBar(
              title: Text(widget.title),
              actions: [
                IconButton(
                    onPressed: () {
                      widget.onUserTap();
                    },
                    icon: const Icon(Icons.person)),
              ],
              bottom: TabBar(
                controller: _tabController,
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
