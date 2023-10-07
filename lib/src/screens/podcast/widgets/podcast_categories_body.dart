import 'package:acela/src/models/podcast/podcast_categories_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/view/podcast_category_view.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';

class PodcastCategoriesBody extends StatefulWidget {
  const PodcastCategoriesBody(
      {Key? key, required this.future, required this.appData})
      : super(key: key);

  final Future<List<PodcastCategory>> future;
  final HiveUserData appData;

  @override
  State<PodcastCategoriesBody> createState() => _PodcastCategoriesBodyState();
}

class _PodcastCategoriesBodyState extends State<PodcastCategoriesBody> {
  late Future<List<PodcastCategory>> future;
  @override
  void initState() {
    future = widget.future;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PodcastCategoriesBody oldWidget) {
    future = widget.future;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PodcastCategory>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RetryScreen(
            error: snapshot.error.toString(),
            onRetry: () {
              setState(() {
                future = widget.future;
              });
            },
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          List<PodcastCategory> list = snapshot.data!;
          if (list.isEmpty) {
            return RetryScreen(
              error: 'No data found.',
              onRetry: () {
                setState(() {
                  future = widget.future;
                });
              },
            );
          } else {
            return getList(list);
          }
        } else {
          return LoadingScreen(title: 'Loading', subtitle: 'Please wait..');
        }
      },
    );
  }

  Widget getList(List<PodcastCategory> items) {
    return ListView.separated(
      itemBuilder: (c, i) {
        return ListTile(
          onTap: () {
            var screen = PodcastCategoryView(
              appData: widget.appData,
              categoryId: items[i].id!,
              categoryName: items[i].name!,
            );
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).push(route);
          },
          title: Text(items[i].name.toString()),
        );
      },
      separatorBuilder: (c, i) => const Divider(height: 0),
      itemCount: items.length,
    );
  }
}
