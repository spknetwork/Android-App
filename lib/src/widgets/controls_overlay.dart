import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ControlsOverlay extends StatefulWidget {
  const ControlsOverlay(
      {Key? key, required this.controller, required this.handleFullScreen})
      : super(key: key);

  final VideoPlayerController controller;
  final Function(bool) handleFullScreen;

  @override
  _ControlsOverlayState createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<ControlsOverlay> {
  static const _examplePlaybackRates = [
    0.5,
    1.0,
    1.5,
    2.0,
  ];

  var volume = 1.0;
  var playing = true;
  var fullScreen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: playing
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              widget.controller.value.isPlaying
                  ? widget.controller.pause()
                  : widget.controller.play();
              playing = widget.controller.value.isPlaying;
            });
          },
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            children: [
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                    child: Slider(
                      value: volume,
                      onChanged: (value) {
                        setState(() {
                          volume = value;
                          widget.controller.setVolume(value);
                        });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        fullScreen = !fullScreen;
                        widget.handleFullScreen(fullScreen);
                      });
                    },
                    icon: fullScreen
                        ? const Icon(Icons.fullscreen)
                        : const Icon(Icons.fullscreen_exit),
                  ),
                  PopupMenuButton<double>(
                    initialValue: widget.controller.value.playbackSpeed,
                    tooltip: 'Playback speed',
                    onSelected: (speed) {
                      widget.controller.setPlaybackSpeed(speed);
                    },
                    itemBuilder: (context) {
                      return [
                        for (final speed in _examplePlaybackRates)
                          PopupMenuItem(
                            value: speed,
                            child: Text('${speed}x'),
                          )
                      ];
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        // Using less vertical padding as the text is also longer
                        // horizontally, so it feels like it would need more spacing
                        // horizontally (matching the aspect ratio of the video).
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Text('${widget.controller.value.playbackSpeed}x'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        )
      ],
    );
  }
}
