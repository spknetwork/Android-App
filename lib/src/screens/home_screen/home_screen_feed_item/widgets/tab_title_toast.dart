import 'dart:developer';

import 'package:flutter/material.dart';

class HomeScreenTabTitleToast extends StatefulWidget {
  const HomeScreenTabTitleToast(
      {Key? key, required this.tabIndex, required this.subtitle})
      : super(key: key);

  final int tabIndex;
  final String subtitle;

  @override
  State<HomeScreenTabTitleToast> createState() =>
      _HomeScreenTabTitleToastState();
}

class _HomeScreenTabTitleToastState extends State<HomeScreenTabTitleToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  ValueNotifier<bool> hideMenu = ValueNotifier(false);

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    animate();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant HomeScreenTabTitleToast oldWidget) {
    if (oldWidget.tabIndex != widget.tabIndex) {
      animate();
    }
    super.didUpdateWidget(oldWidget);
  }

  void animate() async {
    _animationController.reset();
    _animationController.forward();
    await Future.delayed(const Duration(seconds: 3));
    if (_animation.status == AnimationStatus.completed) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              spreadRadius: 2,
              color: Colors.purple.shade800.withOpacity(0.2),
            )
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
          color: Colors.deepPurple.withOpacity(0.8),
        ),
        child: Text(widget.subtitle,style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
