import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';

class FabOverItemData {
  String displayName;
  IconData icon;
  Function onTap;
  String? url;
  String? image;

  FabOverItemData({
    required this.displayName,
    required this.icon,
    required this.onTap,
    this.url,
    this.image
  });
}

class FabOverlay extends StatelessWidget {
  const FabOverlay({
    Key? key,
    required this.items,
    required this.onBackgroundTap,
  }) : super(key: key);
  final List<FabOverItemData> items;
  final Function onBackgroundTap;

  Widget _singleItem(BuildContext context, FabOverItemData data) {
    late Widget child;
    if (data.url != null) {
      child = CustomCircleAvatar(
        height: 40,
        width: 40,
        url: data.url!,
      );
    } else if (data.image != null) {
      child = Image.asset(data.image!, width: 30, height: 30);
    } else {
      child = Icon(data.icon);
    }
    return Column(
      children: [
        const SizedBox(height: 5),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme
                    .of(context)
                    .colorScheme.background,
              ),
              child: Text(data.displayName),
            ),
            const SizedBox(width: 5),
            FloatingActionButton(
                mini: true,
                onPressed: () {
                  data.onTap();
                },
                child: child
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var widgets = items.map((e) => _singleItem(context, e)).toList();
    return InkWell(
      onTap: () {
        onBackgroundTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .scaffoldBackgroundColor
              .withAlpha(200),
        ),
        child: Row(
          children: [
            const Spacer(),
            Column(
              children: [
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: widgets,
                ),
                const SizedBox(height: 10)
              ],
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
