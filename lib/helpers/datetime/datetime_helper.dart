class DateTimeHelper {
  static bool isBetweenDate({
    required DateTime start,
    required DateTime end,
    required DateTime compare,
  }) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    final compareDate = DateTime(compare.year, compare.month, compare.day);

    if (startDate.isAfter(compareDate) || endDate.isBefore(compareDate)) {
      return false;
    } else {
      return true;
    }
  }

  static String dateToString({
    required int month,
    required int day,
    required int year,
  }) {
    List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    String monthName = months.elementAt(month);
    int selectedDay = day + 1;
    return "$monthName $selectedDay, $year";
  }

  static String timeToString({required int hour, required int minute}) {
    String hourString = hour.toString();
    String minuteString = minute.toString();
    if (hour < 10) hourString = "0$hour";
    if (minute < 10) minuteString = "0$minute";
    return "$hourString:$minuteString";
  }
}
