import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import 'orders_history_helpers.dart';

class OrdersHistoryTabs extends StatelessWidget {
  final bool previous;
  final bool compact;
  final int currentCount;
  final bool hasMore;
  final ValueChanged<bool> onChanged;
  const OrdersHistoryTabs({
    super.key,
    this.compact = false,
    required this.previous,
    required this.currentCount,
    required this.hasMore,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: tab(
          ordersText(
            context,
            compact
                ? 'الحالية'
                : 'الحالية ($currentCount${hasMore ? '+' : ''})',
            compact
                ? 'Current'
                : 'Current ($currentCount${hasMore ? '+' : ''})',
          ),
          !previous,
              () => onChanged(false),
        ),
      ),
      SizedBox(width: 8.w),
      Expanded(
        child: tab(
          ordersText(context, 'السابقة', 'Previous'),
          previous,
              () => onChanged(true),
        ),
      ),
    ],
  );
  Widget tab(String title, bool selected, VoidCallback onTap) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      backgroundColor: selected ? AppColors.primaryColor : Colors.white,
      foregroundColor: selected ? Colors.white : AppColors.titleDark,
      minimumSize: Size(0, compact ? 30.h : 42.h),
      padding: EdgeInsets.symmetric(horizontal: compact ? 8.w : 16.w),
      side: BorderSide(
        color: selected ? AppColors.primaryColor : AppColors.unselectedBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
    child: Text(title, style: TextStyle(fontSize: compact ? 10.sp : 12.sp)),
  );
}
