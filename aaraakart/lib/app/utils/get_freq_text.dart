String getFrequencyText({required dynamic period, required dynamic interval}) {
  String periodStr = period?.toString().toLowerCase() ?? '';

  int intervalInt;
  if (interval is int) {
    intervalInt = interval;
  } else if (interval is String) {
    intervalInt = int.tryParse(interval) ?? 1;
  } else {
    intervalInt = 1;
  }

  switch (periodStr) {
    case 'day':
      if (intervalInt == 1) return "Every day";
      if (intervalInt == 2) return "Every alternate day";
      return "Every $intervalInt days";
    case 'week':
      if (intervalInt == 1) return "Every week";
      if (intervalInt == 2) return "Every alternate week";
      return "Every $intervalInt weeks";
    case 'month':
      if (intervalInt == 1) return "Every month";
      if (intervalInt == 2) return "Every alternate month";
      return "Every $intervalInt months";
    default:
      return "Every $intervalInt $periodStr(s)";
  }
}
