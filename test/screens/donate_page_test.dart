import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/models/site_settings.dart';
import 'package:vishwa_radio/screens/donate_page.dart';

/// Drives [DonateBody] directly rather than [DonatePage]: the body takes its
/// settings as a parameter, so every state can be exercised without a network
/// or the controller singleton.
void main() {
  Future<void> pumpWith(WidgetTester tester, DonateSettings donate) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DonateBody(donate: donate))),
    );
    await tester.pumpAndSettle();
  }

  const bankName = BankDetails(
    name: 'Commercial Bank',
    accountName: '',
    accountNumber: '',
    branch: '',
    swift: '',
  );

  const bankFull = BankDetails(
    name: 'Commercial Bank',
    accountName: '',
    accountNumber: '1234567890',
    branch: 'Peradeniya',
    swift: '',
  );

  testWidgets('shows a message when nothing is configured', (tester) async {
    await pumpWith(tester, DonateSettings.empty);

    expect(find.textContaining('being set up'), findsOneWidget);
    expect(find.text('Donate online'), findsNothing);
    expect(find.text('BANK TRANSFER'), findsNothing);
  });

  testWidgets('shows the donation link when set', (tester) async {
    await pumpWith(
      tester,
      const DonateSettings(
        intro: 'Support our work',
        linkUrl: 'https://www.buymeacoffee.com/vishwaradio',
        bank: BankDetails.empty,
      ),
    );

    expect(find.text('Support our work'), findsOneWidget);
    expect(find.text('Donate online'), findsOneWidget);
    expect(find.text('BANK TRANSFER'), findsNothing);
    expect(find.textContaining('being set up'), findsNothing);
  });

  // A bank name with no account number cannot be paid into. Showing the panel
  // anyway invites a failed transfer.
  testWidgets('hides the bank panel when only half filled', (tester) async {
    await pumpWith(
      tester,
      const DonateSettings(intro: '', linkUrl: '', bank: bankName),
    );

    expect(find.text('BANK TRANSFER'), findsNothing);
    expect(find.text('Commercial Bank'), findsNothing);
    // Nothing usable at all, so the fallback message stands in.
    expect(find.textContaining('being set up'), findsOneWidget);
  });

  testWidgets('shows only the bank fields that are set', (tester) async {
    await pumpWith(
      tester,
      const DonateSettings(intro: '', linkUrl: '', bank: bankFull),
    );

    expect(find.text('BANK TRANSFER'), findsOneWidget);
    expect(find.text('Commercial Bank'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('Peradeniya'), findsOneWidget);
    // Account name and SWIFT are unset, so their rows are absent entirely.
    expect(find.text('ACCOUNT NAME'), findsNothing);
    expect(find.text('SWIFT CODE'), findsNothing);
  });

  testWidgets('falls back to default intro copy when none is set', (
    tester,
  ) async {
    await pumpWith(
      tester,
      const DonateSettings(intro: '', linkUrl: '', bank: bankFull),
    );

    expect(find.textContaining('helps keep Vishwa Radio on air'), findsOneWidget);
  });

  // An account number that cannot be copied is one that gets mistyped.
  testWidgets('offers a copy control for each bank field', (tester) async {
    await pumpWith(
      tester,
      const DonateSettings(intro: '', linkUrl: '', bank: bankFull),
    );

    // Three fields set -> three copy buttons.
    expect(find.byIcon(Icons.copy_rounded), findsNWidgets(3));
  });
}
