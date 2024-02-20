import 'package:acela/src/widgets/box_loading/box_loading.dart';
import 'package:acela/src/widgets/box_loading/box_trail.dart';
import 'package:flutter/material.dart';

class VideoDetailFeedLoader extends StatelessWidget {
  const VideoDetailFeedLoader({Key? key, required this.isGridView})
      : super(key: key);

  final bool isGridView;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return BoxLoadingIndicator(
      child: Column(
        children: [
          BoxTrail(
            borderRadius: 0,
            height: isGridView ? screenHeight * 0.4 : 230,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 5),
            child: ListTile(
              contentPadding: EdgeInsets.only(top: 0, left: 15, right: 15),
              dense: true,
              leading: BoxTrail(
                height: 40,
                width: 40,
                shape: BoxShape.circle,
              ),
              title: BoxTrail(
                width: screenWidth * 0.8,
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BoxTrail(
                    width: screenWidth * 0.4,
                  ),
                  BoxTrail(width: 80),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                (index) => BoxTrail(
                  height: 35,
                  width: 35,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0, top: 15),
            child: SizedBox(
              height: 33,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: BoxTrail(
                      width: 130,
                      borderRadius: 18,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
