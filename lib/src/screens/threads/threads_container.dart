import 'dart:developer';

import 'package:acela/src/models/threads/threads_response.dart';
import 'package:acela/src/screens/threads/single_thread_list.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/error_state_widget.dart';
import 'package:acela/src/widgets/loading_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:scroll_navigation/scroll_navigation.dart';

class ThreadsContainer extends StatefulWidget {
  const ThreadsContainer({Key? key}) : super(key: key);

  @override
  State<ThreadsContainer> createState() => _ThreadsContainerState();
}

class _ThreadsContainerState extends State<ThreadsContainer> {
  late Future<ThreadNamesResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = getThreadData();
  }

  Future<ThreadNamesResponse> getThreadData() async {
    var request = Communicator().getThreadSubjects();
    try {
      var response = await Communicator().getResponseString(request);
      var responseData = ThreadNamesResponse.fromJsonString(response);
      return responseData;
    } catch (e) {
      log('Error is -${e.toString()}');
      rethrow;
    }
  }

  Widget _container(ThreadNamesResponse data) {
    var pages = [
          SingleThreadList(
            partUrl: "threads?_data=routes%2Fthreads%2Findex",
          )
        ] +
        data.tags
            .map((e) {
              return SingleThreadList(
                partUrl:
                    "threads/tag/${e.name}?_data=routes%2Fthreads%2Ftag.%24tag",
              );
            })
            .toList()
            .take(10)
            .toList();
    var items = ["Home"] +
        data.tags
            .map((e) {
              return e.name;
            })
            .toList()
            .take(10)
            .toList();
    return SafeArea(
      child: TitleScrollNavigation(
        bodyStyle: NavigationBodyStyle(
          // background: Colors.blue,
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        barStyle: TitleNavigationBarStyle(
          style: TextStyle(fontWeight: FontWeight.bold),
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
          spaceBetween: 20,
          elevation: 1,
        ),
        pages: pages,
        titles: items,
      ),
    );
  }

  Widget _bodyFuture() {
    return FutureBuilder(
      future: _future,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          return ErrorStateWidget(onRetry: () {
            setState(() {
              _future = getThreadData();
            });
          });
        } else if (snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data as ThreadNamesResponse;
          return _container(data);
        } else {
          return const LoadingStateWidget();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hive ♦️ Threads 🪡 by Leo 🦁"),
      ),
      body: _bodyFuture(),
    );
  }
}
