import 'package:aaraa_kart/app/theme/app_colors.dart';

import 'package:aaraa_kart/core/network/api_constants.dart';
import 'package:aaraa_kart/cubit/order/order_cubit.dart';
import 'package:aaraa_kart/cubit/order/order_state.dart';
import 'package:aaraa_kart/cubit/storage/storage_cubit.dart';
import 'package:aaraa_kart/data/model/order_note_response_model.dart';
import 'package:aaraa_kart/presentation/common/my_app_shimmer.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/widgets/build_msg_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsx_plus/iconsx_plus.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderNotesBottomSheet extends StatefulWidget {
  final String orderId;

  final String resource;

  final String noun;

  const OrderNotesBottomSheet({super.key, required this.orderId})
      : resource = ApiConstants.CreateOrder,
        noun = 'Order';

  const OrderNotesBottomSheet.subscription({
    super.key,
    required String subscriptionId,
  })  : orderId = subscriptionId,
        resource = ApiConstants.GetSubscriptions,
        noun = 'Subscription';

  @override
  State<OrderNotesBottomSheet> createState() => _OrderNotesBottomSheetState();
}

class _OrderNotesBottomSheetState extends State<OrderNotesBottomSheet> {
  final TextEditingController _noteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAddingNote = false;
  bool _isSubmittingNote = false;

  @override
  void initState() {
    super.initState();
    _loadOrderNotes();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadOrderNotes() {
    BlocProvider.of<OrderCubit>(context)
        .getOrderNoteList(widget.orderId, resource: widget.resource);
  }

  void _onLinkTap(String? url) async {
    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showErrorToast('Cannot open the link');
        }
      } catch (e) {
        _showErrorToast('Invalid link format');
      }
    }
  }

  void _addNote() async {
    if (_noteController.text.trim().isEmpty) {
      _showErrorToast('Please enter a note');
      return;
    }

    setState(() {
      _isSubmittingNote = true;
    });

    try {
      BlocProvider.of<OrderCubit>(context).createOrderNote(
          widget.orderId, _noteController.text.trim(),
          resource: widget.resource);
    } catch (e) {
      setState(() {
        _isSubmittingNote = false;
      });
      _showErrorToast('Failed to add note. Please try again.');
    }
  }

  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.green.shade600,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.red.shade600,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  IconData _getAuthorIcon(String author, {bool isCustomerNote = false}) {
    if (isCustomerNote) return Iconsax.user_outline;

    switch (author.toLowerCase()) {
      case 'woocommerce':
        return Iconsax.shop_outline;
      case 'system':
        return Iconsax.monitor_outline;
      case 'admin':
        return Iconsax.setting_2_outline;
      default:
        return Iconsax.note_2_outline;
    }
  }

  Color _getAuthorColor(String author, {bool isCustomerNote = false}) {
    if (isCustomerNote) return AppColors.brandPrimary;

    switch (author.toLowerCase()) {
      case 'woocommerce':
      case 'system':
        return AppColors.brandPrimaryDark;
      case 'admin':
        return AppColors.brandSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _authorLabel(OrderNoteProduct note) {
    if (note.customerNote == true) {
      final phone = context.read<StorageCubit>().userData?.phoneNumber;
      return phone == null ? 'You' : '+91 $phone';
    }

    final author = note.author?.trim() ?? '';
    if (author.isEmpty || author.toLowerCase() == 'woocommerce') {
      return 'Store update';
    }
    print('Author: $author, Customer Note: ${note.customerNote}');
    return author;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundBase,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        clipBehavior: Clip.antiAlias,
        child: BlocConsumer<OrderCubit, OrderState>(
          listener: (context, state) {
            if (state is CreateOrderNoteSuccess) {
              _showSuccessToast('Note added successfully');
              setState(() {
                _noteController.clear();
                _isAddingNote = false;
                _isSubmittingNote = false;
              });
              _loadOrderNotes();
            } else if (state is CreateOrderNoteError) {
              setState(() {
                _isSubmittingNote = false;
              });
              _showErrorToast(state.message);
            }
          },
          // Other order flows (list, pagination) share this cubit — ignore their
          // states so an unrelated emission can't blank out the notes list.
          buildWhen: (previous, current) =>
              current is OrderNoteLoading ||
              current is OrderNoteSuccess ||
              current is OrderNoteError,
          builder: (context, state) {
            final notes = (state is OrderNoteSuccess)
                ? state.orderNoteResponse ?? <OrderNoteProduct>[]
                : <OrderNoteProduct>[];
            final isLoading = state is OrderNoteLoading && state.isLoading;

            return Column(
              children: [
                _buildHeader(isLoading ? null : notes.length),
                Expanded(
                  child: isLoading
                      ? _buildLoadingSkeleton()
                      : state is OrderNoteError
                          ? _buildErrorState(state.message)
                          : notes.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  controller: scrollController,
                                  padding: EdgeInsets.fromLTRB(
                                      16.w, 16.h, 16.w, 24.h),
                                  itemCount: notes.length,
                                  itemBuilder: (context, index) =>
                                      _buildNoteTile(
                                    notes[index],
                                    isLast: index == notes.length - 1,
                                  ),
                                ),
                ),
                _buildAddNoteSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return buildMsgState(
      context,
      'No notes yet',
      'Updates about this ${widget.noun.toLowerCase()} from our team will show up here',
      () {},
      '',
      Iconsax.note_2_outline,
      showButton: false,
    );
  }

  Widget _buildErrorState(String message) {
    return buildMsgState(
      context,
      'Failed to load notes',
      message,
      _loadOrderNotes,
      'Retry',
      Iconsax.warning_2_outline,
    );
  }

  Widget _buildLoadingSkeleton() {
    return MyAppShimmer(
      isLoading: true,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        itemCount: 4,
        itemBuilder: (context, index) => _buildNoteTile(
          OrderNoteProduct(
            author: 'Store update',
            note: 'Loading the note content for this order right now',
            dateCreated: DateTime.now(),
          ),
          isLast: index == 3,
        ),
      ),
    );
  }

  Widget _buildHeader(int? noteCount) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 8.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        border: Border(bottom: BorderSide(color: AppColors.borderDisabled)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderDisabled,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Iconsax.messages_2_outline,
                  color: AppColors.brandPrimary,
                  size: 17.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyAppText(
                      data: '${widget.noun} Notes',
                      size: 14.sp,
                      weight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 3.h),
                    MyAppText(
                      data: '${widget.noun} #${widget.orderId}',
                      size: 10.sp,
                      weight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              if (noteCount != null && noteCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: MyAppText(
                    data: '$noteCount ${noteCount == 1 ? 'update' : 'updates'}',
                    size: 10.sp,
                    weight: FontWeight.w700,
                    color: AppColors.brandPrimary,
                  ),
                ),
              IconButton(
                constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                padding: EdgeInsets.all(6.r),
                icon: Icon(Icons.close,
                    size: 18.sp, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddNoteSection() {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border:
            Border.all(color: AppColors.borderDefault ?? Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_comment_outlined,
                color: AppColors.brandPrimary,
                size: 16.r,
              ),
              SizedBox(width: 8.w),
              MyAppText(
                data: 'Add Note',
                size: 12.sp,
                weight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (_isAddingNote)
            Column(
              children: [
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  enabled: !_isSubmittingNote,
                  decoration: InputDecoration(
                    hintText: 'Enter your note here...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                          color:
                              AppColors.borderDefault ?? Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.brandPrimary),
                    ),
                    contentPadding: EdgeInsets.all(12.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmittingNote
                            ? null
                            : () {
                                setState(() {
                                  _isAddingNote = false;
                                  _noteController.clear();
                                });
                              },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: MyAppText(
                          data: 'Cancel',
                          size: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmittingNote ? null : _addNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _isSubmittingNote
                            ? SizedBox(
                                height: 16.h,
                                width: 16.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : MyAppText(
                                data: 'Add Note',
                                size: 12.sp,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _isAddingNote = true),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.brandPrimary),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon:
                    Icon(Icons.add, color: AppColors.brandPrimary, size: 16.r),
                label: MyAppText(
                  data: 'Add New Note',
                  size: 12.sp,
                  color: AppColors.brandPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoteTile(OrderNoteProduct note, {required bool isLast}) {
    final isCustomerNote = note.customerNote == true;
    final accent =
        _getAuthorColor(note.author ?? '', isCustomerNote: isCustomerNote);
    const railWidth = 30.0;

    return Stack(
      children: [
        // Connector runs the full tile height (the gap below is inside this
        // Stack) so the timeline stays unbroken between notes. The marker is
        // painted after it, and its canvas-coloured ring masks it.
        if (!isLast)
          Positioned(
            left: (railWidth.w - 2.w) / 2,
            top: 0,
            bottom: 0,
            child: Container(width: 2.w, color: AppColors.borderDisabled),
          ),
        Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: railWidth.w,
                height: railWidth.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.backgroundBase, width: 2),
                ),
                child: Icon(
                  _getAuthorIcon(note.author ?? '',
                      isCustomerNote: isCustomerNote),
                  color: accent,
                  size: 14.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isCustomerNote
                        ? accent.withOpacity(0.05)
                        : AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isCustomerNote
                          ? accent.withOpacity(0.2)
                          : AppColors.borderDisabled,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MyAppText(
                              data: _authorLabel(note),
                              size: 11.sp,
                              weight: FontWeight.w700,
                              color: isCustomerNote
                                  ? accent
                                  : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Iconsax.clock_outline,
                              size: 10.sp, color: AppColors.textTertiary),
                          SizedBox(width: 4.w),
                          MyAppText(
                            data: _formatTimestamp(
                                note.dateCreated ?? DateTime.now()),
                            size: 9.5.sp,
                            weight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Html(
                        data: note.note ?? '',
                        shrinkWrap: true,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            color: AppColors.textSecondary,
                            fontSize: FontSize(11.5.sp),
                            lineHeight: const LineHeight(1.5),
                          ),
                          "p": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                          ),
                          "a": Style(
                            color: AppColors.brandPrimary,
                            textDecoration: TextDecoration.underline,
                          ),
                        },
                        onLinkTap: (url, _, __) => _onLinkTap(url),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


