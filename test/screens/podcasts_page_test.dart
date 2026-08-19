import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/models/podcast_episode.dart';
import 'package:vishwa_radio/navigation/app_routes.dart';
import 'package:vishwa_radio/screens/podcasts_page.dart';
import 'package:vishwa_radio/services/admin_content_controller.dart';

void main() {
  setUp(() {
    AdminContentController.instance.podcasts = const [
      PodcastEpisode(
        title: 'Ep 1',
        description: 'First episode',
        audioUrl: 'https://a.mp3',
        imageUrl: '',
      ),
    ];
  });

  testWidgets('lists fetched episodes with title and description',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: const PodcastsPage(), routes: AppRoutes.table),
    );

    expect(find.text('Ep 1'), findsOneWidget);
    expect(find.text('First episode'), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no episodes',
      (tester) async {
    AdminContentController.instance.podcasts = const [];

    await tester.pumpWidget(
      MaterialApp(home: const PodcastsPage(), routes: AppRoutes.table),
    );

    expect(find.text('No episodes yet — check back soon.'), findsOneWidget);
  });
}
