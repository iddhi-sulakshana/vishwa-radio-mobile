import 'package:flutter/material.dart';

/// Infinite horizontal ticker — mirrors the `vohTicker` CSS keyframe
/// (translateX 0 → -50%, linear, looping) from the design.
class TickerMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const TickerMarquee({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 18),
  });

  @override
  State<TickerMarquee> createState() => _TickerMarqueeState();
}

class _TickerMarqueeState extends State<TickerMarquee> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _gap = 48.0;
  static const _copies = 4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final itemWidth = painter.width + _gap;
    final rowHeight = (widget.style.fontSize ?? 11) * 1.5;

    return ClipRect(
      child: SizedBox(
        height: rowHeight,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final dx = -_controller.value * itemWidth;
            return Stack(
              clipBehavior: Clip.none,
              children: List.generate(_copies, (i) {
                return Positioned(
                  left: dx + i * itemWidth,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
