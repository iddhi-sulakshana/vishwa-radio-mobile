import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vishwa_radio/my_app.dart';
import 'package:vishwa_radio/services/admin_content_controller.dart';
import 'package:vishwa_radio/services/now_playing_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  // Fire-and-forget: the splash screen's own 2.6s timer is free cover time
  // for this round trip, and every screen falls back to sensible
  // defaults/empty state via AdminContentController if it hasn't resolved
  // yet. Started here (once, at process entry) rather than inside
  // SplashScreen so widget tests that pump individual screens or MyApp
  // directly never trigger a real network call — only running the app via
  // `main()` does.
  AdminContentController.instance.init();
  // Same reasoning, and the same reason it lives here rather than in RadioPage:
  // this one polls on a timer, so starting it from a widget would leave tests
  // pumping a screen with a live timer and a real network call attached to it.
  NowPlayingController.instance.start();
  runApp(const MyApp());
}
