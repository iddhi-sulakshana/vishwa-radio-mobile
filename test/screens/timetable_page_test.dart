import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/models/schedule_slot.dart';
import 'package:vishwa_radio/navigation/app_routes.dart';
import 'package:vishwa_radio/screens/timetable_page.dart';
import 'package:vishwa_radio/services/admin_content_controller.dart';
import 'package:vishwa_radio/utils/day_of_week.dart';

void main() {
  setUp(() {
    AdminContentController.instance.schedule = {
      'monday': const [ScheduleSlot(time: '10:00', title: 'Morning Raha')],
      'tuesday': const [],
      'wednesday': const [],
      'thursday': const [],
      'friday': const [],
      'saturday': const [
        ScheduleSlot(time: '20:00', title: 'Morning Raaga'),
        ScheduleSlot(time: '21:00', title: 'Test Program'),
      ],
      'sunday': const [],
    };
  });

  testWidgets("opens on today's real day and lists its slots", (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: const TimetablePage(), routes: AppRoutes.table),
    );

    final today = todayDayCode();
    final expectedSlots =
        AdminContentController.instance.schedule[dayKeyForCode(today)] ??
            const [];

    if (expectedSlots.isEmpty) {
      expect(find.text('Nothing scheduled for this day yet.'), findsOneWidget);
    } else {
      expect(find.text(expectedSlots.first.title), findsOneWidget);
    }
  });

  testWidgets('switching the day chip switches the visible slots',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: const TimetablePage(), routes: AppRoutes.table),
    );

    await tester.tap(find.text('SAT'));
    await tester.pump();

    expect(find.text('Morning Raaga'), findsOneWidget);
    expect(find.text('Test Program'), findsOneWidget);
  });
}
