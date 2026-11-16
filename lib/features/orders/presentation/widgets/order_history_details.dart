import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/orders_history_model.dart';
import 'orders_history_helpers.dart';

class OrderHistoryDetails extends StatelessWidget {
  final OrderHistoryItem order;
  const OrderHistoryDetails({super.key, required this.order});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Directionality(
      textDirection: isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ordersText(
                      context,
                      'تفاصيل الطلب #${order.code}',
                      'Order #${order.code} details',
                    ),
                    style: AppStyles.styleMedium16(context),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              orderStatusText(context, order),
              style: const TextStyle(color: AppColors.badgeTextGreen),
            ),
            SizedBox(height: 14.h),
            ...order.items.map(
                  (line) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.name(isArabic(context)),
                      style: AppStyles.styleRegular14(context),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${line.quantity} × ${line.unitPrice.toStringAsFixed(3)} ${line.currency}',
                      style: TextStyle(
                        color: AppColors.subtitleGrey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Text(
              order.awaitingPrice
                  ? ordersText(
                context,
                'السعر النهائي بعد المعاينة',
                'Final price after inspection',
              )
                  : '${ordersText(context, 'الإجمالي', 'Total')}: ${order.price.toStringAsFixed(3)} ${order.currency}',
              style: AppStyles.styleMedium16(context),
            ),
          ],
        ),
      ),
    ),
  );
}
