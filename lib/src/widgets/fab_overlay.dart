import 'package:flutter/material.dart';

class FabOverItemData {
  String displayName;
  IconData icon;
  Function onTap;

  FabOverItemData({
    required this.displayName,
    required this.icon,
    required this.onTap,
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
    return Column(
      children: [
        const SizedBox(height: 5),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).backgroundColor,
              ),
              child: Text(data.displayName),
            ),
            const SizedBox(width: 5),
            FloatingActionButton(
              mini: true,
              onPressed: () {
                data.onTap();
              },
              child: Icon(data.icon),
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
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(200),
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
