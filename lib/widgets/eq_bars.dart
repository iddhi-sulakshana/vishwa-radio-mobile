import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A row of 9 equalizer bars either side of the play button. Mirrors the
/// `vohEq` CSS keyframe: each bar pulses 6px→26px on its own duration/delay,
/// starting only while [playing] is true.
class EqBarsRow extends StatelessWidget {
  final bool playing;

  /// The right-hand row staggers in the opposite direction (delay index
  /// counts down from 8 instead of up from 0), matching `anim2` in the
  /// design.
  final bool mirrored;

  const EqBarsRow({super.key, required this.playing, this.mirrored = false});

  static const _periodsSeconds = [0.9, 0.7, 1.1, 0.8, 1.0, 0.75, 1.05, 0.85, 0.95];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(9, (i) {
          final delayIndex = mirrored ? (8 - i) : i;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: _Bar(
              periodSeconds: _periodsSeconds[i],
              delaySeconds: delayIndex * 0.08,
              playing: playing,
            ),
          );
        }),
      ),
    );
  }
}

class _Bar extends StatefulWidget {
  final double periodSeconds;
  final double delaySeconds;
  final bool playing;

  const _Bar({required this.periodSeconds, required this.delaySeconds, required this.playing});

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _height;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.periodSeconds * 1000).round()),
    );
    _height = CurvedAnimation(parent: _controller, curve: Curves.easeInOut).drive(Tween(begin: 6.0, end: 26.0));
    _sync();
  }

  @override
  void didUpdateWidget(covariant _Bar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing) _sync();
  }

  void _sync() {
    _delayTimer?.cancel();
    if (widget.playing) {
      _delayTimer = Timer(Duration(milliseconds: (widget.delaySeconds * 1000).round()), () {
        if (mounted) _controller.repeat(reverse: true);
      });
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _height,
      builder: (context, _) {
        return Container(
          width: 6,
          height: widget.playing ? _height.value : 6,
          decoration: BoxDecoration(
            color: widget.playing ? AppColors.signal : AppColors.whiteAlpha(0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
