import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';

class OrdersHistoryLoadingWidget extends StatelessWidget {
  const OrdersHistoryLoadingWidget({super.key});
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.loadingEffectColor,
    highlightColor: Colors.white,
    child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        3,
            (_) => Container(
          height: 125.h,
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    ),
  );
}
