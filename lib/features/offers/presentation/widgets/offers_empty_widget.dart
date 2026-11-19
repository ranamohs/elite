import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';

class OffersEmptyWidget extends StatelessWidget {
  final VoidCallback? onRefresh;

  const OffersEmptyWidget({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.homeHeaderGreen.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Icon(
                Icons.local_offer_outlined,
                size: 28.sp,
                color: AppColors.homeHeaderGreen,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            AppStrings.noOffersAvailable.tr(),
            textAlign: TextAlign.center,
            style: AppStyles.styleRegular14(context).copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.titleDark,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            AppStrings.offersComingSoon.tr(),
            textAlign: TextAlign.center,
            style: AppStyles.styleRegular14(context).copyWith(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.subtitleGrey,
            ),
          ),
          if (onRefresh != null) ...[
            SizedBox(height: 14.h),
            InkWell(
              onTap: onRefresh,
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.homeHeaderGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 15.sp,
                      color: AppColors.homeHeaderGreen,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      AppStrings.tryAgain.tr(),
                      style: AppStyles.styleRegular14(context).copyWith(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.homeHeaderGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
