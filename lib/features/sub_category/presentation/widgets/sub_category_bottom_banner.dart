import 'package:elite/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_styles.dart';

class SubCategoryBottomBanner extends StatelessWidget {
  final bool isArabic;
  final VoidCallback? onTap;

  const SubCategoryBottomBanner({
    super.key,
    required this.isArabic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: Text(
          isArabic
              ? 'مش عارف المشكلة فين؟ اطلب معاينة وفني يحددها'
              : 'Don’t know the problem? Request an inspection',
          textAlign: TextAlign.center,
          style:AppStyles.styleMedium16(context).copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.homeContractBadgeGreen,
          ),
        ),
      ),
    );
  }
}
