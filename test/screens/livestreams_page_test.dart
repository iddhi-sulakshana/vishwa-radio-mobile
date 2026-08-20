import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/models/site_settings.dart';
import 'package:vishwa_radio/navigation/app_routes.dart';
import 'package:vishwa_radio/screens/livestreams_page.dart';
import 'package:vishwa_radio/screens/radio_page.dart';
import 'package:vishwa_radio/services/admin_content_controller.dart';
import 'package:vishwa_radio/widgets/hamburger_button.dart';

/// The real player is a platform webview, which the test binding has no
/// implementation for — every live-state test swaps in this placeholder and
/// asserts on it instead.
const _fakePlayerKey = Key('fake-youtube-player');

Widget _fakePlayer(YoutubeLive live) =>
    Container(key: _fakePlayerKey, color: Colors.black);

SiteSettings _settingsWith(YoutubeLive live) {
  final base = SiteSettings.defaults();
  return SiteSettings(
    donate: DonateSettings.empty,
    contact: base.contact,
    mapEmbedUrl: base.mapEmbedUrl,
    mapLinkUrl: base.mapLinkUrl,
    livestreamUrl: base.livestreamUrl,
    youtubeLive: live,
    social: base.social,
  );
}

const _liveWithVideo = YoutubeLive(
  enabled: true,
  url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  embedUrl: 'https://www.youtube.com/embed/dQw4w9WgXcQ',
  videoId: 'dQw4w9WgXcQ',
);

const _liveOnChannel = YoutubeLive(
  enabled: true,
  url: 'https://www.youtube.com/channel/UC123/live',
  embedUrl: 'https://www.youtube.com/embed/live_stream?channel=UC123',
  videoId: '',
);

void main() {
  // The controller is a singleton the screen reads from, so each test that
  // changes it has to hand the next one a clean slate.
  tearDown(() {
    AdminContentController.instance.siteSettings = SiteSettings.defaults();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const LivestreamsPage(videoPlayerBuilder: _fakePlayer),
        routes: AppRoutes.table,
      ),
    );
  }

  group('off air', () {
    testWidgets('offers the audio stream and the Facebook page',
        (tester) async {
      await pumpPage(tester);

      // Scroll past the hero card to bring the actions into view
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Listen to the live audio stream'), findsOneWidget);
      expect(find.text('Follow on Facebook'), findsOneWidget);
    });

    testWidgets('the listen action lands on the radio screen', (tester) async {
      await pumpPage(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Listen to the live audio stream'));
      // Not pumpAndSettle: the radio screen's ticker and pulse loop forever.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(RadioPage), findsOneWidget);
    });

    testWidgets('claims no live status, viewer count or invented events',
        (tester) async {
      await pumpPage(tester);

      expect(find.text('LIVE'), findsNothing);
      expect(find.byKey(_fakePlayerKey), findsNothing);
      expect(find.text('1.2K watching'), findsNothing);
      expect(find.text('UPCOMING'), findsNothing);
      expect(find.textContaining('Inter-Faculty Music Fest'), findsNothing);
      expect(find.textContaining('Convocation Day Live'), findsNothing);
      expect(find.textContaining('Radio Drama Night'), findsNothing);
    });

    testWidgets('says plainly that there is no video stream', (tester) async {
      await pumpPage(tester);

      expect(
        find.textContaining('Video streams are announced'),
        findsOneWidget,
      );
    });
  });

  group('live', () {
    testWidgets('plays the broadcast and marks it live', (tester) async {
      AdminContentController.instance.siteSettings =
          _settingsWith(_liveWithVideo);

      await pumpPage(tester);

      expect(find.byKey(_fakePlayerKey), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      expect(
        find.textContaining('Video streams are announced'),
        findsNothing,
      );
    });

    testWidgets('still offers the audio stream and a way out to YouTube',
        (tester) async {
      AdminContentController.instance.siteSettings =
          _settingsWith(_liveWithVideo);

      await pumpPage(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Watch on YouTube'), findsOneWidget);
      expect(find.text('Listen to the live audio stream'), findsOneWidget);
    });

    testWidgets('stops painting the player while the drawer is over it',
        (tester) async {
      // The Android WebView is a platform view: it escapes Flutter's
      // compositing and paints on top of the drawer, hiding the top half of
      // the nav. The only reliable answer is to take it off stage while the
      // drawer is open — `find` skips offstage widgets, so this catches it.
      AdminContentController.instance.siteSettings =
          _settingsWith(_liveWithVideo);

      await pumpPage(tester);
      expect(find.byKey(_fakePlayerKey), findsOneWidget);

      await tester.tap(find.byType(HamburgerButton));
      await tester.pumpAndSettle();

      expect(find.text('Podcasts'), findsOneWidget, reason: 'drawer is open');
      expect(find.byKey(_fakePlayerKey), findsNothing);
    });

    testWidgets('paints the player again once the drawer closes',
        (tester) async {
      AdminContentController.instance.siteSettings =
          _settingsWith(_liveWithVideo);

      await pumpPage(tester);
      await tester.tap(find.byType(HamburgerButton));
      await tester.pumpAndSettle();

      // Tap the scrim to dismiss.
      await tester.tapAt(const Offset(700, 400));
      await tester.pumpAndSettle();

      expect(find.byKey(_fakePlayerKey), findsOneWidget);
    });

    testWidgets('falls back to a link when the console gave us no video id',
        (tester) async {
      AdminContentController.instance.siteSettings =
          _settingsWith(_liveOnChannel);

      await pumpPage(tester);

      // Nothing to embed, so no player — but the stream is still reachable.
      expect(find.byKey(_fakePlayerKey), findsNothing);
      expect(find.text('LIVE'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Watch on YouTube'), findsOneWidget);
    });
  });
}
