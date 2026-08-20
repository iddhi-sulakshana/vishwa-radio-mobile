import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/navigation/app_routes.dart';
import 'package:vishwa_radio/screens/about_page.dart';

void main() {
  testWidgets('shows the stats row and the foundation partnership footer',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: const AboutPage(), routes: AppRoutes.table),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('LANGUAGES'), findsOneWidget);

    // Scroll to make the partnership footer visible
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Woodrose Foundation'), findsOneWidget);
  });

  testWidgets('states no figure the app cannot stand behind', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: const AboutPage(), routes: AppRoutes.table),
    );

    // An invented audience number, an invented programme count, and a
    // founding year the station has no documented claim to.
    expect(find.text('12K'), findsNothing);
    expect(find.textContaining('DAILY LISTENERS'), findsNothing);
    expect(find.text('40+'), findsNothing);
    expect(find.textContaining('BROADCASTING SINCE'), findsNothing);
    expect(find.text('88.4'), findsNothing);

    // With no schedule fetched there is nothing to count, so the programme
    // tile is absent rather than showing a made-up or zero figure.
    expect(find.textContaining('WEEKLY PROGRAMMES'), findsNothing);
  });
}
