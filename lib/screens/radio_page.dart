import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/now_playing.dart';
import '../navigation/app_routes.dart';
import '../services/now_playing_controller.dart';
import '../services/radio_player_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/eq_bars.dart';
import '../widgets/hamburger_button.dart';
import '../widgets/live_badge.dart';
import '../widgets/ticker_marquee.dart';

class RadioPage extends StatelessWidget {
  const RadioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeLabel: 'Radio',
      onSelect: (label) => AppRoutes.navigateToLabel(context, label),
      builder: (context, openDrawer) => _RadioBody(openDrawer: openDrawer),
    );
  }
}

class _RadioBody extends StatelessWidget {
  final VoidCallback openDrawer;

  const _RadioBody({required this.openDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.radioBackground),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              // Stack (not a 3-child Row) so the wordmark sits on the true
              // horizontal centre rather than being nudged off it by the
              // differing widths of the hamburger and the LIVE pill.
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HamburgerButton(onTap: openDrawer),
                      const LivePill(),
                    ],
                  ),
                  Image.asset('assets/woodrose-logo-light.png', height: 58),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(gradient: AppGradients.ticker),
              child: TickerMarquee(
                text: AppData.tickerText,
                style: AppText.mono(
                    size: 11,
                    weight: FontWeight.w400,
                    color: AppColors.tickerText,
                    letterSpacing: 2),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          // Paired with the crest's 78px bottom gap below: the
                          // column is centre-aligned, so growing that gap and
                          // this padding by the same amount lifts the crest
                          // while leaving the controls where they are.
                          padding: const EdgeInsets.only(bottom: 62),
                          child: ListenableBuilder(
                            listenable: Listenable.merge([
                              RadioPlayerController.instance,
                              NowPlayingController.instance,
                            ]),
                            builder: (context, _) {
                              final playing =
                                  RadioPlayerController.instance.isPlaying;
                              final track =
                                  NowPlayingController.instance.current;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/vishwa-radio-light.png',
                                    width: 236,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 78),
                                  Text(
                                    playing
                                        ? 'ON AIR — STREAMING'
                                        : 'TAP TO TUNE IN',
                                    style: AppText.mono(
                                        size: 11,
                                        weight: FontWeight.w700,
                                        color: AppColors.signal,
                                        letterSpacing: 4),
                                  ),
                                  const SizedBox(height: 20),
                                  _NowPlayingCard(track: track),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      EqBarsRow(playing: playing),
                                      const SizedBox(width: 18),
                                      _PlayButton(
                                          playing: playing,
                                          onTap: RadioPlayerController
                                              .instance.toggle),
                                      const SizedBox(width: 18),
                                      EqBarsRow(
                                          playing: playing, mirrored: true),
                                    ],
                                  ),
                                  const SizedBox(height: 34),
                                  Text(
                                    'Woodrose Foundation',
                                    style: AppText.archivo(
                                        size: 15,
                                        weight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Global community radio, amplifying positive change',
                                    style: AppText.archivo(
                                        size: 12,
                                        weight: FontWeight.w400,
                                        color: AppColors.whiteAlpha(0.45)),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cover art, title and listener count for whatever is on the stream.
///
/// Collapses to nothing when there is no title. An unconfigured console, an
/// unreachable Streamerr and a silent stream are indistinguishable from here,
/// and none of them deserve an empty card in the middle of the screen — the
/// play button above still works either way. Height is fixed so the controls
/// below don't jump when a track arrives or the card disappears.
class _NowPlayingCard extends StatelessWidget {
  final NowPlaying track;

  const _NowPlayingCard({required this.track});

  @override
  Widget build(BuildContext context) {
    if (!track.hasTrack) return const SizedBox(height: 56);

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withValues(alpha: 0.22),
        border: Border.all(color: AppColors.whiteAlpha(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (track.coverArt.isNotEmpty)
            ClipOval(
              child: Image.network(
                track.coverArt,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                // Artwork hosts fail independently of the stream; a broken
                // image beside a valid title looks worse than no image.
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          if (track.coverArt.isNotEmpty) const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOW PLAYING',
                  style: AppText.mono(
                      size: 8,
                      weight: FontWeight.w700,
                      color: AppColors.signalAlpha(0.75),
                      letterSpacing: 2),
                ),
                const SizedBox(height: 3),
                Text(
                  track.nowPlaying,
                  maxLines: 1,
                  // Titles arrive unedited from the playout software and can be
                  // long, or a raw filename. Clip rather than wrap.
                  overflow: TextOverflow.ellipsis,
                  style: AppText.archivo(
                      size: 13,
                      weight: FontWeight.w500,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          if (track.listeners > 0) ...[
            const SizedBox(width: 12),
            Text(
              '${track.listeners}',
              style: AppText.mono(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.whiteAlpha(0.7)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.headphones_rounded,
                size: 13, color: AppColors.whiteAlpha(0.55)),
          ],
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool playing;
  final VoidCallback onTap;

  const _PlayButton({required this.playing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 118,
        height: 118,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Flat bone rather than crest gold: gold belongs to the crest above,
          // and a second gold mass this size wins the eye off it. Still a solid
          // disc, not a gradient orb — the shadow is only enough to lift it off
          // the maroon field, not a bloom halo.
          color: AppColors.playButtonFill,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 6))
          ],
        ),
        alignment: Alignment.center,
        child: playing
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PauseBar(),
                  SizedBox(width: 8),
                  _PauseBar(),
                ],
              )
            : const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Icon(Icons.play_arrow_rounded,
                    size: 44, color: Colors.white),
              ),
      ),
    );
  }
}

class _PauseBar extends StatelessWidget {
  const _PauseBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 34,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(3)),
    );
  }
}
