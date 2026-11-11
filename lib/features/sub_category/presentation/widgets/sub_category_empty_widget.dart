import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class SubCategoryEmptyWidget extends StatelessWidget {
  final bool isArabic;
  final String subCategoryName;
  final VoidCallback? onRefresh;
  final VoidCallback? onBack;

  const SubCategoryEmptyWidget({
    super.key,
    required this.isArabic,
    required this.subCategoryName,
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
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.homeHeaderGreen.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Icon(
                  Icons.build_circle_outlined,
                  size: 46.sp,
                  color: AppColors.homeHeaderGreen,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              isArabic ? 'لا توجد عناصر متاحة' : 'No items available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isArabic
                  ? 'قسم $subCategoryName قيد التحديث وسنضيف بنود جديدة قريباً'
                  : 'Section $subCategoryName is being updated and new items will be added soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
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
                      style: TextStyle(
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
                if (onBack != null) ...[
                  SizedBox(width: 12.w),
                  OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFCBD5E1),
                        width: 1,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      isArabic ? 'رجوع' : 'Back',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
