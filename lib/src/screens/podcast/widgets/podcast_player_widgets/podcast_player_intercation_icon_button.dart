import 'package:flutter/material.dart';

class PodcastPlayerInteractionIconButton extends StatelessWidget {
  const PodcastPlayerInteractionIconButton(
      {Key? key,
      required this.icon,
      required this.onPressed,
      required this.color,
      this.size,
      this.horizontalPadding = 10})
      : super(key: key);

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double? size;
  final double horizontalPadding;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding ),
      splashRadius: 18,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}
