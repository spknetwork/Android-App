import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  const DialogButton({
    required this.text,
    required this.onPressed,
     this.color,
  });

  final String text;
  final Function() onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: color),
        ),
      ),
    );
  }
}
