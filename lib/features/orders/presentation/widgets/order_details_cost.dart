import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/order_details_model.dart';
import 'order_details_section.dart';
import 'orders_history_helpers.dart';

class OrderDetailsCost extends StatelessWidget {
  final OrderDetailsModel model;
  const OrderDetailsCost({super.key, required this.model});
  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    return OrderDetailsSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            model.order.hasInvoice
                ? ordersText(context, 'الفاتورة', 'Invoice')
                : ordersText(context, 'ملخص التكلفة', 'Cost summary'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
          ),
          SizedBox(height: 16.h),
          ...model.lines.map(
                (line) => Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          line.title(ar),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.subtitleGrey,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      if (line.totalPrice != null)
                        Text(
                          '${line.totalPrice!.toStringAsFixed(3)} ${line.currency}'
                              .trim(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                    ],
                  ),
                  if (line.quantity != null || line.unitPrice != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        [
                          if (line.quantity != null)
                            '${ordersText(context, 'الكمية', 'Quantity')}: ${line.quantity}',
                          if (line.unitPrice != null)
                            '${ordersText(context, 'سعر الوحدة', 'Unit price')}: ${line.unitPrice!.toStringAsFixed(3)} ${line.currency}',
                        ].join(' • '),
                        style: TextStyle(
                          color: AppColors.subtitleGrey,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  if (line.details(ar).isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        line.details(ar),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.subtitleGrey,
                        ),
                      ),
                    ),
                  if (line.categoryPath(ar).isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        line.categoryPath(ar),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.badgeTextGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (model.price != null) ...[
            const Divider(color: AppColors.unselectedBorder),
            Row(
              children: [
                Expanded(
                  child: Text(
                    ordersText(context, 'الإجمالي', 'Total'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${model.price!.toStringAsFixed(3)} ${model.order.currency}'
                      .trim(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.badgeTextGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
