import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The three-line menu icon (middle bar short + orbit blue) used to open the
/// drawer, tappable with a comfortable hit area.
class HamburgerButton extends StatelessWidget {
  final VoidCallback onTap;

  const HamburgerButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(22, Colors.white),
            const SizedBox(height: 5),
            _bar(14, AppColors.orbit),
            const SizedBox(height: 5),
            _bar(22, Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _bar(double width, Color color) {
    return Container(
      width: width,
      height: 2,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }
}
