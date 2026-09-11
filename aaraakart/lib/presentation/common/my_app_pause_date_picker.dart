import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/subscriptions/subscription_cutoff_helper.dart';
import 'package:aaraa_kart/presentation/subscriptions/subscription_schedule_calendar_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';

class PausePickerResult {
  final dynamic pauseDates;
  final String pauseType;

  const PausePickerResult({
    required this.pauseDates,
    this.pauseType = 'temporary',
  });

  bool get isPermanent => pauseType == 'permanent';
}

Future<PausePickerResult?> myAppPauseDatePicker(
  BuildContext context, {
  List<int>? allowedWeekdays,
}) async {
  if (SubscriptionCutoffHelper.checkAndShowCutoffSnackBar(context)) {
    return null;
  }

  final mode = await showModalBottomSheet<_PauseMode>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (context) => const _PauseModeSheet(),
  );

  if (mode == null || !context.mounted) return null;

  if (mode == _PauseMode.permanent) {
    return const PausePickerResult(
      pauseDates: [],
      pauseType: 'permanent',
    );
  }

  final result = await showModalBottomSheet<dynamic>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (context) => _CalendarPickerSheet(
      mode: mode,
      allowedWeekdays: allowedWeekdays,
    ),
  );

  if (result == null) return null;

  final formatter = DateFormat('yyyy-MM-dd');
  switch (mode) {
    case _PauseMode.single:
      return PausePickerResult(
        pauseDates: formatter.format(result as DateTime),
        pauseType: 'temporary',
      );
    case _PauseMode.range:
      final range = result as DateTimeRange;
      return PausePickerResult(
        pauseDates: {
          "start": formatter.format(range.start),
          "end": formatter.format(range.end),
        },
        pauseType: 'temporary',
      );
    case _PauseMode.multi:
      final dates = result as List<DateTime>;
      return PausePickerResult(
        pauseDates: dates.map((d) => formatter.format(d)).toList(),
        pauseType: 'temporary',
      );
    case _PauseMode.permanent:
      return const PausePickerResult(
        pauseDates: [],
        pauseType: 'permanent',
      );
  }
}

enum _PauseMode { single, range, multi, permanent }

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _PauseModeSheet extends StatelessWidget {
  const _PauseModeSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderDefault,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              MyAppText(
                data: 'Pause Deliveries',
                size: 15.sp,
                weight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 4.h),
              MyAppText(
                data: 'Choose how you want to pause your deliveries',
                size: 11.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 18.h),
              _ModeOption(
                icon: Iconsax.calendar_1_outline,
                title: 'Single Date',
                subtitle: 'Skip delivery for one specific day',
                onTap: () {
                  if (SubscriptionCutoffHelper.checkAndShowCutoffSnackBar(
                      context)) {
                    return;
                  }
                  Navigator.pop(context, _PauseMode.single);
                },
              ),
              SizedBox(height: 10.h),
              _ModeOption(
                icon: Iconsax.calendar_edit_outline,
                title: 'Date Range',
                subtitle: 'Skip deliveries from a start date to an end date',
                onTap: () {
                  if (SubscriptionCutoffHelper.checkAndShowCutoffSnackBar(
                      context)) {
                    return;
                  }
                  Navigator.pop(context, _PauseMode.range);
                },
              ),
              SizedBox(height: 10.h),
              _ModeOption(
                icon: Iconsax.calendar_2_outline,
                title: 'Multiple Dates',
                subtitle: 'Pick specific, non-consecutive days to skip',
                onTap: () {
                  if (SubscriptionCutoffHelper.checkAndShowCutoffSnackBar(
                      context)) {
                    return;
                  }
                  Navigator.pop(context, _PauseMode.multi);
                },
              ),
              SizedBox(height: 10.h),
              _ModeOption(
                icon: Iconsax.pause_circle_outline,
                title: 'Pause Until I Resume',
                subtitle:
                    'Pause deliveries indefinitely starting tomorrow without setting an end date',
                onTap: () {
                  if (SubscriptionCutoffHelper.checkAndShowCutoffSnackBar(
                      context)) {
                    return;
                  }
                  Navigator.pop(context, _PauseMode.permanent);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.backgroundBase,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(icon, size: 18.sp, color: AppColors.brandPrimary),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppText(
                    data: title,
                    size: 12.5.sp,
                    weight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: 2.h),
                  MyAppText(
                    data: subtitle,
                    size: 10.sp,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18.sp, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _CalendarPickerSheet extends StatefulWidget {
  final _PauseMode mode;
  final List<int>? allowedWeekdays;

  const _CalendarPickerSheet({required this.mode, this.allowedWeekdays});

  @override
  State<_CalendarPickerSheet> createState() => _CalendarPickerSheetState();
}

class _CalendarPickerSheetState extends State<_CalendarPickerSheet> {
  late DateTime _visibleMonth;
  late DateTime _firstSelectableDate;
  late DateTime _today;

  DateTime? _singleDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final Set<DateTime> _multiDates = {};

  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _firstSelectableDate = _today.add(const Duration(days: 1));
    _visibleMonth =
        DateTime(_firstSelectableDate.year, _firstSelectableDate.month);
  }

  DateTime get _currentToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _currentFirstSelectableDate =>
      _currentToday.add(const Duration(days: 1));

  bool _isSelectable(DateTime day) {
    if (SubscriptionScheduleCalendarSheet.isPauseCutoffTime()) return false;
    if (day.isBefore(_currentFirstSelectableDate)) return false;
    final allowed = widget.allowedWeekdays;
    if (allowed != null && allowed.isNotEmpty) {
      return allowed.contains(day.weekday);
    }
    return true;
  }

  static const _weekdayShortNames = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };

  String? get _allowedDaysLabel {
    final allowed = widget.allowedWeekdays;
    if (allowed == null || allowed.isEmpty) return null;
    final sorted = allowed.toSet().toList()..sort();
    return sorted.map((d) => _weekdayShortNames[d] ?? '').join(', ');
  }

  void _showPauseCutoffSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyAppText(
          data: SubscriptionScheduleCalendarSheet.pauseCutoffMessage,
          color: AppColors.white,
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _onDayTap(DateTime day) {
    if (SubscriptionScheduleCalendarSheet.isPauseCutoffTime()) {
      _showPauseCutoffSnackBar();
      return;
    }

    if (!_isSelectable(day)) return;
    if (SubscriptionCutoffHelper.checkAndShowCutoffSnackBar(context)) {
      return;
    }

    setState(() {
      switch (widget.mode) {
        case _PauseMode.single:
          _singleDate = day;
          break;
        case _PauseMode.range:
          if (_rangeStart == null || _rangeEnd != null) {
            _rangeStart = day;
            _rangeEnd = null;
          } else if (day.isBefore(_rangeStart!)) {
            _rangeStart = day;
          } else {
            _rangeEnd = day;
          }
          break;
        case _PauseMode.multi:
          if (_multiDates.contains(day)) {
            _multiDates.remove(day);
          } else {
            _multiDates.add(day);
          }
          break;
        case _PauseMode.permanent:
          break;
      }
    });
  }

  void _clear() {
    setState(() {
      _singleDate = null;
      _rangeStart = null;
      _rangeEnd = null;
      _multiDates.clear();
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  bool get _canGoBack {
    final prevMonthEnd = DateTime(_visibleMonth.year, _visibleMonth.month, 0);
    return !prevMonthEnd.isBefore(_currentFirstSelectableDate);
  }

  bool get _hasSelection {
    switch (widget.mode) {
      case _PauseMode.single:
        return _singleDate != null;
      case _PauseMode.range:
        return _rangeStart != null && _rangeEnd != null;
      case _PauseMode.multi:
        return _multiDates.isNotEmpty;
      case _PauseMode.permanent:
        return true;
    }
  }

  String get _title {
    switch (widget.mode) {
      case _PauseMode.single:
        return 'Select a Date';
      case _PauseMode.range:
        return 'Select a Date Range';
      case _PauseMode.multi:
        return 'Select Dates to Skip';
      case _PauseMode.permanent:
        return 'Pause Deliveries';
    }
  }

  String? get _summary {
    final fmt = DateFormat('MMM d, yyyy');
    switch (widget.mode) {
      case _PauseMode.single:
        return _singleDate == null
            ? null
            : 'Skipping ${fmt.format(_singleDate!)}';
      case _PauseMode.range:
        if (_rangeStart == null) return null;
        if (_rangeEnd == null) {
          return '${fmt.format(_rangeStart!)} · pick an end date';
        }
        final nights = _rangeEnd!.difference(_rangeStart!).inDays + 1;
        return '${fmt.format(_rangeStart!)} – ${fmt.format(_rangeEnd!)} ($nights days)';
      case _PauseMode.multi:
        if (_multiDates.isEmpty) return null;
        return '${_multiDates.length} date${_multiDates.length == 1 ? '' : 's'} selected';
      case _PauseMode.permanent:
        return 'Paused until manually resumed';
    }
  }

  void _confirm() {
    if (SubscriptionCutoffHelper.checkAndShowCutoffSnackBar(context)) {
      return;
    }
    switch (widget.mode) {
      case _PauseMode.single:
        Navigator.pop(context, _singleDate);
        break;
      case _PauseMode.range:
        Navigator.pop(
            context, DateTimeRange(start: _rangeStart!, end: _rangeEnd!));
        break;
      case _PauseMode.multi:
        Navigator.pop(context, _multiDates.toList()..sort());
        break;
      case _PauseMode.permanent:
        Navigator.pop(context, null);
        break;
    }
  }

  ({bool filled, bool tinted}) _cellState(DateTime day) {
    switch (widget.mode) {
      case _PauseMode.single:
        return (
          filled: _singleDate != null && _isSameDay(day, _singleDate!),
          tinted: false
        );
      case _PauseMode.range:
        final start = _rangeStart;
        final end = _rangeEnd;
        if (start != null && _isSameDay(day, start)) {
          return (filled: true, tinted: false);
        }
        if (end != null && _isSameDay(day, end)) {
          return (filled: true, tinted: false);
        }
        if (start != null &&
            end != null &&
            day.isAfter(start) &&
            day.isBefore(end)) {
          return (filled: false, tinted: true);
        }
        return (filled: false, tinted: false);
      case _PauseMode.multi:
        return (filled: _multiDates.contains(day), tinted: false);
      case _PauseMode.permanent:
        return (filled: false, tinted: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday % 7;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderDefault,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyAppText(
                    data: _title,
                    size: 14.sp,
                    weight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              if (_allowedDaysLabel != null) ...[
                SizedBox(height: 2.h),
                MyAppText(
                  data: 'Delivery days only: $_allowedDaysLabel',
                  size: 10.sp,
                  weight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _canGoBack ? () => _changeMonth(-1) : null,
                    icon: Icon(Icons.chevron_left,
                        color: _canGoBack
                            ? AppColors.textPrimary
                            : AppColors.textDisabled),
                  ),
                  MyAppText(
                    data: DateFormat('MMMM yyyy').format(_visibleMonth),
                    size: 13.sp,
                    weight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon:
                        Icon(Icons.chevron_right, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Row(
                children: _weekdayLabels
                    .map((label) => Expanded(
                          child: Center(
                            child: MyAppText(
                              data: label,
                              size: 10.sp,
                              weight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 4.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: firstWeekday + daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                itemBuilder: (context, index) {
                  if (index < firstWeekday) return const SizedBox();

                  final day = DateTime(_visibleMonth.year, _visibleMonth.month,
                      index - firstWeekday + 1);
                  final selectable = _isSelectable(day);
                  final state = _cellState(day);
                  final isToday = _isSameDay(day, _today);

                  return Padding(
                    padding: EdgeInsets.all(2.r),
                    child: InkWell(
                      onTap: selectable ? () => _onDayTap(day) : null,
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: state.filled
                              ? AppColors.brandPrimary
                              : state.tinted
                                  ? AppColors.brandPrimary.withOpacity(0.12)
                                  : AppColors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          border: isToday && !state.filled
                              ? Border.all(
                                  color: AppColors.brandPrimary, width: 1)
                              : null,
                        ),
                        child: MyAppText(
                          data: '${day.day}',
                          size: 12.sp,
                          weight:
                              state.filled ? FontWeight.w700 : FontWeight.w500,
                          color: !selectable
                              ? AppColors.textDisabled
                              : state.filled
                                  ? AppColors.white
                                  : state.tinted
                                      ? AppColors.brandPrimaryDark
                                      : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 12.h),
              if (_summary != null) ...[
                MyAppText(
                  data: _summary!,
                  size: 10.5.sp,
                  weight: FontWeight.w600,
                  color: AppColors.brandPrimary,
                ),
                SizedBox(height: 10.h),
              ],
              Row(
                children: [
                  if (_singleDate != null ||
                      _rangeStart != null ||
                      _multiDates.isNotEmpty) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clear,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.borderDefault),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: MyAppText(
                          data: 'Clear',
                          weight: FontWeight.w600,
                          size: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _hasSelection ? _confirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        disabledBackgroundColor:
                            AppColors.brandPrimary.withOpacity(0.4),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: MyAppText(
                        data: 'Confirm',
                        weight: FontWeight.w700,
                        size: 12.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
