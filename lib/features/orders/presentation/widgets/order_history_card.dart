import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/orders_history_model.dart';
import 'orders_history_helpers.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderHistoryItem order;
  final VoidCallback onDetails;
  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onDetails,
  });
  @override
  Widget build(BuildContext context) {
    final title = order.title(isArabic(context));
    final color = order.isCancelled
        ? const Color(0xFFE46A4B)
        : order.isPrevious
        ? AppColors.badgeTextGreen
        : const {'new', 'pending'}.contains(order.statusValue.toLowerCase())
        ? const Color(0xFFAD7918)
        : const Color(0xFF3678E9);
    final background = order.isCancelled
        ? const Color(0xFFFFEDE7)
        : order.isPrevious
        ? AppColors.badgeBg
        : const {'new', 'pending'}.contains(order.statusValue.toLowerCase())
        ? const Color(0xFFFFF3DD)
        : const Color(0xFFE6F0FF);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.unselectedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title.isEmpty
                      ? ordersText(
                    context,
                    'طلب #${order.code}',
                    'Order #${order.code}',
                  )
                      : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              Spacer(),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    orderStatusText(context, order),
                    style: TextStyle(color: color, fontSize: 10.sp),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            [
              '#${order.code}',
              if (order.date != null)
                DateFormat(
                  'EEEE، d MMMM',
                  isArabic(context) ? 'ar' : 'en',
                ).format(order.date!.toLocal()),
            ].join(' • '),
            style: TextStyle(color: AppColors.subtitleGrey, fontSize: 11.sp),
          ),
          SizedBox(height: 6.h),
          const Divider(color: AppColors.unselectedBorder),
          Row(
            children: [
              Expanded(
                child: Text(
                  order.awaitingPrice
                      ? ordersText(
                    context,
                    'السعر بعد المعاينة',
                    'Price after inspection',
                  )
                      : (order.isCancelled &&
                      !order.hasInvoice &&
                      order.price == 0
                      ? '—'
                      : '${order.price.toStringAsFixed(3)} ${order.currency}')
                      .trim(),
                  style: TextStyle(
                    color: AppColors.badgeTextGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              TextButton(
                onPressed: onDetails,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.badgeTextGreen,
                  padding: EdgeInsets.zero,
                  minimumSize: Size(55.w, 28.h),
                ),
                child: Text(
                  ordersText(context, 'التفاصيل', 'Details'),
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
