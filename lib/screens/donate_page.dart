import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/site_settings.dart';
import '../navigation/app_routes.dart';
import '../services/admin_content_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';

/// Donation details, as the console publishes them.
///
/// The body is split into [DonateBody], which takes its settings as a
/// parameter, so the widget test can drive every state without a network or
/// the controller singleton.
class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeLabel: 'Donate',
      onSelect: (label) => AppRoutes.navigateToLabel(context, label),
      builder: (context, openDrawer) => Container(
        decoration: const BoxDecoration(gradient: AppGradients.section),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SectionHeader(title: 'Donate', onMenuTap: openDrawer),
              Expanded(
                child: ListenableBuilder(
                  listenable: AdminContentController.instance,
                  builder: (context, _) => DonateBody(
                    donate: AdminContentController.instance.siteSettings.donate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class DonateBody extends StatelessWidget {
  const DonateBody({super.key, required this.donate});

  final DonateSettings donate;

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
    final hasAnything = donate.linkUrl.isNotEmpty || donate.bank.isComplete;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      children: [
        Text(
          donate.intro.isNotEmpty
              ? donate.intro
              : 'Your support helps keep Vishwa Radio on air and its '
                    'programmes free to listen to.',
          style: AppText.archivo(
            size: 14,
            color: AppColors.whiteAlpha(0.75),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),

        if (donate.linkUrl.isNotEmpty) ...[
          _DonateButton(onTap: () => _open(context, donate.linkUrl)),
          const SizedBox(height: 24),
        ],

        // Shown only once the bank name and account number are both set — a
        // half-filled panel invites a failed transfer.
        if (donate.bank.isComplete) _BankPanel(bank: donate.bank),

        if (!hasAnything)
          Text(
            'Donation details are being set up. Please check back soon, or '
            'get in touch from the Contact screen.',
            style: AppText.archivo(
              size: 14,
              color: AppColors.whiteAlpha(0.6),
              height: 1.6,
            ),
          ),
      ],
    );
  }
}

class _DonateButton extends StatelessWidget {
  const _DonateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppGradients.button,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Donate online',
          style: AppText.archivo(size: 15, weight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _BankPanel extends StatelessWidget {
  const _BankPanel({required this.bank});

  final BankDetails bank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteAlpha(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.whiteAlpha(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BANK TRANSFER',
            style: AppText.mono(
              size: 10,
              weight: FontWeight.w700,
              color: AppColors.orbit,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          for (final (label, value) in bank.rows)
            _BankRow(label: label, value: value),
        ],
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  const _BankRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppText.mono(
                    size: 10,
                    weight: FontWeight.w400,
                    color: AppColors.tickerText,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: AppText.archivo(size: 15, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // An account number that cannot be copied is an account number that
          // gets mistyped. SelectableText covers a long press; this covers the
          // ordinary case.
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied')),
              );
            },
            icon: Icon(
              Icons.copy_rounded,
              size: 18,
              color: AppColors.whiteAlpha(0.5),
            ),
            tooltip: 'Copy $label',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
