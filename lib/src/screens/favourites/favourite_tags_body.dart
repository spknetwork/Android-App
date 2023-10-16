import 'package:acela/src/screens/trending_tags/tag_favourite_provider.dart';
import 'package:acela/src/screens/trending_tags/trending_tag_videos.dart';
import 'package:flutter/material.dart';

class FavouriteTagsBody extends StatelessWidget {
  const FavouriteTagsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TagFavoriteProvider dataProvider = TagFavoriteProvider();
    List items = dataProvider.getLikedTags();
    return items.isNotEmpty
        ? ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  var screen = TrendingTagVideos(tag: items[index]);
                  var route = MaterialPageRoute(builder: (c) => screen);
                  Navigator.of(context).push(route);
                },
                title: Text(items[index]),
              );
            },
          )
        : const Center(
            child: Text("No favourite tags found"),
          );
  }
}
