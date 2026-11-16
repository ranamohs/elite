import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/order_details_model.dart';
import 'order_details_section.dart';
import 'orders_history_helpers.dart';

class OrderDetailsSummary extends StatelessWidget {
  final OrderDetailsModel model;
  const OrderDetailsSummary({super.key, required this.model});
  @override
  Widget build(BuildContext context) {
    final order = model.order;
    final title = order.title(isArabic(context));
    final statusColor = order.isCancelled
        ? Colors.deepOrange
        : order.isPrevious
        ? AppColors.badgeTextGreen
        : const Color(0xFFAD7918);
    return OrderDetailsSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(width: 8.w),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: order.isCancelled
                        ? const Color(0xFFFFEDE7)
                        : AppColors.badgeBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    orderStatusText(context, order),
                    style: TextStyle(color: statusColor, fontSize: 11.sp),
                  ),
                ),
              ),
            ],
          ),
          if (model.createdAt != null) ...[
            SizedBox(height: 12.h),
            Text(
              '${ordersText(context, 'تاريخ إنشاء الطلب', 'Created')}: ${DateFormat('d MMMM yyyy • HH:mm', isArabic(context) ? 'ar' : 'en').format(model.createdAt!.toLocal())}',
              style: TextStyle(color: AppColors.subtitleGrey, fontSize: 11.sp),
            ),
          ],
          if (model.updatedAt != null &&
              model.updatedAt != model.createdAt) ...[
            SizedBox(height: 6.h),
            Text(
              '${ordersText(context, 'آخر تحديث', 'Last updated')}: ${DateFormat('d MMMM yyyy • HH:mm', isArabic(context) ? 'ar' : 'en').format(model.updatedAt!.toLocal())}',
              style: TextStyle(color: AppColors.subtitleGrey, fontSize: 11.sp),
            ),
          ],
        ],
      ),
    );
  }
}
