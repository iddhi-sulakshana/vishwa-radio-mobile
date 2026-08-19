import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Repeating 45° diagonal stripe pattern used as a placeholder background
/// for cover art / video embeds in the redesign (real thumbnails go here
/// once available).
class DiagonalStripes extends StatelessWidget {
  final double stripeWidth;
  final Color colorA;
  final Color colorB;
  final BorderRadius? borderRadius;
  final Widget? child;

  const DiagonalStripes({
    super.key,
    this.stripeWidth = 6,
    this.colorA = AppColors.coverArtStripe,
    this.colorB = AppColors.coverArtBase,
    this.borderRadius,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final content = CustomPaint(
      painter: _StripePainter(stripeWidth: stripeWidth, colorA: colorA, colorB: colorB),
      child: Center(child: child),
    );
    if (borderRadius == null) return content;
    return ClipRRect(borderRadius: borderRadius!, child: content);
  }
}

class _StripePainter extends CustomPainter {
  final double stripeWidth;
  final Color colorA;
  final Color colorB;

  const _StripePainter({required this.stripeWidth, required this.colorA, required this.colorB});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colorA);
    final paint = Paint()..color = colorB;
    final period = stripeWidth * 2;
    final span = size.width + size.height;
    for (double d = -size.height; d < span; d += period) {
      final path = Path()
        ..moveTo(d, 0)
        ..lineTo(d + stripeWidth, 0)
        ..lineTo(d + stripeWidth + size.height, size.height)
        ..lineTo(d + size.height, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter oldDelegate) {
    return oldDelegate.stripeWidth != stripeWidth ||
        oldDelegate.colorA != colorA ||
        oldDelegate.colorB != colorB;
  }
}
