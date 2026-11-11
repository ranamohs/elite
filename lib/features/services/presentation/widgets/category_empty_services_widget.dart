import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryEmptyServicesWidget extends StatelessWidget {
  final bool isArabic;
  final String categoryName;
  final VoidCallback? onRefresh;
  final VoidCallback? onBack;

  const CategoryEmptyServicesWidget({
    super.key,
    required this.isArabic,
    required this.categoryName,
    this.onRefresh,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.homeHeaderGreen.withValues(alpha: 0.15),
                    AppColors.homeHeaderGreen.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Container(
                  width: 86.w,
                  height: 86.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.homeHeaderGreen.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.handyman_rounded,
                      size: 40.sp,
                      color: AppColors.homeHeaderGreen,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            Text(
              isArabic
                  ? 'لا توجد خدمات متاحة حالياً'
                  : 'No services available right now',
              textAlign: TextAlign.center,
              style: AppStyles.styleMedium16(context).copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.titleDark,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isArabic
                  ? 'قسم $categoryName قيد التحديث وسنضيف خدمات جديدة قريباً جداً'
                  : 'The $categoryName section is being updated and new services will be added very soon',
              textAlign: TextAlign.center,
              style: AppStyles.styleRegular14(context).copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.subtitleGrey,
                height: 1.5,
              ),
            ),

            SizedBox(height: 28.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRefresh != null)
                  ElevatedButton.icon(
                    onPressed: onRefresh,
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                    label: Text(
                      isArabic ? 'تحديث' : 'Refresh',
                      style: AppStyles.styleRegular14(context).copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.homeHeaderGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
