DateTime businessWallTime(DateTime instant) {
  final value = instant.toUtc().add(const Duration(hours: 7));
  return DateTime(
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}

DateTime businessNow() => businessWallTime(DateTime.now());
