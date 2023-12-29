import 'package:flutter/material.dart';

class BoxLoadingIndicator extends StatefulWidget {
  const BoxLoadingIndicator({ required this.child, this.end});

  final Widget child;
  final double? end;

  @override
  State<BoxLoadingIndicator> createState() => _BoxLoadingIndicatorState();
}

class _BoxLoadingIndicatorState extends State<BoxLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1, end: widget.end ?? 0.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget? child) {
          return Opacity(
            opacity: _animation.value,
            child: child,
          );
        },
        child: widget.child);
  }
}
