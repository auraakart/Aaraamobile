import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/data/model/get_customer_subs.dart';
import 'package:aaraa_kart/data/model/scheduled_delivery_item.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

enum DeliveryIndicatorType {
  none,
  active,
  paused,
}

class SubscriptionCalendarRibbon extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<GetCustomerSubscriptionsResponseModel>? subscriptions;
  final List<ScheduledDeliveryItem>? futureDeliveries;

  const SubscriptionCalendarRibbon({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.subscriptions,
    this.futureDeliveries,
  });

  @override
  State<SubscriptionCalendarRibbon> createState() =>
      _SubscriptionCalendarRibbonState();
}

class _SubscriptionCalendarRibbonState
    extends State<SubscriptionCalendarRibbon> {
  late final ScrollController _scrollController;
  late final List<DateTime> _dates;
  late final DateTime _today;

  static const int _pastDays = 30;
  static const int _futureDays = 30;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);

    _dates = List.generate(
      _pastDays + _futureDays + 1,
      (index) => _today.subtract(Duration(days: _pastDays - index)),
    );

    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(widget.selectedDate, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant SubscriptionCalendarRibbon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToDate(widget.selectedDate, animate: true);
      });
    }
  }

  void _scrollToDate(DateTime date, {bool animate = false}) {
    if (!_scrollController.hasClients) return;
    final index = _dates.indexWhere((d) => _isSameDay(d, date));
    if (index == -1) return;

    final itemWidth = 60.w;
    final targetOffset = (index * itemWidth).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    if (animate) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return DateTime(value.year, value.month, value.day);
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  bool _isDeliveryDateForSub(
      GetCustomerSubscriptionsResponseModel sub, DateTime day) {
    final scheduleType = sub.deliverySchedule?.type?.toLowerCase() ?? 'daily';
    final normalized = _normalize(day);

    final startDate =
        _parseDate(sub.startDateGmt ?? sub.dateCreated) ?? DateTime(2020, 1, 1);

    if (normalized.isBefore(startDate)) return false;

    switch (scheduleType) {
      case 'daily':
        return true;
      case 'alternate':
        final diffDays = normalized.difference(startDate).inDays;
        return diffDays % 2 == 0;
      case 'weekend':
        return day.weekday == DateTime.saturday ||
            day.weekday == DateTime.sunday;
      case 'custom':
        final days = sub.deliverySchedule?.days;
        if (days == null || days.isEmpty) return true;
        final isoWeekday = day.weekday;
        final scheduleWeekday = isoWeekday == 7 ? 0 : isoWeekday;
        return days.contains(scheduleWeekday);
      default:
        return true;
    }
  }

  bool _isSubPausedOnDate(
      GetCustomerSubscriptionsResponseModel sub, DateTime day) {
    final status = sub.status?.toLowerCase() ?? '';
    final rawPauseDates = sub.pauseDates ?? [];
    final rawResume = sub.resumeDate;

    final isPausedFlag = status == 'pause' ||
        sub.isPaused == true ||
        (status == 'on-hold' &&
            (sub.needsPayment != true ||
                sub.pauseType != null ||
                rawPauseDates.isNotEmpty));

    final isPermanent = sub.pauseType == 'permanent' ||
        (isPausedFlag && rawPauseDates.isEmpty && rawResume == null);

    final normalized = _normalize(day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (isPermanent) {
      if (!normalized.isBefore(tomorrow)) {
        return true;
      }
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(normalized);

    for (final item in rawPauseDates) {
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
          if (!normalized.isBefore(start) && !normalized.isAfter(end)) {
            return true;
          }
        }
      } else if (item != null) {
        final d = _parseDate(item);
        if (d != null && _isSameDay(d, normalized)) {
          return true;
        }
        if (item.toString().contains(dateStr)) {
          return true;
        }
      }
    }

    return false;
  }

  DeliveryIndicatorType _getDeliveryIndicator(DateTime day) {
    final normalized = _normalize(day);

    if (widget.futureDeliveries != null &&
        widget.futureDeliveries!.isNotEmpty) {
      final hasCustom = widget.futureDeliveries!
          .any((d) => _isSameDay(_normalize(d.deliveryDate), normalized));
      if (hasCustom) return DeliveryIndicatorType.active;
    }

    if (widget.subscriptions == null || widget.subscriptions!.isEmpty) {
      return DeliveryIndicatorType.none;
    }

    bool hasActiveDelivery = false;
    bool hasPausedDelivery = false;

    for (final sub in widget.subscriptions!) {
      final status = sub.status?.toLowerCase() ?? '';
      if (status != 'active' && status != 'on-hold' && status != 'pause') {
        continue;
      }

      if (_isDeliveryDateForSub(sub, normalized)) {
        if (_isSubPausedOnDate(sub, normalized)) {
          hasPausedDelivery = true;
        } else {
          hasActiveDelivery = true;
        }
      }
    }

    if (hasActiveDelivery) return DeliveryIndicatorType.active;
    if (hasPausedDelivery) return DeliveryIndicatorType.paused;
    return DeliveryIndicatorType.none;
  }

  @override
  Widget build(BuildContext context) {
    final selectedNorm = _normalize(widget.selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 12.h),
          child: MyAppText(
            data: 'Delivery Calendar',
            weight: FontWeight.w700,
            size: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(
          height: 58.h,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _dates.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final day = _dates[index];

              final isSelected = _isSameDay(
                day,
                selectedNorm,
              );

              final indicator = _getDeliveryIndicator(day);

              return _buildDateCard(
                day: day,
                isSelected: isSelected,
                indicator: indicator,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard({
    required DateTime day,
    required bool isSelected,
    required DeliveryIndicatorType indicator,
  }) {
    final dayName = isSelected
        ? DateFormat('E').format(day).toUpperCase()
        : DateFormat('E').format(day);

    final dayNumber = DateFormat('d').format(day);

    final Color bgColor = isSelected
        ? AppColors.calendarSelectedBg
        : AppColors.calendarUnselectedBg;

    final Color textColor =
        isSelected ? AppColors.white : AppColors.textPrimary;

    return InkWell(
      onTap: () => widget.onDateSelected(day),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 52.w,
        height: 50.h,
        padding: EdgeInsets.symmetric(
          vertical: 4.h,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? null
              : Border.all(
                  color: AppColors.borderDefault,
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.calendarSelectedBg.withValues(alpha: 0.20)
                  : AppColors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 6 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MyAppText(
              data: dayName,
              size: 11.sp,
              weight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: textColor,
            ),
            MyAppText(
              data: dayNumber,
              size: 16.sp,
              weight: FontWeight.w800,
              color: textColor,
            ),
            _buildIndicatorDot(
              indicator,
              isSelected,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorDot(DeliveryIndicatorType indicator, bool isSelected) {
    if (indicator == DeliveryIndicatorType.none && !isSelected) {
      return SizedBox(height: 4.r);
    }

    final Color dotColor = isSelected
        ? AppColors.white
        : indicator == DeliveryIndicatorType.active
            ? AppColors.calendarDotActive
            : indicator == DeliveryIndicatorType.paused
                ? AppColors.warning
                : AppColors.calendarDotInactive;

    return Container(
      width: 4.r,
      height: 4.r,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
