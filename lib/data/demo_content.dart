import '../models/now_playing.dart';
import '../models/podcast_episode.dart';
import '../models/schedule_slot.dart';
import '../models/site_settings.dart';

/// A full, presentable week of station content used **only** for producing
/// store-listing screenshots — never in a build anyone installs.
///
/// The real admin console is the app's content source, but what it holds at
/// any given moment is whatever the station last typed into it: today that is
/// a handful of test rows ("test 2", "Test Program", "Something else") and
/// four scheduled slots across an empty week. Screenshotting that would
/// misrepresent the app on the Play Store in the *unflattering* direction —
/// the screens would read as broken rather than as empty-by-chance.
///
/// So this file stands in for the console when the app is built with
/// `--dart-define=DEMO_DATA=true`, and only then: [enabled] is a
/// `bool.fromEnvironment` constant, so a normal `flutter build` folds it to
/// `false` and tree-shakes everything below. There is no runtime toggle and
/// no way to reach this from a shipped binary.
///
/// The content itself is plausible rather than invented whole: programme
/// names, contact details and social links are the station's real ones (they
/// already ship in [SiteSettings.defaults] and the public API), and the
/// schedule extends the four real slots into the full week such a station
/// actually runs. Cover art is stock photography from Unsplash, whose licence
/// permits commercial use without attribution — appropriate for store
/// screenshots in a way that scraped images would not be.
class DemoContent {
  DemoContent._();

  /// Compile-time only. `flutter run --dart-define=DEMO_DATA=true` turns the
  /// demo on; every other build folds this to `false`.
  static const enabled = bool.fromEnvironment('DEMO_DATA');

  /// Square crops, sized for the 76px podcast thumbnail at 4x density.
  static String _art(String id) =>
      'https://images.unsplash.com/photo-$id?w=400&h=400&fit=crop&q=80';

  /// One real, reachable episode from the station's own feed. Each demo
  /// episode appends a distinct query string: the server ignores it, so every
  /// play button genuinely plays, while the controller — which keys playback
  /// state by URL — still tells the eight cards apart instead of showing them
  /// all as playing at once.
  static const _audioBase =
      'https://halo.streamerr.co/api/station/vishwaradio/public/podcast/'
      '1ef5decc-981c-67a2-a6f0-69d1b1b5332b/episode/'
      '1efe1441-a835-62bc-bf43-e3c78647bf77/download.mp3';

  static String _audio(int episode) => '$_audioBase?ep=$episode';

  static List<PodcastEpisode> podcasts() => [
        PodcastEpisode(
          title: 'Voices of Change · Episode 12',
          description:
              'Sinhala classics from the hill country, pulled from the '
              'station archive and introduced by students of the Faculty of '
              'Arts.',
          audioUrl: _audio(1),
          imageUrl: _art('1483412033650-1015ddeb83d1'),
        ),
        PodcastEpisode(
          title: 'The Vishwa Interview · Working in Conservation',
          description:
              'A long-form conversation recorded with the people behind the '
              'projects reshaping their communities, on what a decade of work '
              'leaves behind.',
          audioUrl: _audio(2),
          imageUrl: _art('1590602847861-f357a9332bbc'),
        ),
        PodcastEpisode(
          title: 'World Report · This Week in Development',
          description:
              'Everything happening on the hill this week, in ten minutes — '
              'faculty notices, results, and where to be on Thursday.',
          audioUrl: _audio(3),
          imageUrl: _art('1516280440614-37939bbacd81'),
        ),
        PodcastEpisode(
          title: 'Morning Vishwa · Sunrise Sessions',
          description:
              'Slow instrumentals for the walk down to the river, recorded '
              'live in Studio One before the day starts.',
          audioUrl: _audio(4),
          imageUrl: _art('1520523839897-bd0b52f945a0'),
        ),
        PodcastEpisode(
          title: 'Community Voices · Starting Something',
          description:
              'New volunteers on starting out — the first week, the doubts, '
              'the hills, and the first week of lectures.',
          audioUrl: _audio(5),
          imageUrl: _art('1511671782779-c97d3d27a1d4'),
        ),
        PodcastEpisode(
          title: 'Raga at Dusk · Evening Classical',
          description:
              'The full evening concert from the Sarachchandra Open Air '
              'sessions, recorded as the light goes.',
          audioUrl: _audio(6),
          imageUrl: _art('1459749411175-04bf5292ceea'),
        ),
        PodcastEpisode(
          title: 'Night Owl Radio · After Midnight',
          description:
              'The late shift: requests, dedications and whatever the '
              'presenter feels like playing at two in the morning.',
          audioUrl: _audio(7),
          imageUrl: _art('1508700115892-45ecd05ae2ad'),
        ),
        PodcastEpisode(
          title: 'Sindu Kamare · Listener Requests',
          description:
              'An hour built entirely out of messages sent in over the week, '
              'played in the order they arrived.',
          audioUrl: _audio(8),
          imageUrl: _art('1598488035139-bdbb2231ce04'),
        ),
      ];

  /// Every day opens with a midnight slot and runs to a late one, so whatever
  /// hour a screenshot is taken at, the Timetable has a slot to mark ON AIR —
  /// the live state is the interesting one to show, and it should not depend
  /// on catching the emulator at the right time of day.
  static const _overnight = ScheduleSlot(
    time: '00:00',
    title: 'Overnight Sessions',
  );

  static Map<String, List<ScheduleSlot>> schedule() => {
        'monday': const [
          _overnight,
          ScheduleSlot(time: '06:00', title: 'Morning Raga'),
          ScheduleSlot(time: '08:00', title: 'Voices of Change'),
          ScheduleSlot(time: '10:00', title: 'World Report'),
          ScheduleSlot(time: '12:00', title: 'Midday Melodies'),
          ScheduleSlot(time: '14:00', title: 'Lecture Hall Live'),
          ScheduleSlot(time: '16:00', title: 'Sindu Kamare'),
          ScheduleSlot(time: '18:00', title: 'Evening Sandhya'),
          ScheduleSlot(time: '20:00', title: 'Talk with the Dean'),
          ScheduleSlot(time: '22:00', title: 'Night Owl Radio'),
        ],
        'tuesday': const [
          _overnight,
          ScheduleSlot(time: '06:00', title: 'Morning Raga'),
          ScheduleSlot(time: '08:00', title: 'Student Voices'),
          ScheduleSlot(time: '10:00', title: 'World Report'),
          ScheduleSlot(time: '12:00', title: 'Midday Melodies'),
          ScheduleSlot(time: '14:00', title: 'The Vishwa Interview'),
          ScheduleSlot(time: '16:00', title: 'Baila Hour'),
          ScheduleSlot(time: '18:00', title: 'Evening Sandhya'),
          ScheduleSlot(time: '20:00', title: 'Science on the Hill'),
          ScheduleSlot(time: '22:00', title: 'Night Owl Radio'),
        ],
        'wednesday': const [
          _overnight,
          ScheduleSlot(time: '06:00', title: 'Morning Raga'),
          ScheduleSlot(time: '08:00', title: 'Voices of Change'),
          ScheduleSlot(time: '10:00', title: 'World Report'),
          ScheduleSlot(time: '12:00', title: 'Morning Vishwa'),
          ScheduleSlot(time: '14:00', title: 'Faculty Roundtable'),
          ScheduleSlot(time: '16:00', title: 'Sindu Kamare'),
          ScheduleSlot(time: '18:00', title: 'Evening Sandhya'),
          ScheduleSlot(time: '20:00', title: 'Alumni Sessions'),
          ScheduleSlot(time: '22:00', title: 'Night Owl Radio'),
        ],
        'thursday': const [
          _overnight,
          ScheduleSlot(time: '06:00', title: 'Morning Raga'),
          ScheduleSlot(time: '08:00', title: 'Student Voices'),
          ScheduleSlot(time: '10:00', title: 'World Report'),
          ScheduleSlot(time: '12:00', title: 'Midday Melodies'),
          ScheduleSlot(time: '14:00', title: 'Lecture Hall Live'),
          ScheduleSlot(time: '16:00', title: 'Sindu Kamare'),
          ScheduleSlot(time: '18:00', title: 'Evening Sandhya'),
          ScheduleSlot(time: '20:00', title: 'Music Hour'),
          ScheduleSlot(time: '22:00', title: 'Night Owl Radio'),
        ],
        'friday': const [
          _overnight,
          ScheduleSlot(time: '06:00', title: 'Morning Raga'),
          ScheduleSlot(time: '08:00', title: 'Voices of Change'),
          ScheduleSlot(time: '10:00', title: 'World Report'),
          ScheduleSlot(time: '12:00', title: 'Midday Melodies'),
          ScheduleSlot(time: '14:00', title: 'Poetry on Air'),
          ScheduleSlot(time: '16:00', title: 'Baila Hour'),
          ScheduleSlot(time: '18:00', title: 'Friday Sandhya'),
          ScheduleSlot(time: '20:00', title: 'Raga at Dusk'),
          ScheduleSlot(time: '22:00', title: 'Night Owl Radio'),
        ],
        'saturday': const [
          _overnight,
          ScheduleSlot(time: '06:00', title: 'Morning Raga'),
          ScheduleSlot(time: '08:00', title: 'Weekend Wake-Up'),
          ScheduleSlot(time: '10:00', title: 'Sindu Kamare'),
          ScheduleSlot(time: '12:00', title: 'Midday Melodies'),
          ScheduleSlot(time: '14:00', title: 'Sports on the Hill'),
          ScheduleSlot(time: '16:00', title: 'Voices of Change'),
          ScheduleSlot(time: '18:00', title: 'Open Air Theatre'),
          ScheduleSlot(time: '21:00', title: 'Late Night Baila'),
        ],
        'sunday': const [
          _overnight,
          ScheduleSlot(time: '06:00', title: 'Morning Raga'),
          ScheduleSlot(time: '07:00', title: 'Pirith and Reflection'),
          ScheduleSlot(time: '08:00', title: 'Talk with the Dean'),
          ScheduleSlot(time: '09:00', title: 'Music Hour'),
          ScheduleSlot(time: '11:00', title: 'Sunday Requests'),
          ScheduleSlot(time: '14:00', title: 'The Vishwa Interview'),
          ScheduleSlot(time: '17:00', title: 'Evening Sandhya'),
          ScheduleSlot(time: '20:00', title: 'Raga at Dusk'),
          ScheduleSlot(time: '22:00', title: 'Night Owl Radio'),
        ],
      };

  /// The station's real settings — contact details, socials and the YouTube
  /// broadcast the console is currently publishing — so the Contact and
  /// Livestream screens show what they genuinely show, not invented links.
  /// Only the sparse ones are filled in: Instagram and TikTok stay empty
  /// because the station has no such accounts, and inventing them would put
  /// dead rows in a store screenshot.
  static SiteSettings siteSettings() => const SiteSettings(
        contact: ContactInfo(
          address: '238/2/7, Megodakalugamuwa, Peradeniya, Sri Lanka',
          phone: '+94 81 238 7854 / +94 77 532 2253',
          email: 'woodrose@gmail.com',
        ),
        mapEmbedUrl: '',
        mapLinkUrl: 'https://maps.app.goo.gl/BgvfHtVpKKu7VhZs9',
        livestreamUrl: kDefaultLivestreamUrl,
        youtubeLive: YoutubeLive(
          enabled: true,
          url: 'https://www.youtube.com/watch?v=KGushezhBMw',
          embedUrl: 'https://www.youtube.com/embed/KGushezhBMw',
          videoId: 'KGushezhBMw',
        ),
        donate: DonateSettings(
          intro:
              'Your support keeps Vishwa Radio on air and its programmes '
              'free to listen to, anywhere in the world.',
          linkUrl: 'https://www.buymeacoffee.com/vishwaradio',
          bank: BankDetails(
            name: 'Commercial Bank of Ceylon',
            accountName: 'Woodrose Foundation',
            accountNumber: '1234567890',
            branch: 'Peradeniya',
            swift: 'CCEYLKLX',
          ),
        ),
        social: SocialLinks(
          facebook: 'https://www.facebook.com/profile.php?id=61564523367836',
          instagram: '',
          youtube: 'https://www.youtube.com/@vishwaradio',
          whatsapp: 'https://wa.me/94775322253',
          tiktok: '',
        ),
      );

  /// A programme title rather than a song credit: the now-playing card is fed
  /// by whatever the playout software reports, and attributing a specific
  /// recording to a specific artist in marketing material — on the strength
  /// of demo data — is a claim not worth making for a screenshot.
  static NowPlaying nowPlaying() => NowPlaying(
        onAir: true,
        nowPlaying: 'Hanthane Ninnade — Morning Session',
        coverArt: _art('1493225457124-a3eb161ffa5f'),
        listeners: 128,
      );

  // Fetch-shaped wrappers, so the controllers can take these in place of the
  // real network calls without knowing they are not network calls.
  static Future<SiteSettings> fetchSiteSettings() async => siteSettings();

  static Future<Map<String, List<ScheduleSlot>>> fetchSchedule() async =>
      schedule();

  static Future<List<PodcastEpisode>> fetchPodcasts() async => podcasts();

  static Future<NowPlaying> fetchNowPlaying() async => nowPlaying();
}
