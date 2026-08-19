import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/site_settings.dart';
import '../navigation/app_routes.dart';
import '../services/admin_content_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/diagonal_stripes.dart';
import '../widgets/section_header.dart';

/// Whether the station is live in vision, and on what, is the admin console's
/// call — this screen only renders the answer. Live and embeddable plays here;
/// live on a channel link (no video id to play) shows the badge and sends
/// people to YouTube; off air says so plainly rather than dressing up an empty
/// frame. The live audio stream is always one tap away either way.
class LivestreamsPage extends StatelessWidget {
  /// Builds the video player. Overridden in widget tests, where the real one
  /// would need a platform webview the test binding has no implementation for.
  final Widget Function(YoutubeLive live)? videoPlayerBuilder;

  const LivestreamsPage({super.key, this.videoPlayerBuilder});

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
      activeLabel: 'Livestream',
      onSelect: (label) => AppRoutes.navigateToLabel(context, label),
      builder: (context, openDrawer) => Container(
        decoration: const BoxDecoration(gradient: AppGradients.section),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SectionHeader(title: 'Livestreams', onMenuTap: openDrawer),
              Expanded(
                child: ListenableBuilder(
                  listenable: AdminContentController.instance,
                  builder: (context, _) {
                    final settings =
                        AdminContentController.instance.siteSettings;
                    final live = settings.youtubeLive;
                    final facebook = settings.social.facebook;

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                      children: [
                        if (live.enabled)
                          _LiveVideoCard(
                            live: live,
                            player: videoPlayerBuilder ?? _defaultPlayer,
                          )
                        else
                          const _NoVideoStreamCard(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'WHAT YOU CAN DO',
                            style: AppText.mono(
                                size: 11,
                                weight: FontWeight.w700,
                                color: AppColors.orbit,
                                letterSpacing: 2),
                          ),
                        ),
                        if (live.enabled && live.url.isNotEmpty)
                          _ActionRow(
                            icon: Icons.open_in_new_rounded,
                            title: 'Watch on YouTube',
                            subtitle: live.canEmbed
                                ? 'Full screen, chat and casting'
                                : 'Opens the live broadcast',
                            primary: !live.canEmbed,
                            onTap: () => _open(context, live.url),
                          ),
                        _ActionRow(
                          icon: Icons.play_arrow_rounded,
                          title: 'Listen to the live audio stream',
                          subtitle: 'Opens the Radio screen',
                          primary: !live.enabled,
                          // Replaces the route rather than stacking on it, so
                          // the drawer keeps behaving like a side-nav switch.
                          onTap: () =>
                              AppRoutes.navigateToLabel(context, 'Radio'),
                        ),
                        if (facebook.isNotEmpty)
                          _ActionRow(
                            icon: Icons.campaign_rounded,
                            title: 'Follow on Facebook',
                            subtitle: 'Where video streams are announced',
                            onTap: () => _open(context, facebook),
                          ),
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

Widget _defaultPlayer(YoutubeLive live) =>
    _YoutubeLivePlayer(videoId: live.videoId);

/// Owns the player controller for as long as the card is on screen. Separate
/// from the card so the webview is created once and torn down with it.
class _YoutubeLivePlayer extends StatefulWidget {
  final String videoId;

  const _YoutubeLivePlayer({required this.videoId});

  @override
  State<_YoutubeLivePlayer> createState() => _YoutubeLivePlayerState();
}

class _YoutubeLivePlayerState extends State<_YoutubeLivePlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      // Deliberately not autoplay: this is a video stream on someone's mobile
      // data, so starting it is their decision.
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void didUpdateWidget(_YoutubeLivePlayer old) {
    super.didUpdateWidget(old);
    // The console can switch broadcasts while the screen is open.
    if (old.videoId != widget.videoId) {
      _controller.cueVideoById(videoId: widget.videoId);
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(controller: _controller, aspectRatio: 16 / 9);
  }
}

class _LiveVideoCard extends StatelessWidget {
  final YoutubeLive live;
  final Widget Function(YoutubeLive live) player;

  const _LiveVideoCard({required this.live, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.orbitAlpha(0.35)),
        color: AppColors.whiteAlpha(0.03),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The badge sits in the caption below rather than floating over the
          // video: anything Flutter paints on top of the platform view is
          // hidden by it, the same way the nav drawer was.
          AspectRatio(
            aspectRatio: 16 / 9,
                // A channel link carries no video id, so there is nothing the
                // in-app player can load — the stripes stand in for it and the
                // action below opens YouTube.
                child: live.canEmbed
                    ? Visibility(
                        // The player is an Android platform view, composited
                        // by Android rather than by Flutter, so it paints over
                        // the nav drawer and hides the top half of the menu.
                        // Off stage while the drawer is open fixes that;
                        // maintainState keeps the stream running underneath
                        // instead of reloading it on every peek at the menu.
                        visible: !DrawerVisibility.isOpenOf(context),
                        maintainState: true,
                        child: player(live),
                      )
                    : DiagonalStripes(
                        stripeWidth: 8,
                        child: Icon(Icons.smart_display_rounded,
                            size: 30, color: AppColors.whiteAlpha(0.4)),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _LiveBadge(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "We're live in vision",
                        style: AppText.archivo(
                            size: 15,
                            weight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  live.canEmbed
                      ? 'Streaming from our YouTube channel. Tap play to '
                          'watch here, or open it in YouTube for full screen '
                          'and chat.'
                      : 'Streaming from our YouTube channel. Open it in '
                          'YouTube to watch.',
                  style: AppText.archivo(
                      size: 12,
                      weight: FontWeight.w400,
                      color: AppColors.whiteAlpha(0.5),
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.liveRed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE',
            style: AppText.mono(
                size: 10,
                weight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }
}

class _NoVideoStreamCard extends StatelessWidget {
  const _NoVideoStreamCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.orbitAlpha(0.35)),
        color: AppColors.whiteAlpha(0.03),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: DiagonalStripes(
              stripeWidth: 8,
              child: Icon(Icons.videocam_off_rounded,
                  size: 30, color: AppColors.whiteAlpha(0.4)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video streams are announced on our channels',
                  style: AppText.archivo(
                      size: 15,
                      weight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3),
                ),
                const SizedBox(height: 6),
                Text(
                  'The station goes live on video only for the occasional '
                  'campus event. When it does, it plays right here. The live '
                  'audio stream is always on the Radio screen.',
                  style: AppText.archivo(
                      size: 12,
                      weight: FontWeight.w400,
                      color: AppColors.whiteAlpha(0.5),
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool primary;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
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
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: primary ? AppGradients.button : null,
                color: primary ? null : AppColors.orbitAlpha(0.12),
                border: primary
                    ? null
                    : Border.all(color: AppColors.orbitAlpha(0.3)),
              ),
              alignment: Alignment.center,
              child: Icon(icon,
                  size: 20,
                  color: primary ? Colors.white : AppColors.orbit),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppText.archivo(
                          size: 14,
                          weight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: AppText.archivo(
                          size: 11,
                          weight: FontWeight.w400,
                          color: AppColors.whiteAlpha(0.45))),
                ],
              ),
            ),
            Text('›',
                style: AppText.mono(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppColors.whiteAlpha(0.4))),
          ],
        ),
      ),
    );
  }
}
