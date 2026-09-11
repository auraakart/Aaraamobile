import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

Theme _datePickerTheme(BuildContext context, Widget child) {
  return Theme(
    data: Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: AppColors.brandPrimary,
        onPrimary: Colors.white,
        onSurface: Colors.black,
        secondary: AppColors.brandPrimary.withOpacity(0.8),
        onSecondary: Colors.white,
        surface: Colors.white,
        primaryContainer: AppColors.brandPrimary.withOpacity(0.1),
        onPrimaryContainer: AppColors.brandPrimary,
      ),
      textTheme: Theme.of(context).textTheme.copyWith(
            headlineSmall: TextStyle(
              color: AppColors.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
            bodyMedium: TextStyle(
              color: Colors.black87,
            ),
          ),
    ),
    child: child,
  );
}

Future<Map<String, DateTime>?> myAppDateRangePicker(
  BuildContext context,
) async {
  final now = DateTime.now();

  final picked = await showDateRangePicker(
    context: context,
    firstDate: now.add(const Duration(days: 1)),
    lastDate: DateTime(now.year + 5),
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    initialDateRange: DateTimeRange(
      start: now.add(const Duration(days: 1)),
      end: now.add(const Duration(days: 7)),
    ),
    builder: (context, child) => _datePickerTheme(context, child!),
  );

  if (picked == null) return null;

  return {"fromDate": picked.start, "toDate": picked.end};
}

Future<Map<String, DateTime>?> myAppOrderDateRangePicker(
  BuildContext context,
  DateTime? fromDate,
  DateTime? toDate,
) async {
  final now = DateTime.now();

  final picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(now.year - 5),
    lastDate: now,
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    builder: (context, child) => _datePickerTheme(context, child!),
  );

  if (picked == null) return null;

  return {
    "fromDate": picked.start,
    "toDate": picked.end,
  };
}


