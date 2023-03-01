import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/threads/single_thread_response.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/error_state_widget.dart';
import 'package:acela/src/widgets/loading_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:timeago/timeago.dart' as timeago;

class SingleThreadList extends StatefulWidget {
  const SingleThreadList({
    Key? key,
    required this.partUrl,
  }) : super(key: key);
  final String partUrl;

  @override
  State<SingleThreadList> createState() => _SingleThreadListState();
}

class _SingleThreadListState extends State<SingleThreadList> {
  late Future<SingleThreadResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = getThreadData();
  }

  Future<SingleThreadResponse> getThreadData() async {
    var request = Communicator().getThreadDetails(widget.partUrl);
    try {
      var response = await Communicator().getResponseString(request);
      var responseData = SingleThreadResponse.fromJsonString(response);
      return responseData;
    } catch (e) {
      log('Error is -${e.toString()}');
      rethrow;
    }
  }

  Widget _container(SingleThreadResponse data) {
    return ListView.separated(
      itemBuilder: (c, i) {
        var dateTime = DateTime.tryParse(data.threadContents[i].content.created) ?? DateTime.now();
        String timeInString = timeago.format(dateTime);
        return ListTile(
          tileColor: i % 2 == 0 ? Colors.transparent : Colors.white10,
          leading: CustomCircleAvatar(
            height: 40,
            width: 40,
            url: server.userOwnerThumb(data.threadContents[i].content.author),
          ),
          title: Text("${data.threadContents[i].content.author} · 📆 $timeInString"),
          subtitle: MarkdownBody(data: data.threadContents[i].content.body),
        );
      },
      separatorBuilder: (c, i) => const Divider(color: Colors.transparent),
      itemCount: data.threadContents.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          return ErrorStateWidget(onRetry: (){
            setState(() {
              _future = getThreadData();
            });
          });
        } else if (snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data as SingleThreadResponse;
          return _container(data);
        } else {
          return const LoadingStateWidget();
        }
      },
    );
  }
}
