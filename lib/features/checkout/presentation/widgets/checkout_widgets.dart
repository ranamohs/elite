import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/order_draft.dart';

String checkoutText(BuildContext context, String ar, String en) =>
    isArabic(context) ? ar : en;

class CheckoutScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final String action;
  final VoidCallback? onAction;
  final Widget? footer;
  const CheckoutScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.action,
    this.onAction,
    this.footer,
  });
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
    child: Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: AppStyles.styleMedium16(context).fontFamily,
        ),
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: AppColors.primaryColor),
      ),
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        appBar: AppBar(
          backgroundColor: AppColors.homeBackground,
          elevation: 0,
          title: Text(
            title,
            style: AppStyles.styleMedium16(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
          child: body,
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.unselectedBorder),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      minimumSize: Size(double.infinity, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                    ),
                    child: Text(
                      action,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (footer != null) footer!,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class CheckoutCard extends StatelessWidget {
  final Widget child;
  const CheckoutCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: AppColors.unselectedBorder),
    ),
    child: child,
  );
}

class CheckoutSectionTitle extends StatelessWidget {
  final String title;
  const CheckoutSectionTitle(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 16.h, bottom: 10.h),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(title, style: TextStyle(fontSize: 14.sp)),
    ),
  );
}

class OrderPriceCard extends StatelessWidget {
  final OrderDraft order;
  final String title;
  const OrderPriceCard({super.key, required this.order, required this.title});
  @override
  Widget build(BuildContext context) => CheckoutCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        SizedBox(height: 12.h),
        ...order.items.map(
              (item) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.title(isArabic(context))} × ${order.quantities[item.key]}',
                    style: TextStyle(
                      color: AppColors.subtitleGrey,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  order.money(item.price * (order.quantities[item.key] ?? 0)),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Text(
                checkoutText(context, 'الإجمالي', 'Total'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              order.money(order.subtotal),
              style: const TextStyle(
                color: AppColors.badgeTextGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class CheckoutNotice extends StatelessWidget {
  final String title, message;
  const CheckoutNotice({super.key, required this.title, required this.message});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF4DD),
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFFAF7800),
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          message,
          style: TextStyle(
            color: const Color(0xFFAF7800),
            height: 1.7,
            fontSize: 12.sp,
          ),
        ),
      ],
    ),
  );
}
