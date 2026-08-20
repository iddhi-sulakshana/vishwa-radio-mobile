import 'package:flutter_test/flutter_test.dart';

import 'package:vishwa_radio/my_app.dart';

void main() {
  testWidgets('app launches on the splash screen without throwing',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // The station has no FM frequency, so the splash carries the university
    // line alone — see the removed "88.4 FM" assertion this replaced.
    expect(find.text('WOODROSE FOUNDATION'), findsOneWidget);
  });
}
