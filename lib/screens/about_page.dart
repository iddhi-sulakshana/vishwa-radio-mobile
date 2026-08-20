import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../services/admin_content_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  /// Taken from the website's About page. The reference app listed the
  /// university's founding dates here; Vishwa has no comparable documented
  /// timeline, and inventing one would be fabrication — so this carries the
  /// languages the station actually broadcasts in.
  static const _history = [
    'Sinhala · news, talk shows, cultural programmes and music',
    'Tamil · current affairs, entertainment and cultural shows',
    'English · global news, interviews and contemporary discussion',
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeLabel: 'About',
      onSelect: (label) => AppRoutes.navigateToLabel(context, label),
      builder: (context, openDrawer) => Container(
        decoration: const BoxDecoration(gradient: AppGradients.section),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SectionHeader(title: 'About', onMenuTap: openDrawer),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  children: [
                    const _StatsRow(),
                    const SizedBox(height: 24),
                    Text(
                      'Vishwa Radio, an initiative by the Woodrose '
                      'Foundation, is a global broadcasting platform '
                      'dedicated to amplifying positive change and uniting '
                      'communities worldwide through impactful audio and '
                      'video content.',
                      style: AppText.archivo(
                        size: 14,
                        weight: FontWeight.w400,
                        color: AppColors.whiteAlpha(0.75),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ..._history.map(
                      (h) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.only(left: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: AppColors.orbit, width: 3.0)),
                        ),
                        child: Text(
                          h,
                          style: AppText.mono(
                              size: 12,
                              weight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'We are a platform for organisations and individuals '
                      'to share their achievements and their visions for a '
                      'better world — feature stories on projects and '
                      'initiatives, community events, and the personal '
                      'experiences behind them, across education, health, '
                      'the environment and the arts.',
                      style: AppText.archivo(
                        size: 14,
                        weight: FontWeight.w400,
                        color: AppColors.whiteAlpha(0.75),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Our mission is to bring diverse voices together, '
                      'sharing stories that inspire, educate and drive '
                      'social and environmental progress — amplifying '
                      'underrepresented voices and promoting inclusivity '
                      'across every corner of the world.',
                      style: AppText.archivo(
                        size: 14,
                        weight: FontWeight.w400,
                        color: AppColors.whiteAlpha(0.75),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.whiteAlpha(0.04),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/woodrose-logo-light.png',
                              height: 40),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IN PARTNERSHIP WITH',
                                  style: AppText.mono(
                                      size: 10,
                                      weight: FontWeight.w700,
                                      color: AppColors.orbit,
                                      letterSpacing: 1),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Woodrose Foundation',
                                  style: AppText.archivo(
                                      size: 15,
                                      weight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The figures at the top of the page. Both are things the app can actually
/// stand behind: the station broadcasts in three languages, which the website
/// states; the programme count is counted from the schedule the admin
/// publishes, and the tile is simply absent until there is a schedule to
/// count. Nothing here is estimated. The reference app opened with a founding
/// year, and Vishwa has no documented equivalent — a plausible-looking date
/// on an About screen is a fabrication, not a placeholder.
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminContentController.instance,
      builder: (context, _) {
        final programmes = AdminContentController.instance.schedule.values
            .fold<int>(0, (total, day) => total + day.length);
        return Row(
          children: [
            // The reference app opened with the university's founding year.
            // There is no documented Vishwa equivalent, and a made-up date on
            // an About screen is worse than one fewer tile — so the counts
            // here are only ever real, fetched numbers.
            const Expanded(
              child: _StatTile(value: '3', label: 'LANGUAGES'),
            ),
            if (programmes > 0)
              Expanded(
                child: _StatTile(
                  value: '$programmes',
                  label: 'WEEKLY PROGRAMMES',
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(value,
              style: AppText.archivo(
                  size: 22, weight: FontWeight.w800, color: AppColors.orbit)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.mono(
                size: 8,
                weight: FontWeight.w400,
                color: AppColors.whiteAlpha(0.5),
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
