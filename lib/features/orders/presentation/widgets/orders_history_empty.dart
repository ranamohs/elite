import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import 'orders_history_helpers.dart';

class OrdersHistoryEmpty extends StatelessWidget {
  final bool previous;
  final VoidCallback onRequestService;
  const OrdersHistoryEmpty({
    super.key,
    required this.previous,
    required this.onRequestService,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 30.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 164.w,
            height: 164.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F6E5),
            ),
            child: Center(
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.badgeBg,
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  size: 52.sp,
                  color: AppColors.badgeTextGreen,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          previous
              ? ordersText(
            context,
            'مفيش طلبات سابقة لسه',
            'No previous orders yet',
          )
              : ordersText(
            context,
            'لسه ماعملتش أي طلب',
            'You haven’t placed any orders yet',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.titleDark,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          ordersText(
            context,
            'أول ما تطلب خدمة هتلاقي كل طلباتك وحالتها هنا خطوة بخطوة.',
            'Once you request a service, you can find your orders and their status here.',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.subtitleGrey,
            height: 1.8,
          ),
        ),
        SizedBox(height: 24.h),
        FilledButton(
          onPressed: onRequestService,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            minimumSize: Size(double.infinity, 46.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            ordersText(context, 'اطلب خدمة دلوقتي', 'Request a service now'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
