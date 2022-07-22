abstract class DateTimeUtil {
  static bool isSameDate(DateTime a, DateTime b) => a.toIso8601String().substring(0, 10) == b.toIso8601String().substring(0, 10);
}
