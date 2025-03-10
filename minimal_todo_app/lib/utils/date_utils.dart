bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month && date.day == now.day;
}

bool isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(Duration(days: 1));
  return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
}

bool isTomorrow(DateTime date) {
  final tomorrow = DateTime.now().add(Duration(days: 1));
  return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
}

String getDayOfWeek(DateTime date) {
  if (isToday(date)) return 'Today';
  if (isYesterday(date)) return 'Yesterday';
  if (isTomorrow(date)) return 'Tomorrow';
  return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
}
List<DateTime> generateDateList() {
  return List.generate(
      7, (index) => DateTime.now().subtract(Duration(days: 3 - index)));
}