import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/models/site_settings.dart';
import 'package:vishwa_radio/services/admin_api_service.dart';

void main() {
  group('parseSiteSettings', () {
    test('reads a well-formed payload', () {
      final settings = parseSiteSettings({
        'contact': {'address': 'Addr', 'phone': '+94', 'email': 'a@b.com'},
        'location': {'mapEmbedUrl': 'embed', 'mapLinkUrl': 'link'},
        'streaming': {'livestreamUrl': 'https://stream.example/live'},
        'social': {
          'facebook': 'https://fb.example',
          'instagram': '',
          'youtube': '',
          'whatsapp': '',
          'tiktok': '',
        },
      });

      expect(settings.contact.email, 'a@b.com');
      expect(settings.livestreamUrl, 'https://stream.example/live');
      expect(settings.social.facebook, 'https://fb.example');
    });

    test('falls back to the default stream url when it is empty', () {
      final settings = parseSiteSettings({
        'streaming': {'livestreamUrl': ''},
      });
      expect(
        settings.livestreamUrl,
        kDefaultLivestreamUrl,
      );
    });

    test('does not crash on a missing/malformed payload', () {
      final settings = parseSiteSettings({});
      expect(settings.contact.email, '');
      expect(
        settings.livestreamUrl,
        kDefaultLivestreamUrl,
      );
    });

    group('youtubeLive', () {
      test('reads a live broadcast', () {
        final settings = parseSiteSettings({
          'streaming': {
            'livestreamUrl': 'https://stream.example/live',
            'youtubeLive': {
              'enabled': true,
              'url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
              'embedUrl': 'https://www.youtube.com/embed/dQw4w9WgXcQ',
              'videoId': 'dQw4w9WgXcQ',
            },
          },
        });

        expect(settings.youtubeLive.enabled, isTrue);
        expect(settings.youtubeLive.videoId, 'dQw4w9WgXcQ');
        expect(settings.youtubeLive.canEmbed, isTrue);
      });

      test('reads a channel broadcast as live but not embeddable', () {
        final settings = parseSiteSettings({
          'streaming': {
            'youtubeLive': {
              'enabled': true,
              'url': 'https://www.youtube.com/channel/UC123/live',
              'embedUrl':
                  'https://www.youtube.com/embed/live_stream?channel=UC123',
              'videoId': '',
            },
          },
        });

        expect(settings.youtubeLive.enabled, isTrue);
        expect(settings.youtubeLive.canEmbed, isFalse);
        expect(settings.youtubeLive.url, isNotEmpty);
      });

      test('is off air when the console sends no youtubeLive block at all', () {
        // An admin console deployed before this feature existed.
        final settings = parseSiteSettings({
          'streaming': {'livestreamUrl': 'https://stream.example/live'},
        });

        expect(settings.youtubeLive.enabled, isFalse);
      });

      test('is off air when enabled arrives without an embed url', () {
        final settings = parseSiteSettings({
          'streaming': {
            'youtubeLive': {'enabled': true, 'embedUrl': ''},
          },
        });

        expect(settings.youtubeLive.enabled, isFalse);
      });

      test('is off air when enabled is not a real boolean', () {
        final settings = parseSiteSettings({
          'streaming': {
            'youtubeLive': {
              'enabled': 'yes',
              'embedUrl': 'https://www.youtube.com/embed/dQw4w9WgXcQ',
            },
          },
        });

        expect(settings.youtubeLive.enabled, isFalse);
      });
    });
  });

  group('parseSchedule', () {
    test('reads slots for the days that have them and empties the rest', () {
      final week = parseSchedule({
        'days': {
          'monday': [
            {'time': '10:00', 'title': 'Morning Raha'},
          ],
          'saturday': [
            {'time': '20:00', 'title': 'Morning Raaga'},
            {'time': '21:00', 'title': 'Test Program'},
          ],
        },
      });

      expect(week['monday']!.single.title, 'Morning Raha');
      expect(week['saturday']!.length, 2);
      expect(week['tuesday'], isEmpty);
    });

    test('drops a slot missing time or title, and never crashes on garbage',
        () {
      final week = parseSchedule({
        'days': {
          'monday': [
            {'time': '10:00'},
            {'title': 'No time'},
            'not-a-map',
          ],
        },
      });

      expect(week['monday'], isEmpty);
    });

    test('returns a fully empty week for a malformed payload', () {
      final week = parseSchedule({});
      expect(week.keys, hasLength(7));
      expect(week.values.every((slots) => slots.isEmpty), true);
    });
  });

  group('parsePodcasts', () {
    test('reads episodes with a title and audio url', () {
      final episodes = parsePodcasts({
        'episodes': [
          {
            'title': 'Ep 1',
            'description': 'd',
            'audioUrl': 'https://a.mp3',
            'imageUrl': 'https://a.png',
          },
        ],
      });

      expect(episodes.single.title, 'Ep 1');
    });

    test('drops an episode missing a title or audio url', () {
      final episodes = parsePodcasts({
        'episodes': [
          {'title': '', 'audioUrl': 'https://a.mp3'},
          {'title': 'No audio', 'audioUrl': ''},
        ],
      });

      expect(episodes, isEmpty);
    });

    test('returns an empty list for a malformed payload', () {
      expect(parsePodcasts({}), isEmpty);
    });
  });

  group('donate parsing', () {
    test('reads a full donate block', () {
      final settings = parseSiteSettings({
        'donate': {
          'intro': 'Support our work',
          'linkUrl': 'https://www.buymeacoffee.com/vishwaradio',
          'bank': {
            'name': 'Commercial Bank',
            'accountName': 'Woodrose Foundation',
            'accountNumber': '1234567890',
            'branch': 'Peradeniya',
            'swift': 'CCEYLKLX',
          },
        },
      });

      expect(settings.donate.intro, 'Support our work');
      expect(settings.donate.linkUrl, 'https://www.buymeacoffee.com/vishwaradio');
      expect(settings.donate.bank.isComplete, isTrue);
      expect(settings.donate.bank.swift, 'CCEYLKLX');
    });

    // A console deployed before the donate columns existed sends no block at
    // all. That must read as "nothing to show", not as a crash.
    test('treats a missing donate block as empty', () {
      final settings = parseSiteSettings(<String, dynamic>{});
      expect(settings.donate.intro, isEmpty);
      expect(settings.donate.linkUrl, isEmpty);
      expect(settings.donate.bank.isComplete, isFalse);
    });

    test('treats a malformed donate block as empty', () {
      final settings = parseSiteSettings({'donate': 'not-an-object'});
      expect(settings.donate.bank.isComplete, isFalse);
    });

    test('treats a malformed bank block as empty', () {
      final settings = parseSiteSettings({
        'donate': {'intro': 'Support us', 'bank': 42},
      });
      expect(settings.donate.intro, 'Support us');
      expect(settings.donate.bank.isComplete, isFalse);
    });
  });
}
