import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/models/podcast_episode.dart';
import 'package:vishwa_radio/models/schedule_slot.dart';
import 'package:vishwa_radio/models/site_settings.dart';
import 'package:vishwa_radio/services/admin_content_controller.dart';

void main() {
  test('init() marks every section ready and stores the fetched data',
      () async {
    final controller = AdminContentController.forTesting(
      fetchSiteSettings: () async => SiteSettings.defaults(),
      fetchSchedule: () async => {
        'monday': const [ScheduleSlot(time: '10:00', title: 'Test Show')],
      },
      fetchPodcasts: () async => const [
        PodcastEpisode(
          title: 'Ep 1',
          description: '',
          audioUrl: 'https://a.mp3',
          imageUrl: '',
        ),
      ],
    );

    await controller.init();

    expect(controller.settingsStatus, ContentStatus.ready);
    expect(controller.scheduleStatus, ContentStatus.ready);
    expect(controller.podcastsStatus, ContentStatus.ready);
    expect(controller.schedule['monday']!.single.title, 'Test Show');
    expect(controller.podcasts.single.title, 'Ep 1');
  });

  test('a failed fetch marks that section as error and keeps defaults',
      () async {
    final controller = AdminContentController.forTesting(
      fetchSiteSettings: () async => throw Exception('network down'),
      fetchSchedule: () async => {'monday': const <ScheduleSlot>[]},
      fetchPodcasts: () async => const [],
    );

    await controller.init();

    expect(controller.settingsStatus, ContentStatus.error);
    expect(
      controller.siteSettings.livestreamUrl,
      SiteSettings.defaults().livestreamUrl,
    );
    expect(controller.scheduleStatus, ContentStatus.ready);
  });

  test('notifies listeners as each section settles', () async {
    var notifications = 0;
    final controller = AdminContentController.forTesting(
      fetchSiteSettings: () async => SiteSettings.defaults(),
      fetchSchedule: () async => {'monday': const <ScheduleSlot>[]},
      fetchPodcasts: () async => const [],
    );
    controller.addListener(() => notifications++);

    await controller.init();

    expect(notifications, greaterThanOrEqualTo(3));
  });
}
