import 'package:acela/src/widgets/box_loading/box_loading.dart';
import 'package:acela/src/widgets/box_loading/box_trail.dart';
import 'package:flutter/material.dart';

class VideoItemLoader extends StatefulWidget {
  const VideoItemLoader({Key? key, required this.isGridView});

  final bool isGridView;
  @override
  State<VideoItemLoader> createState() => _VideoItemLoaderState();
}

class _VideoItemLoaderState extends State<VideoItemLoader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BoxLoadingIndicator(
        child: Column(
      children: [
        widget.isGridView ? Expanded(child: BoxTrail(
          shape: BoxShape.rectangle,
          height: 230,
        ),) :
        BoxTrail(
          shape: BoxShape.rectangle,
          height: 230,
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 10.0, bottom: 5, left: 13, right: 13),
          child: Row(
            children: [
              BoxTrail(
                shape: BoxShape.circle,
                height: 40,
                width: 40,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: BoxTrail(),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const BoxTrail(
                        width: 90,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      const BoxTrail(
                        width: 70,
                      ),
                    ],
                  ),
                ],
              ))
            ],
          ),
        ),
      ],
    ));
  }
}
