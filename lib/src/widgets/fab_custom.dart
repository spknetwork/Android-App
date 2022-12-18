import 'package:flutter/material.dart';

class FabCustom extends StatelessWidget {
  const FabCustom({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);
  final IconData icon;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Row(
          children: [
            const Spacer(),
            FloatingActionButton(
              onPressed: () {
                onTap();
              },
              child: Icon(icon),
            ),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
