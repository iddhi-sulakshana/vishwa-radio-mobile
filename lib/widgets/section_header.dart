import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import 'hamburger_button.dart';

/// Hamburger + large title header used by the Timetable, Podcasts,
/// Livestreams, About and Contact screens.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuTap;

  const SectionHeader({super.key, required this.title, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 20, 6),
      child: Row(
        children: [
          HamburgerButton(onTap: onMenuTap),
          const SizedBox(width: 8),
          Text(title, style: AppText.archivo(size: 20, weight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
