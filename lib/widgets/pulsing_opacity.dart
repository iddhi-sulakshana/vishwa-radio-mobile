import 'package:flutter/material.dart';

/// Wraps [child] in a 1.6s opacity pulse (1.0 → 0.35 → 1.0), matching the
/// `vohLive` keyframe used for every "on air" indicator in the redesign.
class PulsingOpacity extends StatefulWidget {
  final Widget child;

  const PulsingOpacity({super.key, required this.child});

  @override
  State<PulsingOpacity> createState() => _PulsingOpacityState();
}

class _PulsingOpacityState extends State<PulsingOpacity> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.35).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
