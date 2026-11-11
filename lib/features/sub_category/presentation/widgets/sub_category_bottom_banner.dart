import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        color: const Color(0xFFF1F8E9), // Light pastel green background
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Center(
        child: Text(
          isArabic
              ? 'مش عارف المشكلة فين؟ اطلب معاينة وفني يحددها'
              : 'Don’t know the problem? Request an inspection',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF558B2F),
          ),
        ),
      ),
    );
  }
}
