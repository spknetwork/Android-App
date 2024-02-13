import 'package:acela/src/widgets/box_loading/video_item_loader.dart';
import 'package:flutter/material.dart';

class VideoFeedLoader extends StatelessWidget {
  const VideoFeedLoader(
      {Key? key, this.isGridView = false, this.isSliver = false})
      : super(key: key);

  final bool isGridView;
  final bool isSliver;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = getCrossAxisCount(screenWidth);
    return isGridView
        ? isSliver
            ? SliverFillRemaining(
                child: _gridViewLoader(crossAxisCount, context),
              )
            : _gridViewLoader(crossAxisCount, context)
        : isSliver
            ? SliverToBoxAdapter(
                child: _listViewLoader(),
              )
            : _listViewLoader();
  }

  Padding _listViewLoader() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: VideoItemLoader(
              isGridView: false,
            ),
          ),
        ),
      ),
    );
  }

  Padding _gridViewLoader(int crossAxisCount, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: GridView.builder(
        itemCount: 25,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio:
              MediaQuery.of(context).orientation == Orientation.landscape
                  ? 1.25
                  : 1.4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          return VideoItemLoader(
            isGridView: isGridView,
          );
        },
      ),
    );
  }

  int getCrossAxisCount(double width) {
    if (width > 1300) {
      return 4;
    } else if (width > 974 && width < 1300) {
      return 3;
    } else if (width > 650 && width < 974) {
      return 2;
    } else {
      return 2;
    }
  }
}
