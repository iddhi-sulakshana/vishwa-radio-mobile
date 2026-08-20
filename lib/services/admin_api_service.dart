import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/now_playing.dart';
import '../models/podcast_episode.dart';
import '../models/schedule_slot.dart';
import '../models/site_settings.dart';
import 'admin_config.dart';

/// Talks to the admin console's read-only `/api/public/*` endpoints — the
/// same three the website uses. Each fetch function throws on a network
/// failure or non-2xx response; callers (AdminContentController) decide the
/// fallback. Parsing is split into standalone top-level functions so it can
/// be unit-tested with hand-built maps, no network involved.

String _str(dynamic value) => value is String ? value : '';

/// An admin console deployed before the YouTube fields existed sends no
/// `youtubeLive` block, so anything missing or half-formed reads as off air
/// rather than as a player with nothing to play.
YoutubeLive _parseYoutubeLive(dynamic value) {
  final live = value as Map<String, dynamic>? ?? const {};
  final embedUrl = _str(live['embedUrl']);

  // The console already refuses to publish `enabled` without a usable embed;
  // checking again here just means a mangled payload can't get through.
  if (live['enabled'] != true || embedUrl.isEmpty) return YoutubeLive.offAir;

  return YoutubeLive(
    enabled: true,
    url: _str(live['url']),
    embedUrl: embedUrl,
    videoId: _str(live['videoId']),
  );
}

Future<Map<String, dynamic>> _getJson(String path) async {
  final response = await http.get(
    Uri.parse('${AdminConfig.baseUrl}$path'),
    headers: {'x-api-key': AdminConfig.apiKey},
  );

  if (response.statusCode != 200) {
    throw Exception('$path request failed (${response.statusCode})');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}

/// Reads the payload defensively — an old admin deployment or a proxy error
/// page shouldn't crash the app. Unlike the other fields, an empty
/// `livestreamUrl` falls back to the built-in default rather than staying
/// blank, so it can never silently break the play button.
/// A console deployed before the donate columns existed sends no `donate`
/// block, and a mangled payload could send something that is not an object.
/// Both read as "nothing to show" rather than throwing — same reasoning as
/// [_parseYoutubeLive].
DonateSettings _parseDonate(dynamic value) {
  final donate = value is Map<String, dynamic> ? value : const <String, dynamic>{};
  final bank =
      donate['bank'] is Map<String, dynamic>
          ? donate['bank'] as Map<String, dynamic>
          : const <String, dynamic>{};

  return DonateSettings(
    intro: _str(donate['intro']),
    linkUrl: _str(donate['linkUrl']),
    bank: BankDetails(
      name: _str(bank['name']),
      accountName: _str(bank['accountName']),
      accountNumber: _str(bank['accountNumber']),
      branch: _str(bank['branch']),
      swift: _str(bank['swift']),
    ),
  );
}

SiteSettings parseSiteSettings(Map<String, dynamic> json) {
  final defaults = SiteSettings.defaults();
  final contact = json['contact'] as Map<String, dynamic>? ?? {};
  final location = json['location'] as Map<String, dynamic>? ?? {};
  final streaming = json['streaming'] as Map<String, dynamic>? ?? {};
  final social = json['social'] as Map<String, dynamic>? ?? {};

  final livestreamUrl = _str(streaming['livestreamUrl']);

  return SiteSettings(
    contact: ContactInfo(
      address: _str(contact['address']),
      phone: _str(contact['phone']),
      email: _str(contact['email']),
    ),
    mapEmbedUrl: _str(location['mapEmbedUrl']),
    mapLinkUrl: _str(location['mapLinkUrl']),
    livestreamUrl:
        livestreamUrl.isNotEmpty ? livestreamUrl : defaults.livestreamUrl,
    youtubeLive: _parseYoutubeLive(streaming['youtubeLive']),
    social: SocialLinks(
      facebook: _str(social['facebook']),
      instagram: _str(social['instagram']),
      youtube: _str(social['youtube']),
      whatsapp: _str(social['whatsapp']),
      tiktok: _str(social['tiktok']),
    ),
    donate: _parseDonate(json['donate']),
  );
}

const _dayKeys = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

/// Empty is valid: a day with no slots, or a malformed/missing `days` map,
/// both come back as an empty list for that day rather than an error.
Map<String, List<ScheduleSlot>> parseSchedule(Map<String, dynamic> json) {
  final days = json['days'] as Map<String, dynamic>? ?? {};
  final week = <String, List<ScheduleSlot>>{};

  for (final key in _dayKeys) {
    final raw = days[key];
    if (raw is! List) {
      week[key] = const [];
      continue;
    }

    week[key] = raw
        .whereType<Map<String, dynamic>>()
        .map((item) =>
            ScheduleSlot(time: _str(item['time']), title: _str(item['title'])))
        .where((slot) => slot.time.isNotEmpty && slot.title.isNotEmpty)
        .toList();
  }

  return week;
}

/// The console has already normalised Streamerr's document, so this only has
/// to guard against an older console deployment or a proxy error page — the
/// same defensive read the other parsers do.
NowPlaying parseNowPlaying(Map<String, dynamic> json) {
  final listeners = json['listeners'];

  return NowPlaying(
    onAir: json['onAir'] == true,
    nowPlaying: _str(json['nowPlaying']),
    coverArt: _str(json['coverArt']),
    listeners: listeners is int && listeners > 0 ? listeners : 0,
  );
}

List<PodcastEpisode> parsePodcasts(Map<String, dynamic> json) {
  final episodes = json['episodes'];
  if (episodes is! List) return const [];

  return episodes
      .whereType<Map<String, dynamic>>()
      .map((item) => PodcastEpisode(
            title: _str(item['title']),
            description: _str(item['description']),
            audioUrl: _str(item['audioUrl']),
            imageUrl: _str(item['imageUrl']),
          ))
      .where(
          (episode) => episode.title.isNotEmpty && episode.audioUrl.isNotEmpty)
      .toList();
}

Future<SiteSettings> fetchSiteSettings() async =>
    parseSiteSettings(await _getJson('/api/public/site-settings'));

Future<Map<String, List<ScheduleSlot>>> fetchSchedule() async =>
    parseSchedule(await _getJson('/api/public/schedule'));

Future<List<PodcastEpisode>> fetchPodcasts() async =>
    parsePodcasts(await _getJson('/api/public/podcasts'));

/// Unlike the other three this is polled, not fetched once — see
/// [NowPlayingController]. A 503 here means the console couldn't reach
/// Streamerr, and throws like any other failure so the caller can keep
/// showing the last track rather than blanking the screen.
Future<NowPlaying> fetchNowPlaying() async =>
    parseNowPlaying(await _getJson('/api/public/now-playing'));
