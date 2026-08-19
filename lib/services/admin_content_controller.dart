import 'package:flutter/foundation.dart';

import '../models/podcast_episode.dart';
import '../models/schedule_slot.dart';
import '../models/site_settings.dart';
import 'admin_api_service.dart' as api;

enum ContentStatus { loading, ready, error }

/// Holds the admin-fetched content the app screens read from — site
/// settings, weekly schedule, podcast episodes — each with its own status
/// so one slow/failed endpoint never holds up the other two. Starts with
/// sane defaults/empty state and only ever improves on `init()`; a failed
/// fetch keeps whatever was already there rather than clearing it.
///
/// Fetch functions are injectable (defaulting to the real network calls in
/// admin_api_service.dart) purely so tests can supply fakes without hitting
/// the network.
class AdminContentController extends ChangeNotifier {
  AdminContentController._internal({
    Future<SiteSettings> Function()? fetchSiteSettings,
    Future<Map<String, List<ScheduleSlot>>> Function()? fetchSchedule,
    Future<List<PodcastEpisode>> Function()? fetchPodcasts,
  })  : _fetchSiteSettings = fetchSiteSettings ?? api.fetchSiteSettings,
        _fetchSchedule = fetchSchedule ?? api.fetchSchedule,
        _fetchPodcasts = fetchPodcasts ?? api.fetchPodcasts;

  /// [DemoContent.enabled] is a compile-time `false` in every build except a
  /// `--dart-define=DEMO_DATA=true` one, so these three collapse to `null`,
  /// the real API functions are used, and the demo content is tree-shaken
  /// out entirely. Screenshot builds get the demo week instead of whatever
  /// test rows the console happens to be holding.
  // TEMPORARY: the DemoContent wiring is restored in the demo-content commit.
  static final AdminContentController instance =
      AdminContentController._internal();

  /// Only for tests — the real app always uses [instance].
  @visibleForTesting
  factory AdminContentController.forTesting({
    required Future<SiteSettings> Function() fetchSiteSettings,
    required Future<Map<String, List<ScheduleSlot>>> Function() fetchSchedule,
    required Future<List<PodcastEpisode>> Function() fetchPodcasts,
  }) {
    return AdminContentController._internal(
      fetchSiteSettings: fetchSiteSettings,
      fetchSchedule: fetchSchedule,
      fetchPodcasts: fetchPodcasts,
    );
  }

  final Future<SiteSettings> Function() _fetchSiteSettings;
  final Future<Map<String, List<ScheduleSlot>>> Function() _fetchSchedule;
  final Future<List<PodcastEpisode>> Function() _fetchPodcasts;

  SiteSettings siteSettings = SiteSettings.defaults();
  Map<String, List<ScheduleSlot>> schedule = const {
    'monday': [],
    'tuesday': [],
    'wednesday': [],
    'thursday': [],
    'friday': [],
    'saturday': [],
    'sunday': [],
  };
  List<PodcastEpisode> podcasts = const [];

  ContentStatus settingsStatus = ContentStatus.loading;
  ContentStatus scheduleStatus = ContentStatus.loading;
  ContentStatus podcastsStatus = ContentStatus.loading;

  Future<void> init() {
    return Future.wait([_loadSettings(), _loadSchedule(), _loadPodcasts()]);
  }

  Future<void> _loadSettings() async {
    try {
      siteSettings = await _fetchSiteSettings();
      settingsStatus = ContentStatus.ready;
    } catch (_) {
      settingsStatus = ContentStatus.error;
    }
    notifyListeners();
  }

  Future<void> _loadSchedule() async {
    try {
      schedule = await _fetchSchedule();
      scheduleStatus = ContentStatus.ready;
    } catch (_) {
      scheduleStatus = ContentStatus.error;
    }
    notifyListeners();
  }

  Future<void> _loadPodcasts() async {
    try {
      podcasts = await _fetchPodcasts();
      podcastsStatus = ContentStatus.ready;
    } catch (_) {
      podcastsStatus = ContentStatus.error;
    }
    notifyListeners();
  }
}
