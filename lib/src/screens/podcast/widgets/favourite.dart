import 'package:flutter/material.dart';


class FavouriteWidget extends StatefulWidget {
  const FavouriteWidget(
      {Key? key,
      required this.isLiked,
      required this.onAdd,
      required this.onRemove,
      this.iconColor,
      this.disablePadding = false})
      : super(key: key);

  final bool isLiked;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final Color? iconColor;
  final bool disablePadding;

  @override
  State<FavouriteWidget> createState() => _FavouriteWidgetState();
}

class _FavouriteWidgetState extends State<FavouriteWidget> {
  late bool isLiked;
  @override
  void initState() {
    isLiked = widget.isLiked;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FavouriteWidget oldWidget) {
    isLiked = widget.isLiked;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: widget.disablePadding ? BoxConstraints() : null,
          padding: widget.disablePadding ? EdgeInsets.zero : null,
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: widget.iconColor,
      ),
      onPressed: () {
        if (isLiked) {
          widget.onRemove();
          setState(() {
            isLiked = false;
          });
        } else {
          widget.onAdd();
          setState(() {
            isLiked = true;
          });
        }
      },
    );
  }
}
