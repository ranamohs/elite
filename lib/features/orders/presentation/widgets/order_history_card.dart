import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/orders_history_model.dart';
import '../views/order_invoice_view.dart';
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
    final invoiced = order.statusValue.trim().toLowerCase() == 'invoiced';
    final color = order.isCancelled
        ? const Color(0xFFE46A4B)
        : order.isPrevious
        ? AppColors.badgeTextGreen
        : const Color(0xFF3678E9);
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.unselectedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  title.isEmpty
                      ? ordersText(
                    context,
                    'طلب #${order.code}',
                    'Order #${order.code}',
                  )
                      : title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Flexible(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Text(
                    orderStatusText(context, order),
                    style: TextStyle(fontSize: 10.sp, color: color),
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
                  'd MMMM yyyy',
                  isArabic(context) ? 'ar' : 'en',
                ).format(order.date!.toLocal()),
            ].join(' · '),
            style: TextStyle(fontSize: 11.sp, color: AppColors.subtitleGrey),
          ),
          SizedBox(height: 14.h),
          const Divider(height: 1, color: AppColors.unselectedBorder),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  order.priceAvailable
                      ? '${order.price.toStringAsFixed(2)} ${order.currency}'
                      .trim()
                      : '—',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.badgeTextGreen,
                  ),
                ),
              ),
              TextButton(
                onPressed: onDetails,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.subtitleGrey,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                ),
                child: Text(
                  ordersText(context, 'التفاصيل', 'Details'),
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          ),
          if (invoiced) ...[
            SizedBox(height: 6.h),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderInvoiceView(orderId: order.id),
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 40.h),
                foregroundColor: AppColors.badgeTextGreen,
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: Text(ordersText(context, 'عرض الفاتورة', 'View invoice')),
            ),
          ],
        ],
      ),
    );
  }
}
