import 'package:flutter/material.dart';

import '../screens/about_page.dart';
import '../screens/contact_page.dart';
import '../screens/donate_page.dart';
import '../screens/livestreams_page.dart';
import '../screens/podcasts_page.dart';
import '../screens/radio_page.dart';
import '../screens/timetable_page.dart';

class AppRoutes {
  AppRoutes._();

  static const radio = '/radio';
  static const livestreams = '/livestreams';
  static const podcasts = '/podcasts';
  static const timetable = '/timetable';
  static const about = '/about';
  static const contact = '/contact';
  static const donate = '/donate';

  static const _routeByNavLabel = {
    'Radio': radio,
    'Livestream': livestreams,
    'Podcasts': podcasts,
    'Timetable': timetable,
    'About': about,
    'Contact': contact,
    'Donate': donate,
  };

  static Map<String, WidgetBuilder> get table => {
        radio: (_) => const RadioPage(),
        livestreams: (_) => const LivestreamsPage(),
        podcasts: (_) => const PodcastsPage(),
        timetable: (_) => const TimetablePage(),
        about: (_) => const AboutPage(),
        contact: (_) => const ContactPage(),
        donate: (_) => const DonatePage(),
      };

  /// Navigates to the screen for a drawer nav item label, replacing the
  /// current route so the drawer behaves like a side-nav switch rather than
  /// stacking screens.
  static void navigateToLabel(BuildContext context, String label) {
    final route = _routeByNavLabel[label];
    if (route == null) return;
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushReplacementNamed(route);
  }
}
