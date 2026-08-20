import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../navigation/app_routes.dart';
import '../services/admin_content_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _open(BuildContext context, String url) async {
    if (url.isEmpty) return;
    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open that link")),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open that link")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeLabel: 'Contact',
      onSelect: (label) => AppRoutes.navigateToLabel(context, label),
      builder: (context, openDrawer) => Container(
        decoration: const BoxDecoration(gradient: AppGradients.section),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SectionHeader(title: 'Contact', onMenuTap: openDrawer),
              Expanded(
                child: ListenableBuilder(
                  listenable: AdminContentController.instance,
                  builder: (context, _) {
                    final settings =
                        AdminContentController.instance.siteSettings;
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                      children: [
                        _ContactRow(
                          label: 'Address',
                          value: settings.contact.address,
                          onTap: null,
                        ),
                        _ContactRow(
                          label: 'Phone',
                          value: settings.contact.phone,
                          onTap: () =>
                              _open(context, 'tel:${settings.contact.phone}'),
                        ),
                        _ContactRow(
                          label: 'Email',
                          value: settings.contact.email,
                          onTap: () => _open(
                            context,
                            'mailto:${settings.contact.email}',
                          ),
                        ),
                        if (settings.social.configured.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            'FOLLOW US',
                            style: AppText.mono(
                              size: 11,
                              weight: FontWeight.w700,
                              color: AppColors.orbit,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...settings.social.configured.map(
                            (entry) => _ContactRow(
                              label: entry.$1,
                              value: entry.$2,
                              onTap: () => _open(context, entry.$2),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.whiteAlpha(0.04),
          border: Border.all(color: AppColors.whiteAlpha(0.07)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 70,
              child: Text(
                label,
                style: AppText.mono(
                  size: 10,
                  weight: FontWeight.w700,
                  color: AppColors.orbit,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: AppText.archivo(
                  size: 14,
                  weight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
            if (onTap != null)
              Text(
                '›',
                style: AppText.mono(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.whiteAlpha(0.4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
