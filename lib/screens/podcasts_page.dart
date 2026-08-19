import 'package:flutter/material.dart';

import '../models/podcast_episode.dart';
import '../navigation/app_routes.dart';
import '../services/admin_content_controller.dart';
import '../services/podcast_player_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/diagonal_stripes.dart';
import '../widgets/section_header.dart';

class PodcastsPage extends StatelessWidget {
  const PodcastsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeLabel: 'Podcasts',
      onSelect: (label) => AppRoutes.navigateToLabel(context, label),
      builder: (context, openDrawer) => Container(
        decoration: const BoxDecoration(gradient: AppGradients.section),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SectionHeader(title: 'Podcasts', onMenuTap: openDrawer),
              Expanded(
                child: ListenableBuilder(
                  listenable: AdminContentController.instance,
                  builder: (context, _) {
                    final episodes = AdminContentController.instance.podcasts;

                    if (episodes.isEmpty) {
                      return Center(
                        child: Text(
                          'No episodes yet — check back soon.',
                          style: AppText.archivo(
                              size: 13,
                              weight: FontWeight.w400,
                              color: AppColors.whiteAlpha(0.5)),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                      itemCount: episodes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _PodcastCard(episode: episodes[i]),
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

class _PodcastCard extends StatelessWidget {
  final PodcastEpisode episode;

  const _PodcastCard({required this.episode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteAlpha(0.04),
        border: Border.all(color: AppColors.whiteAlpha(0.07)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: episode.imageUrl.isEmpty
                ? const _CoverArtPlaceholder()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      episode.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const _CoverArtPlaceholder(),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  style: AppText.archivo(
                      size: 14,
                      weight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3),
                ),
                const SizedBox(height: 3),
                Text(
                  episode.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.archivo(
                      size: 11,
                      weight: FontWeight.w400,
                      color: AppColors.whiteAlpha(0.45)),
                ),
              ],
            ),
          ),
          // An episode the admin left without audio gets no control at all,
          // rather than a button that cannot do anything.
          if (episode.audioUrl.isNotEmpty) ...[
            const SizedBox(width: 8),
            ListenableBuilder(
              listenable: PodcastPlayerController.instance,
              builder: (context, _) => _PlayCircle(
                state: PodcastPlayerController.instance
                    .stateFor(episode.audioUrl),
                onTap: () => PodcastPlayerController.instance.toggle(episode),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayCircle extends StatelessWidget {
  final PodcastPlaybackState state;
  final VoidCallback onTap;

  const _PlayCircle({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, gradient: AppGradients.button),
        alignment: Alignment.center,
        child: switch (state) {
          PodcastPlaybackState.loading => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
          PodcastPlaybackState.playing =>
            const Icon(Icons.pause_rounded, size: 20, color: Colors.white),
          PodcastPlaybackState.idle => const Padding(
              padding: EdgeInsets.only(left: 2),
              child: Icon(Icons.play_arrow_rounded,
                  size: 20, color: Colors.white),
            ),
        },
      ),
    );
  }
}

class _CoverArtPlaceholder extends StatelessWidget {
  const _CoverArtPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DiagonalStripes(
      borderRadius: BorderRadius.circular(12),
      child: Text(
        'cover\nart',
        textAlign: TextAlign.center,
        style: AppText.mono(
            size: 8, weight: FontWeight.w400, color: AppColors.whiteAlpha(0.4)),
      ),
    );
  }
}
