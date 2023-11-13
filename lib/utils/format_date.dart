class DateFormatter {
  static String formatDate(DateTime date) {
    final List<String> monthNames = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];

    final day = date.day.toString();
    final month = monthNames[date.month - 1];
    final year = date.year.toString();

    return '$day $month $year';
  }
}
