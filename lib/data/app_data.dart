/// The handful of constants that are the same on every install — everything
/// that can change (schedule, episodes, contact details) is fetched from the
/// admin API instead.
class AppData {
  AppData._();

  /// The radio screen has no way of knowing which programme is on air — the
  /// schedule is a weekly grid, not a live feed — so the ticker carries a line
  /// that is true at any hour.
  /// Ends with its own separator: the marquee lays repeated copies end to
  /// end, and without one the last word of a pass runs into the first word of
  /// the next ("...PROJECTVISHWA RADIO...").
  static const tickerText =
      'VISHWA RADIO · AMPLIFYING POSITIVE CHANGE · A WOODROSE FOUNDATION PROJECT · ';

  static const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  static const navItems = [
    'Radio',
    'Livestream',
    'Podcasts',
    'Timetable',
    'About',
    'Contact',
    'Donate',
  ];
}
