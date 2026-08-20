import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/utils/day_of_week.dart';

void main() {
  group('dayKeyForCode', () {
    test('maps every 3-letter code to its admin day key', () {
      expect(dayKeyForCode('MON'), 'monday');
      expect(dayKeyForCode('SUN'), 'sunday');
    });

    test('falls back to monday for an unknown code', () {
      expect(dayKeyForCode('XXX'), 'monday');
    });
  });

  group('todayDayCode', () {
    test(
      'with an injected now, returns that day\'s code, not the real one',
      () {
        expect(todayDayCode(now: DateTime(2026, 1, 5)), 'MON');
        expect(todayDayCode(now: DateTime(2026, 1, 11)), 'SUN');
      },
    );

    test('with no argument, matches the real Colombo clock', () {
      expect(todayDayCode(), todayDayCode(now: colomboNow()));
    });
  });

  group('isSlotOnAir', () {
    test('is false before the slot starts', () {
      final now = DateTime(2026, 1, 1, 9, 59);
      expect(isSlotOnAir(time: '10:00', nextTime: '12:00', now: now), false);
    });

    test('is true once the slot starts', () {
      final now = DateTime(2026, 1, 1, 10, 0);
      expect(isSlotOnAir(time: '10:00', nextTime: '12:00', now: now), true);
    });

    test('is true right up until the next slot starts', () {
      final now = DateTime(2026, 1, 1, 11, 59);
      expect(isSlotOnAir(time: '10:00', nextTime: '12:00', now: now), true);
    });

    test('is false once the next slot starts', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      expect(isSlotOnAir(time: '10:00', nextTime: '12:00', now: now), false);
    });

    test('has no upper bound for the last slot of the day', () {
      final now = DateTime(2026, 1, 1, 23, 30);
      expect(isSlotOnAir(time: '21:00', nextTime: null, now: now), true);
    });
  });
}
