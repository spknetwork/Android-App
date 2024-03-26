import 'package:acela/src/screens/video_details_screen/comment/controller/comment_controller.dart';
import 'package:acela/src/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentViewAppbar extends StatefulWidget implements PreferredSizeWidget {
  const CommentViewAppbar(
      {Key? key, required this.state, required this.showSearchBar})
      : super(key: key);

  final ViewState state;
  final ValueNotifier<bool> showSearchBar;

  @override
  State<CommentViewAppbar> createState() => _CommentViewAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CommentViewAppbarState extends State<CommentViewAppbar> {
  bool showSearch = false;

  @override
  Widget build(BuildContext context) {
    int numberOfComments = context
        .select<CommentController, int>((value) => value.disPlayedItems.length);
    return AppBar(
      title: Text(
          'Comments${widget.state != ViewState.loading ? ' ($numberOfComments)' : ''}'),
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: widget.showSearchBar,
          builder: (context, showSearchButton, child) {
            return Visibility(
                visible: numberOfComments != 0 && !showSearchButton,
                child: child!);
          },
          child: IconButton(
            onPressed: () {
              widget.showSearchBar.value = true;
            },
            icon: Icon(Icons.search),
          ),
        )
      ],
    );
  }
}
