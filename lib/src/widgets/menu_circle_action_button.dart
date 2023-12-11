import 'package:flutter/material.dart';

class MenuCircleActionButton extends StatelessWidget {
  const MenuCircleActionButton(
      {required this.text,
      required this.icon,
      this.backgroundColor,
      required this.onTap});

  final String text;
  final IconData icon;
  final Color? backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.grey.shade800,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 1),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          text,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
