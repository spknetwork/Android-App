import 'package:flutter/material.dart';

class VideoDetailsTabbedWidget extends StatefulWidget {
  const VideoDetailsTabbedWidget({Key? key, required this.children})
      : super(key: key);
  final List<Widget> children;

  @override
  _VideoDetailsTabbedWidgetState createState() =>
      _VideoDetailsTabbedWidgetState();
}

class _VideoDetailsTabbedWidgetState extends State<VideoDetailsTabbedWidget>
    with SingleTickerProviderStateMixin {
  static const List<Tab> tabs = [
    Tab(text: 'Video'),
    Tab(text: 'Description'),
    Tab(text: 'Comments')
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
      appBar: AppBar(
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
