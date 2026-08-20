/// Sri Lanka has no daylight-saving time, so Asia/Colombo is always a fixed
/// UTC+5:30 offset — safe to compute by hand instead of pulling in the
/// `timezone` package for one feature.
const _colomboOffset = Duration(hours: 5, minutes: 30);

const _codesMondayFirst = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

const _dayKeyByCode = {
  'MON': 'monday',
  'TUE': 'tuesday',
  'WED': 'wednesday',
  'THU': 'thursday',
  'FRI': 'friday',
  'SAT': 'saturday',
  'SUN': 'sunday',
};

/// The admin's schedule keys are full lowercase day names; the timetable's
/// day chips (`AppData.days`) use 3-letter codes. Falls back to `'monday'`
/// for an unknown code so a typo can't crash the lookup.
String dayKeyForCode(String code) => _dayKeyByCode[code] ?? 'monday';

DateTime colomboNow() => DateTime.now().toUtc().add(_colomboOffset);

/// `'MON'`..`'SUN'` for the current moment in Colombo — matches the format
/// of `AppData.days`. Pass [now] to compute the code for a fixed instant
/// instead of the real wall clock (tests only; every production call site
/// omits it and gets the real `colomboNow()`).
String todayDayCode({DateTime? now}) =>
    _codesMondayFirst[(now ?? colomboNow()).weekday - 1];

/// True when `now` falls between `time` (inclusive) and `nextTime`
/// (exclusive) — or after `time` with no upper bound when this is the last
/// slot of the day (`nextTime` is null). `time`/`nextTime` are `"HH:mm"`.
bool isSlotOnAir({
  required String time,
  required String? nextTime,
  required DateTime now,
}) {
  final nowMinutes = now.hour * 60 + now.minute;
  final slotMinutes = _minutesOf(time);
  if (slotMinutes == null || nowMinutes < slotMinutes) return false;

  if (nextTime == null) return true;
  final nextMinutes = _minutesOf(nextTime);
  if (nextMinutes == null) return true;
  return nowMinutes < nextMinutes;
}

int? _minutesOf(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return hour * 60 + minute;
}
