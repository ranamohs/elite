import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';

class SubCategoryEmptyWidget extends StatelessWidget {
  final String subCategoryName;
  final VoidCallback? onRefresh;
  final VoidCallback? onBack;

  const SubCategoryEmptyWidget({
    super.key,
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
              AppStrings.noItemsAvailable.tr(),
              textAlign: TextAlign.center,
              style:AppStyles.styleMedium16(context).copyWith(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.titleDark,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppStrings.sectionUpdatingItems.tr(
                namedArgs: {'name': subCategoryName},
              ),
              textAlign: TextAlign.center,
              style:AppStyles.styleMedium16(context).copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.subtitleGrey,
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
                      AppStrings.refresh.tr(),
                      style:AppStyles.styleMedium16(context).copyWith(
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
