import 'package:intl/intl.dart';

abstract class DateHelpers {
  static final _dateFormatter = DateFormat('dd/MM/yyyy');
  static final _timeFormatter = DateFormat('HH:mm');
  static final _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');
  static final _monthYearFormatter = DateFormat('MMMM yyyy');

  static String formatDate(DateTime date) => _dateFormatter.format(date);
  static String formatTime(DateTime date) => _timeFormatter.format(date);
  static String formatDateTime(DateTime date) =>
      _dateTimeFormatter.format(date);
  static String formatMonthYear(DateTime date) =>
      _monthYearFormatter.format(date);

  /// Returns relative time string (e.g., "2 hours ago", "in 3 days").
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative) {
      // Future date
      final futureDiff = date.difference(now);
      if (futureDiff.inDays > 0) return 'in ${futureDiff.inDays} days';
      if (futureDiff.inHours > 0) return 'in ${futureDiff.inHours} hours';
      return 'in ${futureDiff.inMinutes} minutes';
    }

    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static bool isYesterday(DateTime date) =>
      isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));

  static String smartDate(DateTime date) {
    if (isToday(date)) return 'Today, ${formatTime(date)}';
    if (isYesterday(date)) return 'Yesterday, ${formatTime(date)}';
    return formatDate(date);
  }
}
