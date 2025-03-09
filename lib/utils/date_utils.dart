class DateUtils {
  static DateTime _mockDate = DateTime.now();

  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime getToday() {
    print('getToday() called: $_mockDate');
    return _mockDate;
  }

  static void setMockDate(DateTime date) {
    _mockDate = date;
    print('setMockDate() called: $date');
  }

  static void resetMockDate() {
    _mockDate = DateTime.now();
    print('resetMockDate() called: $_mockDate');
  }
}
