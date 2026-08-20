import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/navigation/app_routes.dart';
import 'package:vishwa_radio/screens/contact_page.dart';

void main() {
  testWidgets('shows the default contact details and exactly one social link',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: const ContactPage(), routes: AppRoutes.table),
    );

    expect(find.text('woodrose@gmail.com'), findsOneWidget);
    expect(find.text('+94 81 238 7854 / +94 77 532 2253'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
    expect(find.text('Instagram'), findsNothing);
  });
}
