import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_cubit.dart';
import 'package:aaraa_kart/cubit/subscriptions/subscriptions_state.dart';
import 'package:aaraa_kart/data/model/get_customer_subs.dart';
import 'package:aaraa_kart/presentation/common/my_app_dialog.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/subscriptions/subscription_cutoff_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';

class SubscriptionScheduleCalendarSheet extends StatefulWidget {
  final GetCustomerSubscriptionsResponseModel subscription;

  static const String pauseCutoffMessage =
      'Pausing deliveries is temporarily unavailable from 11:55 PM to 12:00 AM for daily schedule maintenance. Deliveries can be resumed at any time.';

  /// Returns true ONLY during the 5-minute cutoff window between 11:55 PM and 12:00 AM (23:55 to 23:59:59).
  static bool isPauseCutoffTime([DateTime? time]) {
    final now = time ?? DateTime.now();
    return now.hour == 23 && now.minute >= 55;
  }

  const SubscriptionScheduleCalendarSheet({
    super.key,
    required this.subscription,
  });

  static Future<void> show(
    BuildContext context,
    GetCustomerSubscriptionsResponseModel subscription,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<SubscriptionsCubit>(),
        child: SubscriptionScheduleCalendarSheet(subscription: subscription),
      ),
    );
  }

  @override
  State<SubscriptionScheduleCalendarSheet> createState() =>
      _SubscriptionScheduleCalendarSheetState();
}

enum _ScheduleTab { calendar, pause }

class _SubscriptionScheduleCalendarSheetState
    extends State<SubscriptionScheduleCalendarSheet> {
  _ScheduleTab _currentTab = _ScheduleTab.calendar;

  late DateTime _visibleMonth;
  late DateTime _today;
  late DateTime _firstSelectableDate;
  late DateTime _startDate;

  late Set<String> _pausedDates;
  late Set<String> _initialPausedDates;
  bool _isPermanentlyPaused = false;
  bool _isSaving = false;

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat _monthHeaderFormatter = DateFormat('MMMM yyyy');
  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  bool get _isPauseCutoffNow =>
      SubscriptionScheduleCalendarSheet.isPauseCutoffTime();

  DateTime get _currentToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _currentFirstSelectableDate =>
      _currentToday.add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _firstSelectableDate = _today.add(const Duration(days: 1));
    _visibleMonth =
        DateTime(_firstSelectableDate.year, _firstSelectableDate.month);

    final rawStart =
        widget.subscription.startDateGmt ?? widget.subscription.dateCreated;
    _startDate = _parseDate(rawStart) ?? _today;

    _pausedDates = _extractAllPausedDates(widget.subscription.pauseDates);
    _initialPausedDates = Set<String>.from(_pausedDates);

    final isPausedFlag = widget.subscription.status == 'pause' ||
        widget.subscription.isPaused == true ||
        (widget.subscription.status == 'on-hold' &&
            (widget.subscription.needsPayment != true ||
                widget.subscription.pauseType != null ||
                _pausedDates.isNotEmpty));

    _isPermanentlyPaused = widget.subscription.pauseType == 'permanent' ||
        (isPausedFlag &&
            _pausedDates.isEmpty &&
            widget.subscription.resumeDate == null);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return DateTime(value.year, value.month, value.day);
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  Set<String> _extractAllPausedDates(List<dynamic>? pauseDates) {
    final result = <String>{};
    if (pauseDates == null || pauseDates.isEmpty) return result;

    for (final item in pauseDates) {
      if (item is Map) {
        final start = _parseDate(item['start'] ??
            item['from'] ??
            item['pause_start_date'] ??
            item['start_date']);
        final end = _parseDate(item['end'] ??
            item['to'] ??
            item['pause_end_date'] ??
            item['end_date']);
        if (start != null && end != null) {
          var curr = start;
          while (!curr.isAfter(end)) {
            result.add(_dateFormatter.format(curr));
            curr = curr.add(const Duration(days: 1));
          }
        }
      } else if (item != null) {
        final date = _parseDate(item);
        if (date != null) {
          result.add(_dateFormatter.format(date));
        }
      }
    }
    return result;
  }

  bool _isDeliveryDate(DateTime day) {
    final scheduleType =
        widget.subscription.deliverySchedule?.type?.toLowerCase() ?? 'daily';
    final normalized = DateTime(day.year, day.month, day.day);

    if (normalized.isBefore(_startDate)) return false;

    switch (scheduleType) {
      case 'daily':
        return true;
      case 'alternate':
        final diffDays = normalized.difference(_startDate).inDays;
        return diffDays % 2 == 0;
      case 'weekend':
        return day.weekday == DateTime.saturday ||
            day.weekday == DateTime.sunday;
      case 'custom':
        final days = widget.subscription.deliverySchedule?.days;
        if (days == null || days.isEmpty) return true;
        final isoWeekday = day.weekday;
        final scheduleWeekday = isoWeekday == 7 ? 0 : isoWeekday;
        return days.contains(scheduleWeekday);
      default:
        return true;
    }
  }

  bool _isSelectable(DateTime day) {
    if (_isPauseCutoffNow) return false;
    final normalized = DateTime(day.year, day.month, day.day);
    if (normalized.isBefore(_currentFirstSelectableDate)) return false;
    return _isDeliveryDate(day);
  }

  bool _isDatePaused(DateTime day) {
    if (_isPermanentlyPaused) {
      final normalized = DateTime(day.year, day.month, day.day);
      return !normalized.isBefore(_currentFirstSelectableDate);
    }
    final dateStr = _dateFormatter.format(day);
    return _pausedDates.contains(dateStr);
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

  void _toggleDatePause(DateTime day) {
    if (_isPauseCutoffNow) {
      _showPauseCutoffSnackBar();
      return;
    }

    if (!_isSelectable(day) || _isSaving) return;

    final dateStr = _dateFormatter.format(day);
    final isCurrentlyDatePaused = _pausedDates.contains(dateStr);

    if (!isCurrentlyDatePaused || _isPermanentlyPaused) {
      if (SubscriptionCutoffHelper.checkAndShowCutoffSnackBar(context)) {
        return;
      }
    }

    setState(() {
      if (_isPermanentlyPaused) {
        _isPermanentlyPaused = false;
      }
      if (_pausedDates.contains(dateStr)) {
        _pausedDates.remove(dateStr);
      } else {
        _pausedDates.add(dateStr);
      }
    });
  }

  bool get _hasChanges {
    if (_isPermanentlyPaused !=
        (widget.subscription.pauseType == 'permanent')) {
      return true;
    }
    if (_pausedDates.length != _initialPausedDates.length) return true;
    return !_pausedDates.containsAll(_initialPausedDates);
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + offset, 1);
    });
  }

  String _customerId() =>
      context.read<StorageCubit>().userData?.customerID?.toString() ??
      widget.subscription.customerId?.toString() ??
      '';

  String _subscriptionId() => widget.subscription.id?.toString() ?? '';

  void _saveDatePauses() {
    if (_pausedDates.isEmpty) {
      setState(() {
        _isSaving = true;
      });
      context.read<SubscriptionsCubit>().resumeSubscription(
            subscriptionId: _subscriptionId(),
            customerId: _customerId(),
            billingPeriod: widget.subscription.billingPeriod,
            billingInterval: widget.subscription.billingInterval,
            startDate: widget.subscription.startDateGmt ??
                widget.subscription.dateCreated,
            currentNextPaymentDate: widget.subscription.nextPaymentDateGmt,
          );
      return;
    }

    if (SubscriptionCutoffHelper.checkAndShowCutoffSnackBar(context)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final sortedDates = _pausedDates.toList()..sort();

    context.read<SubscriptionsCubit>().pauseSubscription(
          subscriptionId: _subscriptionId(),
          customerId: _customerId(),
          pauseDates: sortedDates,
          pauseType: "temporary",
        );
  }

  void _confirmResume() {
    showDialog(
      context: context,
      builder: (dialogCtx) => MyAppDialog(
        title: "Resume Subscription?",
        subtitle:
            "Deliveries will resume according to your regular schedule starting from tomorrow.",
        positiveText: "Yes, Resume",
        negativeText: "Cancel",
        onPositivePressed: () {
          Navigator.pop(dialogCtx);
          setState(() {
            _isSaving = true;
          });
          context.read<SubscriptionsCubit>().resumeSubscription(
                subscriptionId: _subscriptionId(),
                customerId: _customerId(),
                billingPeriod: widget.subscription.billingPeriod,
                billingInterval: widget.subscription.billingInterval,
                startDate: widget.subscription.startDateGmt ??
                    widget.subscription.dateCreated,
                currentNextPaymentDate: widget.subscription.nextPaymentDateGmt,
              );
        },
        onNegativePressed: () {
          Navigator.pop(dialogCtx);
        },
      ),
    );
  }

  void _confirmLongPause() {
    if (SubscriptionCutoffHelper.checkAndShowCutoffSnackBar(context)) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => MyAppDialog(
        title: "Pause Subscription Indefinitely?",
        subtitle:
            "All deliveries will be paused starting from tomorrow until you manually resume. Today's delivery is not affected. You can resume anytime from the Subscriptions screen.",
        positiveText: "Pause Delivery",
        negativeText: "Cancel",
        onPositivePressed: () {
          Navigator.pop(dialogCtx);
          if (SubscriptionCutoffHelper.checkAndShowCutoffSnackBar(context)) {
            return;
          }
          setState(() {
            _isSaving = true;
          });
          context.read<SubscriptionsCubit>().pauseSubscription(
                subscriptionId: _subscriptionId(),
                customerId: _customerId(),
                pauseDates: [],
                pauseType: "permanent",
              );
        },
        onNegativePressed: () {
          Navigator.pop(dialogCtx);
        },
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _pausedDates.clear();
      _isPermanentlyPaused = false;
    });
  }

  bool _isResumeDate(DateTime day) {
    if (_isPermanentlyPaused) return false;
    final explicitResume = _parseDate(widget.subscription.resumeDate);
    if (explicitResume == null) return false;
    final dateStr = _dateFormatter.format(day);
    if (_pausedDates.contains(dateStr)) return false;
    return day.year == explicitResume.year &&
        day.month == explicitResume.month &&
        day.day == explicitResume.day;
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentlyPaused = widget.subscription.status == 'pause' ||
        widget.subscription.isPaused == true ||
        _isPermanentlyPaused ||
        (widget.subscription.status == 'on-hold' &&
            widget.subscription.needsPayment != true) ||
        _pausedDates.isNotEmpty;

    return BlocConsumer<SubscriptionsCubit, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionUpdateSuccess) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: MyAppText(
                data: 'Subscription schedule updated successfully!',
                color: AppColors.white,
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (state is SubscriptionUpdateError) {
          setState(() {
            _isSaving = false;
          });
          final msg = state.message.replaceAll('Exception: ', '').trim();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: MyAppText(
                data: msg.isNotEmpty ? msg : 'Failed to update schedule',
                color: AppColors.white,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.92,
          minChildSize: 0.60,
          maxChildSize: 0.96,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildSheetHandle(),
                _buildHeader(isCurrentlyPaused),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSegmentedTabs(isCurrentlyPaused),
                        SizedBox(height: 16.h),
                        if (_currentTab == _ScheduleTab.calendar) ...[
                          _buildCutoffNotice(),
                          _buildCalendarSection(),
                          SizedBox(height: 14.h),
                          _buildLegendSection(),
                          SizedBox(height: 14.h),
                          // _buildStatusPillSection(),
                          // SizedBox(height: 18.h),
                          _buildBottomActionButtons(isCurrentlyPaused),
                        ] else ...[
                          _buildPauseTabContent(isCurrentlyPaused),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetHandle() {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
      child: Center(
        child: Container(
          width: 44.w,
          height: 4.5.h,
          decoration: BoxDecoration(
            color: AppColors.borderDefault,
            borderRadius: BorderRadius.circular(2.5.r),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isCurrentlyPaused) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 12.w, 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyAppText(
                  data: 'Manage Deliveries',
                  size: 16.5.sp,
                  weight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: 3.h),
                MyAppText(
                  data: _currentTab == _ScheduleTab.pause
                      ? (isCurrentlyPaused
                          ? 'Resume your recurring deliveries anytime'
                          : 'Stop every delivery until you resume')
                      : 'Tap a delivery day to skip it, or a paused day to bring it back',
                  size: 11.sp,
                  weight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  lineHeight: 1.3,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: AppColors.textPrimary,
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs(bool isCurrentlyPaused) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              tab: _ScheduleTab.calendar,
              icon: Iconsax.calendar_1_outline,
              label: 'Calendar',
            ),
          ),
          Expanded(
            child: _buildTabItem(
              tab: _ScheduleTab.pause,
              icon: isCurrentlyPaused
                  ? Icons.play_circle_outline_rounded
                  : Iconsax.pause_circle_outline,
              label: isCurrentlyPaused ? 'Resume' : 'Long Pause',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required _ScheduleTab tab,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentTab == tab;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isSelected
          ? null
          : () {
              setState(() {
                _currentTab = tab;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.backgroundSurface : AppColors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? Border.all(color: AppColors.borderDefault)
              : Border.all(color: AppColors.transparent),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color:
                  isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            SizedBox(width: 8.w),
            MyAppText(
              data: label,
              size: 12.5.sp,
              weight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color:
                  isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    final firstDayOfMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => _changeMonth(-1),
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.textSecondary,
                size: 22.sp,
              ),
            ),
            MyAppText(
              data: _monthHeaderFormatter.format(_visibleMonth),
              size: 14.5.sp,
              weight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            IconButton(
              onPressed: () => _changeMonth(1),
              icon: Icon(
                Icons.chevron_right,
                color: AppColors.textPrimary,
                size: 22.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: _weekdayLabels
              .map((label) => Expanded(
                    child: Center(
                      child: MyAppText(
                        data: label,
                        size: 11.sp,
                        weight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ))
              .toList(),
        ),
        SizedBox(height: 10.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: firstWeekday + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.88,
            crossAxisSpacing: 5,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            if (index < firstWeekday) return const SizedBox();

            final dayNumber = index - firstWeekday + 1;
            final day =
                DateTime(_visibleMonth.year, _visibleMonth.month, dayNumber);
            final isDelivery = _isDeliveryDate(day);
            final isSelectable = _isSelectable(day);
            final isPaused = _isDatePaused(day);
            final isResume = _isResumeDate(day);
            final isToday = day.year == _today.year &&
                day.month == _today.month &&
                day.day == _today.day;

            return _buildCalendarDayCell(
              dayNumber: dayNumber,
              day: day,
              isDelivery: isDelivery,
              isSelectable: isSelectable,
              isPaused: isPaused,
              isResume: isResume,
              isToday: isToday,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendarDayCell({
    required int dayNumber,
    required DateTime day,
    required bool isDelivery,
    required bool isSelectable,
    required bool isPaused,
    required bool isResume,
    required bool isToday,
  }) {
    if (!isSelectable && !isToday && !isDelivery) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textDisabled,
                decoration: isPaused ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.textDisabled,
                decorationThickness: 1.8,
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              width: 3.5.r,
              height: 3.5.r,
              decoration: BoxDecoration(
                color: AppColors.textDisabled.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      );
    }

    if (!isSelectable && (isToday || day.isBefore(_firstSelectableDate))) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: isToday
              ? Border.all(color: AppColors.textPrimary, width: 1.2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                color: isToday ? AppColors.textPrimary : AppColors.textDisabled,
                decoration: isPaused ? TextDecoration.lineThrough : null,
                decorationColor:
                    isToday ? AppColors.textPrimary : AppColors.textDisabled,
                decorationThickness: 1.8,
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              width: 3.5.r,
              height: 3.5.r,
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.textDisabled
                    : AppColors.textDisabled.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      );
    }

    Color cellBg = AppColors.backgroundSurface;
    Color textColor = AppColors.textPrimary;
    Color dotColor = AppColors.textPrimary;
    Color borderColor = AppColors.borderDefault;
    TextDecoration? textDecoration;

    if (isResume) {
      cellBg = AppColors.textPrimary;
      textColor = AppColors.white;
      dotColor = AppColors.white;
      borderColor = AppColors.textPrimary;
    } else if (isPaused) {
      if (_isPermanentlyPaused) {
        cellBg = AppColors.backgroundSurface;
        textColor = AppColors.textSecondary;
        dotColor = AppColors.textDisabled;
        borderColor = AppColors.borderDefault;
        textDecoration = TextDecoration.lineThrough;
      } else {
        // Will be skipped state
        cellBg = AppColors.textSecondary.withValues(alpha: 0.18);
        textColor = AppColors.textSecondary;
        dotColor = AppColors.textSecondary;
        borderColor = AppColors.textSecondary.withValues(alpha: 0.55);
        textDecoration = TextDecoration.lineThrough;
      }
    }

    return InkWell(
      onTap: () => _toggleDatePause(day),
      borderRadius: BorderRadius.circular(14.r),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: cellBg,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isResume || !isPaused
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: textColor,
                    decoration: textDecoration,
                    decorationColor: textColor,
                    decorationThickness: 1.8,
                  ),
                ),
                SizedBox(height: 3.h),
                Container(
                  width: 4.r,
                  height: 4.r,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          if (isResume)
            Positioned(
              top: -4.r,
              right: -4.r,
              child: Container(
                width: 14.r,
                height: 14.r,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderDefault, width: 1),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 9.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLegendChip(
              label: 'Delivery day',
              boxBg: AppColors.backgroundSurface,
              borderColor: AppColors.textPrimary,
              dotColor: AppColors.textPrimary,
            ),
            // SizedBox(width: 16.w),
            // _buildLegendChip(
            //   label: 'Paused',
            //   boxBg: AppColors.backgroundSurface,
            //   borderColor: AppColors.textSecondary,
            //   dotColor: AppColors.textDisabled,
            // ),
            SizedBox(width: 16.w),
            _buildLegendChip(
              label: 'Will be skipped',
              boxBg: AppColors.backgroundSurface,
              borderColor: AppColors.textSecondary,
              dotColor: AppColors.textSecondary,
              hasStrike: true,
            ),
          ],
        ),
        // SizedBox(height: 10.h),
        // _buildLegendChip(
        //   label: 'Will resume',
        //   boxBg: AppColors.textPrimary,
        //   borderColor: AppColors.textPrimary,
        //   dotColor: AppColors.white,
        // ),
      ],
    );
  }

  Widget _buildLegendChip({
    required String label,
    required Color boxBg,
    required Color borderColor,
    required Color dotColor,
    bool hasStrike = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16.r,
          height: 16.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: boxBg,
            borderRadius: BorderRadius.circular(4.5.r),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 3.8.r,
                height: 3.8.r,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (hasStrike)
                Container(
                  width: 12.w,
                  height: 1.4.h,
                  color: borderColor,
                ),
            ],
          ),
        ),
        SizedBox(width: 6.w),
        MyAppText(
          data: label,
          size: 10.sp,
          weight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  // Widget _buildStatusPillSection() {
  //   final nextResume = _findNextResumeDate();

  //   final String statusText;
  //   final String dateText;

  //   if (_isPermanentlyPaused) {
  //     statusText = 'Paused';
  //     dateText = 'until manually resumed';
  //   } else if (nextResume != null) {
  //     statusText = 'Resuming';
  //     dateText = _shortDateFormatter.format(nextResume);
  //   } else if (_pausedDates.isNotEmpty) {
  //     statusText = 'Skipping';
  //     dateText =
  //         '${_pausedDates.length} ${_pausedDates.length == 1 ? "delivery" : "deliveries"}';
  //   } else {
  //     statusText = 'Active';
  //     dateText = 'All scheduled deliveries active';
  //   }

  //   return Container(
  //     width: double.infinity,
  //     padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
  //     decoration: BoxDecoration(
  //       color: AppColors.backgroundElevated,
  //       borderRadius: BorderRadius.circular(14.r),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 22.r,
  //           height: 22.r,
  //           alignment: Alignment.center,
  //           decoration: BoxDecoration(
  //             color: AppColors.backgroundSurface,
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(
  //             Icons.refresh_rounded,
  //             size: 13.sp,
  //             color: AppColors.textPrimary,
  //           ),
  //         ),
  //         SizedBox(width: 10.w),
  //         RichText(
  //           text: TextSpan(
  //             children: [
  //               TextSpan(
  //                 text: '$statusText  ',
  //                 style: TextStyle(
  //                   fontSize: 12.5.sp,
  //                   fontWeight: FontWeight.w700,
  //                   color: AppColors.textPrimary,
  //                 ),
  //               ),
  //               TextSpan(
  //                 text: dateText,
  //                 style: TextStyle(
  //                   fontSize: 12.sp,
  //                   fontWeight: FontWeight.w400,
  //                   color: AppColors.textSecondary,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBottomActionButtons(bool isCurrentlyPaused) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 48.h,
            child: OutlinedButton(
              onPressed: _isSaving ? null : _clearSelection,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.borderDefault, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                backgroundColor: AppColors.backgroundSurface,
              ),
              child: MyAppText(
                data: 'Clear',
                size: 13.sp,
                weight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      if (_hasChanges) {
                        _saveDatePauses();
                      } else if (isCurrentlyPaused) {
                        _confirmResume();
                      } else {
                        _confirmLongPause();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : MyAppText(
                      data: _hasChanges
                          ? 'Save Changes'
                          : isCurrentlyPaused
                              ? 'Resume Deliveries'
                              : 'Pause Deliveries',
                      size: 13.sp,
                      weight: FontWeight.w700,
                      color: AppColors.white,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  DateTime _findNextUpcomingDeliveryDate() {
    var check = _firstSelectableDate;
    while (!_isDeliveryDate(check)) {
      check = check.add(const Duration(days: 1));
    }
    return check;
  }

  Widget _buildPauseTabContent(bool isCurrentlyPaused) {
    final nextDelivery = _findNextUpcomingDeliveryDate();
    final dateFormatted = DateFormat('EEEE, MMM d').format(nextDelivery);

    if (isCurrentlyPaused) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.borderDefault.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: 20.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: MyAppText(
                        data: 'Resume Subscription Deliveries',
                        size: 13.5.sp,
                        weight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                _buildPauseBulletItem(
                    'Deliveries will resume from $dateFormatted'),
                _buildPauseBulletItem(
                    'All scheduled deliveries will restart automatically'),
                _buildPauseBulletItem(
                    'Your plan, schedule and time slot stay as they are'),
                _buildPauseBulletItem(
                    'You can pause individual dates again anytime from the calendar'),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16.sp,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: MyAppText(
                          data:
                              'Deliveries will resume according to your saved schedule',
                          size: 11.sp,
                          weight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          lineHeight: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _confirmResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : MyAppText(
                      data: 'Resume Deliveries',
                      size: 13.sp,
                      weight: FontWeight.w700,
                      color: AppColors.white,
                    ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCutoffNotice(),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.borderDefault.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.pause_rounded,
                      size: 20.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: MyAppText(
                      data: 'Pause everything until I resume',
                      size: 13.5.sp,
                      weight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              _buildPauseBulletItem('Deliveries stop from $dateFormatted'),
              _buildPauseBulletItem(
                  'No end date — nothing arrives until you resume'),
              _buildPauseBulletItem(
                  'Today\'s delivery (if scheduled) will not be affected'),
              _buildPauseBulletItem(
                  'Your plan, schedule and time slot stay as they are'),
              _buildPauseBulletItem(
                  'The individual dates you had skipped are covered by this pause'),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 16.sp,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: MyAppText(
                        data:
                            'Start again anytime with Resume on this subscription',
                        size: 11.sp,
                        weight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        lineHeight: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _confirmLongPause,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : MyAppText(
                    data: 'Pause Until I Resume',
                    size: 13.sp,
                    weight: FontWeight.w700,
                    color: AppColors.white,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCutoffNotice() {
    if (!_isPauseCutoffNow) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16.sp,
            color: AppColors.warning,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: MyAppText(
              data: SubscriptionScheduleCalendarSheet.pauseCutoffMessage,
              size: 11.sp,
              weight: FontWeight.w500,
              color: AppColors.textPrimary,
              lineHeight: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseBulletItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4.5.h, right: 10.w),
            child: Container(
              width: 5.r,
              height: 5.r,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: MyAppText(
              data: text,
              size: 11.2.sp,
              weight: FontWeight.w500,
              color: AppColors.textSecondary,
              lineHeight: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
