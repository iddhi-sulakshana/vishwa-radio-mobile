import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';

/// Google Play requires the privacy policy to be reachable from inside the
/// app as well as from the store listing, so the drawer carries both policy
/// links in its footer.
// NOTE: neither page exists on vishwaradio.lk yet — both return 404 today.
// They are pointed at their canonical URLs rather than removed, because both
// app stores require a reachable privacy policy before submission, and a
// missing link here would hide that requirement instead of surfacing it.
// Create the two pages on the website before the first store release.
const _privacyPolicyUrl = 'https://vishwaradio.lk/privacy-policy';
const _termsUrl = 'https://vishwaradio.lk/terms';

/// The slide-in navigation panel content (emblem header, nav items, policy
/// links). Rendered inside [AppScaffold]'s overlay.
class AppDrawerPanel extends StatelessWidget {
  final String activeLabel;
  final void Function(String label) onSelect;

  const AppDrawerPanel({
    super.key,
    required this.activeLabel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: AppGradients.drawerPanel,
        border: Border(right: BorderSide(color: AppColors.orbitAlpha(0.25))),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.whiteAlpha(0.08))),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/woodrose-logo-light.png',
                    width: 44,
                    height: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Vishwa Radio',
                          overflow: TextOverflow.ellipsis,
                          style: AppText.archivo(size: 14, weight: FontWeight.w600, color: Colors.white),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Woodrose Foundation',
                          overflow: TextOverflow.ellipsis,
                          style: AppText.mono(size: 10, weight: FontWeight.w400, color: AppColors.orbit, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                children: AppData.navItems.map((label) {
                  return _NavRow(
                    label: label,
                    active: label == activeLabel,
                    onTap: () => onSelect(label),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(color: AppColors.whiteAlpha(0.08), height: 18),
                  // Three fixed-width children in a 280-wide panel: at the
                  // default text scale they fit with room to spare, but a
                  // raised system text size clips "Terms" off the edge.
                  // scaleDown only engages when it would otherwise overflow.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const _PolicyLink(label: 'Privacy Policy', url: _privacyPolicyUrl),
                        Text(
                          '  ·  ',
                          style: AppText.mono(size: 11, weight: FontWeight.w400, color: AppColors.whiteAlpha(0.35)),
                        ),
                        const _PolicyLink(label: 'Terms', url: _termsUrl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens a policy page in the browser. Failure is silent by design — a
/// missing browser shouldn't throw out of a drawer tap.
class _PolicyLink extends StatelessWidget {
  final String label;
  final String url;

  const _PolicyLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } catch (_) {
          // Nothing useful to do — the drawer stays open.
        }
      },
      child: Text(
        label,
        style: AppText.mono(
          size: 11,
          weight: FontWeight.w400,
          color: AppColors.whiteAlpha(0.55),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavRow({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.orbit : AppColors.whiteAlpha(0.85);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: active ? AppGradients.navActive : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.archivo(size: 15, weight: FontWeight.w500, color: color)),
            Text('›', style: AppText.mono(size: 12, weight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
